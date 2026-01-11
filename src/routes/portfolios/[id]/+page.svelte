<script lang="ts">
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { trpc } from '$lib/trpc/client';
	import { DEFAULT_BAND_CONFIG } from '$lib/utils/bands';

	type Portfolio = Awaited<ReturnType<typeof trpc.portfolios.get.query>>;
	type PortfolioRule = Awaited<ReturnType<typeof trpc.rules.list.query>>[number];
	type AssetType = 'stock' | 'etf' | 'bond' | 'fund' | 'commodity' | 'other';

	const ASSET_TYPE_LABELS: Record<AssetType, string> = {
		stock: 'Stocks',
		etf: 'ETFs',
		bond: 'Bonds',
		fund: 'Funds',
		commodity: 'Commodities',
		other: 'Other'
	};

	let portfolio: Portfolio | null = null;
	let rules: PortfolioRule[] = [];
	let loading = true;
	let error: string | null = null;

	// Band settings
	let showBandSettings = false;
	let bandRelativeTolerance = DEFAULT_BAND_CONFIG.relativeTolerance;
	let bandAbsoluteFloor = DEFAULT_BAND_CONFIG.absoluteFloor;
	let bandAbsoluteCap = DEFAULT_BAND_CONFIG.absoluteCap;
	let savingBands = false;

	// Rule settings
	let showRuleForm = false;
	let newRuleName = '';
	let newRuleMaxPercent = 5;
	let newRuleAssetTypes: AssetType[] = ['stock']; // Default to stocks only
	let savingRule = false;

	$: portfolioId = $page.params.id;

	onMount(async () => {
		await loadPortfolio();
	});

	async function loadPortfolio() {
		loading = true;
		error = null;
		try {
			if (!portfolioId) {
				error = 'No portfolio ID';
				return;
			}
			[portfolio, rules] = await Promise.all([
				trpc.portfolios.get.query({ id: portfolioId }),
				trpc.rules.list.query({ portfolioId })
			]);
			// Load band settings
			bandRelativeTolerance = portfolio.bandRelativeTolerance;
			bandAbsoluteFloor = portfolio.bandAbsoluteFloor;
			bandAbsoluteCap = portfolio.bandAbsoluteCap;
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to load portfolio';
		} finally {
			loading = false;
		}
	}

	async function saveBandSettings() {
		if (!portfolio) return;
		savingBands = true;
		error = null;
		try {
			await trpc.portfolios.update.mutate({
				id: portfolio.id,
				bandRelativeTolerance,
				bandAbsoluteFloor,
				bandAbsoluteCap
			});
			showBandSettings = false;
			await loadPortfolio();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to save band settings';
		} finally {
			savingBands = false;
		}
	}

	function resetBandDefaults() {
		bandRelativeTolerance = DEFAULT_BAND_CONFIG.relativeTolerance;
		bandAbsoluteFloor = DEFAULT_BAND_CONFIG.absoluteFloor;
		bandAbsoluteCap = DEFAULT_BAND_CONFIG.absoluteCap;
	}

	function toggleAssetType(type: AssetType) {
		if (newRuleAssetTypes.includes(type)) {
			newRuleAssetTypes = newRuleAssetTypes.filter(t => t !== type);
		} else {
			newRuleAssetTypes = [...newRuleAssetTypes, type];
		}
	}

	async function createRule() {
		if (!portfolioId || !newRuleName.trim()) return;
		savingRule = true;
		error = null;
		try {
			await trpc.rules.createConcentrationLimit.mutate({
				portfolioId,
				name: newRuleName.trim(),
				config: {
					maxPercent: newRuleMaxPercent,
					assetTypes: newRuleAssetTypes.length > 0 ? newRuleAssetTypes : undefined
				}
			});
			// Reset form
			showRuleForm = false;
			newRuleName = '';
			newRuleMaxPercent = 5;
			newRuleAssetTypes = ['stock'];
			await loadPortfolio();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to create rule';
		} finally {
			savingRule = false;
		}
	}

	async function toggleRule(ruleId: string) {
		try {
			await trpc.rules.toggle.mutate({ id: ruleId });
			await loadPortfolio();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to toggle rule';
		}
	}

	async function deleteRule(ruleId: string, ruleName: string) {
		if (!confirm(`Delete rule "${ruleName}"?`)) return;
		try {
			await trpc.rules.delete.mutate({ id: ruleId });
			await loadPortfolio();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to delete rule';
		}
	}

	function formatRuleConfig(rule: PortfolioRule): string {
		const config = rule.config as { maxPercent: number; assetTypes?: AssetType[] };
		const types = config.assetTypes;
		if (!types || types.length === 0) {
			return `Max ${config.maxPercent}% per asset`;
		}
		const typeLabels = types.map(t => ASSET_TYPE_LABELS[t]).join(', ');
		return `Max ${config.maxPercent}% per ${typeLabels.toLowerCase()}`;
	}

	function formatCurrency(value: number): string {
		return value.toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });
	}
</script>

<div class="min-h-screen bg-gray-50">
	<header class="bg-white shadow">
		<div class="mx-auto max-w-7xl px-4 py-6">
			<div class="flex items-center gap-4">
				<a href="/" class="text-gray-500 hover:text-gray-700">&larr; Back</a>
				{#if portfolio}
					<h1 class="text-3xl font-bold text-gray-900">{portfolio.name}</h1>
				{:else}
					<h1 class="text-3xl font-bold text-gray-900">Portfolio</h1>
				{/if}
			</div>
		</div>
	</header>

	<main class="mx-auto max-w-7xl px-4 py-8">
		{#if error}
			<div class="mb-6 rounded-lg bg-red-50 p-4 text-red-700">
				<p class="font-medium">Error</p>
				<p>{error}</p>
				<button onclick={() => (error = null)} class="mt-2 text-sm underline">Dismiss</button>
			</div>
		{/if}

		{#if loading}
			<div class="text-center py-12">
				<div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-blue-600 border-r-transparent"></div>
				<p class="mt-4 text-gray-600">Loading portfolio...</p>
			</div>
		{:else if portfolio}
			<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
				<!-- Sleeves Card -->
				<div class="rounded-lg bg-white p-6 shadow">
					<h2 class="text-lg font-semibold text-gray-900">Sleeves & Allocation</h2>
					<p class="mt-2 text-gray-500">
						Organize assets into sleeves with budget targets
					</p>
					<a
						href="/portfolios/{portfolio.id}/sleeves"
						class="mt-4 inline-block rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
					>
						Manage Sleeves
					</a>
				</div>

				<!-- Tolerance Settings Card -->
				<div class="rounded-lg bg-white p-6 shadow">
					<div class="flex items-center justify-between">
						<h2 class="text-lg font-semibold text-gray-900">Tolerance Bands</h2>
						<button
							onclick={() => (showBandSettings = !showBandSettings)}
							class="text-sm text-blue-600 hover:text-blue-800"
						>
							{showBandSettings ? 'Hide' : 'Edit'}
						</button>
					</div>
					
					{#if showBandSettings}
						<div class="mt-4 space-y-4">
							<div>
								<label class="block text-sm font-medium text-gray-700">
									Relative Tolerance
								</label>
								<div class="mt-1 flex items-center gap-2">
									<input
										type="number"
										min="1"
										max="100"
										step="1"
										bind:value={bandRelativeTolerance}
										class="block w-20 rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
									/>
									<span class="text-gray-500">%</span>
								</div>
								<p class="mt-1 text-xs text-gray-500">
									Sleeves can drift ±{bandRelativeTolerance}% from their target
								</p>
							</div>

							<div>
								<label class="block text-sm font-medium text-gray-700">
									Minimum Band Width
								</label>
								<div class="mt-1 flex items-center gap-2">
									<input
										type="number"
										min="0"
										max="50"
										step="0.5"
										bind:value={bandAbsoluteFloor}
										class="block w-20 rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
									/>
									<span class="text-gray-500">pp</span>
								</div>
								<p class="mt-1 text-xs text-gray-500">
									Small targets won't have overly tight bands
								</p>
							</div>

							<div>
								<label class="block text-sm font-medium text-gray-700">
									Maximum Band Width
								</label>
								<div class="mt-1 flex items-center gap-2">
									<input
										type="number"
										min="1"
										max="50"
										step="0.5"
										bind:value={bandAbsoluteCap}
										class="block w-20 rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
									/>
									<span class="text-gray-500">pp</span>
								</div>
								<p class="mt-1 text-xs text-gray-500">
									Large targets won't have overly loose bands
								</p>
							</div>

							<div class="pt-3 border-t flex items-center justify-between">
								<button
									onclick={resetBandDefaults}
									class="text-sm text-gray-500 hover:text-gray-700"
								>
									Reset to Defaults
								</button>
								<div class="flex gap-2">
									<button
										onclick={() => { 
											showBandSettings = false;
											bandRelativeTolerance = portfolio?.bandRelativeTolerance ?? DEFAULT_BAND_CONFIG.relativeTolerance;
											bandAbsoluteFloor = portfolio?.bandAbsoluteFloor ?? DEFAULT_BAND_CONFIG.absoluteFloor;
											bandAbsoluteCap = portfolio?.bandAbsoluteCap ?? DEFAULT_BAND_CONFIG.absoluteCap;
										}}
										class="rounded bg-gray-100 px-3 py-1 text-sm text-gray-700 hover:bg-gray-200"
									>
										Cancel
									</button>
									<button
										onclick={saveBandSettings}
										disabled={savingBands || bandAbsoluteFloor > bandAbsoluteCap}
										class="rounded bg-blue-600 px-3 py-1 text-sm text-white hover:bg-blue-700 disabled:opacity-50"
									>
										{savingBands ? 'Saving...' : 'Save'}
									</button>
								</div>
							</div>
							{#if bandAbsoluteFloor > bandAbsoluteCap}
								<p class="text-sm text-red-600">
									Minimum band width cannot be greater than maximum
								</p>
							{/if}
						</div>
					{:else}
						<div class="mt-2 text-sm text-gray-600 space-y-1">
							<p>Relative: ±{portfolio.bandRelativeTolerance}%</p>
							<p>Min band: ±{portfolio.bandAbsoluteFloor}pp</p>
							<p>Max band: ±{portfolio.bandAbsoluteCap}pp</p>
						</div>
						<p class="mt-3 text-xs text-gray-400">
							Controls when sleeves show as "on target" vs "warning"
						</p>
					{/if}
				</div>
			</div>

			<!-- Portfolio Rules Section -->
			<div class="mt-6 rounded-lg bg-white p-6 shadow">
				<div class="flex items-center justify-between mb-4">
					<div>
						<h2 class="text-lg font-semibold text-gray-900">Concentration Rules</h2>
						<p class="text-sm text-gray-500">Limit how much any single asset can represent</p>
					</div>
					<button
						onclick={() => (showRuleForm = !showRuleForm)}
						class="rounded bg-blue-600 px-3 py-1.5 text-sm text-white hover:bg-blue-700"
					>
						{showRuleForm ? 'Cancel' : '+ Add Rule'}
					</button>
				</div>

				{#if showRuleForm}
					<div class="mb-6 p-4 bg-gray-50 rounded-lg border">
						<h3 class="font-medium text-gray-900 mb-3">New Concentration Limit</h3>
						<div class="space-y-4">
							<div>
								<label class="block text-sm font-medium text-gray-700 mb-1">
									Rule Name
								</label>
								<input
									type="text"
									bind:value={newRuleName}
									placeholder="e.g., Single stock limit"
									class="block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
								/>
							</div>

							<div>
								<label class="block text-sm font-medium text-gray-700 mb-1">
									Maximum Percentage
								</label>
								<div class="flex items-center gap-2">
									<input
										type="number"
										min="1"
										max="100"
										step="1"
										bind:value={newRuleMaxPercent}
										class="block w-24 rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
									/>
									<span class="text-gray-500">% of invested portfolio</span>
								</div>
							</div>

							<div>
								<label class="block text-sm font-medium text-gray-700 mb-2">
									Apply to Asset Types
								</label>
								<div class="flex flex-wrap gap-2">
									{#each Object.entries(ASSET_TYPE_LABELS) as [type, label]}
										<button
											onclick={() => toggleAssetType(type as AssetType)}
											class="px-3 py-1.5 rounded text-sm font-medium transition-colors {newRuleAssetTypes.includes(type as AssetType) 
												? 'bg-blue-100 text-blue-800 border border-blue-300' 
												: 'bg-gray-100 text-gray-600 border border-gray-200 hover:bg-gray-200'}"
										>
											{label}
										</button>
									{/each}
								</div>
								<p class="mt-2 text-xs text-gray-500">
									{#if newRuleAssetTypes.length === 0}
										Applies to all assets
									{:else}
										Only applies to: {newRuleAssetTypes.map(t => ASSET_TYPE_LABELS[t]).join(', ')}
									{/if}
								</p>
							</div>

							<div class="pt-3 border-t flex justify-end gap-2">
								<button
									onclick={() => { showRuleForm = false; newRuleName = ''; newRuleMaxPercent = 5; newRuleAssetTypes = ['stock']; }}
									class="rounded bg-gray-100 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-200"
								>
									Cancel
								</button>
								<button
									onclick={createRule}
									disabled={savingRule || !newRuleName.trim()}
									class="rounded bg-blue-600 px-3 py-1.5 text-sm text-white hover:bg-blue-700 disabled:opacity-50"
								>
									{savingRule ? 'Creating...' : 'Create Rule'}
								</button>
							</div>
						</div>
					</div>
				{/if}

				{#if rules.length === 0}
					<p class="text-gray-500 text-sm py-4">
						No concentration rules defined. Add a rule to monitor asset concentration.
					</p>
				{:else}
					<div class="space-y-3">
						{#each rules as rule}
							<div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg {rule.enabled ? '' : 'opacity-60'}">
								<div class="flex items-center gap-3">
									<button
										onclick={() => toggleRule(rule.id)}
										class="w-10 h-5 rounded-full transition-colors {rule.enabled ? 'bg-blue-600' : 'bg-gray-300'}"
										title={rule.enabled ? 'Disable rule' : 'Enable rule'}
									>
										<span class="block w-4 h-4 bg-white rounded-full shadow transform transition-transform {rule.enabled ? 'translate-x-5' : 'translate-x-0.5'}"></span>
									</button>
									<div>
										<p class="font-medium text-gray-900">{rule.name}</p>
										<p class="text-sm text-gray-500">{formatRuleConfig(rule)}</p>
									</div>
								</div>
								<button
									onclick={() => deleteRule(rule.id, rule.name)}
									class="text-red-500 hover:text-red-700 text-sm"
								>
									Delete
								</button>
							</div>
						{/each}
					</div>
				{/if}
			</div>

			<!-- Quick Links -->
			<div class="mt-8 grid gap-4 md:grid-cols-2">
				<a
					href="/import"
					class="rounded-lg bg-white p-6 shadow hover:shadow-md transition-shadow"
				>
					<h3 class="font-semibold text-gray-900">Import Orders</h3>
					<p class="mt-1 text-sm text-gray-500">Upload CSV from your broker</p>
				</a>
				<a
					href="/assets"
					class="rounded-lg bg-white p-6 shadow hover:shadow-md transition-shadow"
				>
					<h3 class="font-semibold text-gray-900">View Assets</h3>
					<p class="mt-1 text-sm text-gray-500">Manage assets and Yahoo symbols</p>
				</a>
			</div>

			<!-- Info -->
			<div class="mt-8 rounded-lg bg-gray-100 p-4 text-sm text-gray-600">
				<p>Created: {new Date(portfolio.createdAt).toLocaleDateString()}</p>
				<p>Last updated: {new Date(portfolio.updatedAt).toLocaleDateString()}</p>
			</div>
		{/if}
	</main>
</div>
