<script lang="ts">
	import { page } from '$app/stores';
	import { onMount, tick } from 'svelte';
	import { browser } from '$app/environment';
	import { trpc } from '$lib/trpc/client';

	type Sleeve = Awaited<ReturnType<typeof trpc.sleeves.list.query>>[number];
	type PortfolioValuation = Awaited<ReturnType<typeof trpc.valuation.getPortfolioValuation.query>>;
	type SleeveAllocation = PortfolioValuation['sleeves'][number];

	let valuation: PortfolioValuation | null = null;
	let sleeves: Sleeve[] = [];
	let loading = true;
	let error: string | null = null;
	let saving = false;
	let refreshingPrices = false;
	let refreshResult: { successCount: number; errorCount: number; resolvedCount?: number; errors: Array<{ isin: string; error: string }> } | null = null;

	// View mode toggle: 'invested' or 'total'
	let viewMode: 'invested' | 'total' = 'invested';

	// Navigation - which sleeve we're currently viewing (null = root)
	let currentParentId: string | null = null;

	// Create sleeve form
	let showCreateForm = false;
	let newSleeveName = '';
	let newSleeveParentId: string | null = null;
	let creating = false;

	// Budget editing
	let budgetEdits: Record<string, number> = {};
	let editingBudgets = false;

	$: portfolioId = $page.params.id;
	
	// Current level sleeves (children of currentParentId)
	$: currentSleeves = sleeves
		.filter((s) => s.parentSleeveId === currentParentId)
		.sort((a, b) => a.sortOrder - b.sortOrder);
	
	// Parent sleeve (if we're navigated into one)
	$: currentParent = currentParentId ? sleeves.find(s => s.id === currentParentId) : null;
	
	// Breadcrumb path from root to current location
	$: breadcrumbs = getBreadcrumbs(currentParentId);

	// Budget constraint: at root level sum to 100%, at sub-level sum to parent's budget
	$: maxBudgetForLevel = currentParent?.budgetPercent ?? 100;
	$: budgetEditTotal = Object.values(budgetEdits).reduce((sum, v) => sum + v, 0);
	$: budgetEditValid = Math.abs(budgetEditTotal - maxBudgetForLevel) < 0.01;

	// Get children for a sleeve
	function getChildren(parentId: string): Sleeve[] {
		return sleeves.filter((s) => s.parentSleeveId === parentId).sort((a, b) => a.sortOrder - b.sortOrder);
	}

	// Get depth of a sleeve in the hierarchy (for indentation)
	function getSleeveDepth(sleeveId: string): number {
		let depth = 0;
		let currentId: string | null = sleeveId;
		while (currentId) {
			const sleeve = sleeves.find(s => s.id === currentId);
			if (sleeve?.parentSleeveId) {
				depth++;
				currentId = sleeve.parentSleeveId;
			} else {
				break;
			}
		}
		return depth;
	}

	// Build breadcrumb path
	function getBreadcrumbs(parentId: string | null): Array<{ id: string | null; name: string }> {
		const path: Array<{ id: string | null; name: string }> = [{ id: null, name: 'Portfolio' }];
		let currentId = parentId;
		const items: Array<{ id: string; name: string }> = [];
		
		while (currentId) {
			const sleeve = sleeves.find(s => s.id === currentId);
			if (sleeve) {
				items.unshift({ id: sleeve.id, name: sleeve.name });
				currentId = sleeve.parentSleeveId;
			} else {
				break;
			}
		}
		
		return [...path, ...items];
	}

	onMount(async () => {
		// Load view mode preference from localStorage
		if (browser) {
			const savedMode = localStorage.getItem('allocationViewMode');
			if (savedMode === 'invested' || savedMode === 'total') {
				viewMode = savedMode;
			}
		}
		await loadData();
	});

	function setViewMode(mode: 'invested' | 'total') {
		viewMode = mode;
		if (browser) {
			localStorage.setItem('allocationViewMode', mode);
		}
	}

	async function loadData() {
		loading = true;
		error = null;
		try {
			if (!portfolioId) return;
			[sleeves, valuation] = await Promise.all([
				trpc.sleeves.list.query({ portfolioId }),
				trpc.valuation.getPortfolioValuation.query({ portfolioId })
			]);
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to load data';
		} finally {
			loading = false;
		}
	}

	function navigateTo(parentId: string | null) {
		currentParentId = parentId;
		cancelEditBudgets();
	}

	function startEditBudgets() {
		budgetEdits = {};
		for (const s of currentSleeves) {
			budgetEdits[s.id] = s.budgetPercent;
		}
		editingBudgets = true;
	}

	function cancelEditBudgets() {
		editingBudgets = false;
		budgetEdits = {};
	}

	async function saveBudgets() {
		if (!budgetEditValid) {
			error = `Budgets must sum to ${maxBudgetForLevel.toFixed(1)}%. Current: ${budgetEditTotal.toFixed(1)}%`;
			return;
		}

		saving = true;
		error = null;
		try {
			const budgets = Object.entries(budgetEdits).map(([sleeveId, budgetPercent]) => ({
				sleeveId,
				budgetPercent
			}));
			await trpc.sleeves.updateBudgets.mutate({ budgets });
			editingBudgets = false;
			budgetEdits = {};
			await loadData();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to save budgets';
		} finally {
			saving = false;
		}
	}

	function openCreateSleeveForm() {
		newSleeveParentId = currentParentId;
		newSleeveName = '';
		showCreateForm = true;
	}

	async function createSleeve() {
		if (!portfolioId || !newSleeveName.trim()) return;

		creating = true;
		error = null;
		const createdUnderParentId = newSleeveParentId;
		try {
			await trpc.sleeves.create.mutate({
				portfolioId,
				parentSleeveId: createdUnderParentId,
				name: newSleeveName.trim(),
				budgetPercent: 0
			});
			showCreateForm = false;
			newSleeveName = '';
			newSleeveParentId = null;
			await loadData();
			// Navigate to the level where we created the sleeve so we can edit its budget
			if (createdUnderParentId !== currentParentId) {
				navigateTo(createdUnderParentId);
			}
			// Wait for reactive statements to update before starting budget edit
			await tick();
			startEditBudgets();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to create sleeve';
		} finally {
			creating = false;
		}
	}

	async function deleteSleeve(id: string, name: string) {
		const sleeve = sleeves.find(s => s.id === id);
		const children = sleeves.filter(s => s.parentSleeveId === id);
		const hasParent = sleeve?.parentSleeveId;
		
		let message = `Delete sleeve "${name}"?`;
		if (children.length > 0) {
			message += `\n\nThis will also delete ${children.length} sub-sleeve(s).`;
		}
		if (hasParent) {
			const parent = sleeves.find(s => s.id === hasParent);
			message += `\n\nAssets will be moved to "${parent?.name ?? 'parent sleeve'}".`;
		} else {
			message += '\n\nAssets will become unassigned.';
		}
		
		if (!confirm(message)) return;
		try {
			await trpc.sleeves.delete.mutate({ id });
			// If we deleted the current parent, navigate up
			if (id === currentParentId) {
				navigateTo(sleeve?.parentSleeveId ?? null);
			}
			await loadData();
			if (currentSleeves.length > 0) {
				startEditBudgets();
			}
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to delete sleeve';
		}
	}

	async function assignAsset(assetIsin: string, sleeveId: string | null) {
		error = null;
		try {
			if (sleeveId) {
				await trpc.sleeves.assignAsset.mutate({ sleeveId, assetIsin });
			} else {
				const currentSleeve = valuation?.sleeves.find((s) => 
					s.assets.some((a) => a.isin === assetIsin)
				);
				if (currentSleeve) {
					await trpc.sleeves.unassignAsset.mutate({ sleeveId: currentSleeve.sleeveId, assetIsin });
				}
			}
			await loadData();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to assign asset';
		}
	}

	async function refreshPrices() {
		error = null;
		refreshResult = null;
		refreshingPrices = true;
		try {
			const result = await trpc.oracle.refreshAllPrices.mutate();
			refreshResult = result;
			await loadData();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to refresh prices';
		} finally {
			refreshingPrices = false;
		}
	}

	function formatCurrency(value: number): string {
		return value.toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });
	}

	function formatPercent(value: number): string {
		return value.toFixed(1) + '%';
	}

	function formatBand(band: { lower: number; upper: number }): string {
		return `${band.lower.toFixed(0)}-${band.upper.toFixed(0)}%`;
	}

	function getStatusColor(status: string): string {
		return status === 'ok' ? 'bg-green-500' : 'bg-yellow-500';
	}

	function getStatusTextColor(status: string): string {
		return status === 'ok' ? 'text-green-600' : 'text-yellow-600';
	}

	function getSleeveValuation(sleeveId: string): SleeveAllocation | undefined {
		return valuation?.sleeves.find((s) => s.sleeveId === sleeveId);
	}

	function getAssetSleeveId(assetIsin: string): string | null {
		if (!valuation) return null;
		for (const sleeve of valuation.sleeves) {
			if (sleeve.assets.some((a) => a.isin === assetIsin)) {
				return sleeve.sleeveId;
			}
		}
		return null;
	}

	// Get all sleeves (for asset assignment dropdown)
	$: assignableSleeves = sleeves;

	// Get all assets in a sleeve and its descendants recursively
	function getAssetsInSleeveTree(sleeveId: string): Set<string> {
		const result = new Set<string>();
		const sleeveVal = valuation?.sleeves.find(s => s.sleeveId === sleeveId);
		if (sleeveVal) {
			for (const asset of sleeveVal.directAssets) {
				result.add(asset.isin);
			}
		}
		// Recursively get assets from children
		const children = sleeves.filter(s => s.parentSleeveId === sleeveId);
		for (const child of children) {
			const childAssets = getAssetsInSleeveTree(child.id);
			for (const isin of childAssets) {
				result.add(isin);
			}
		}
		return result;
	}

	// All assets sorted by value, filtered by current navigation context
	$: allAssets = valuation ? [...valuation.sleeves.flatMap(s => s.directAssets), ...valuation.unassignedAssets] : [];
	$: sortedAssets = [...allAssets].sort((a, b) => b.valueEur - a.valueEur);
	
	// Filter assets based on current sleeve context
	$: filteredAssets = (() => {
		if (!currentParentId) {
			// At root level, show all assets
			return sortedAssets;
		}
		// When navigated into a sleeve, show only assets in that sleeve or its sub-sleeves
		const relevantIsins = getAssetsInSleeveTree(currentParentId);
		return sortedAssets.filter(a => relevantIsins.has(a.isin));
	})();

	// Calculate total value of filtered assets for percentage calculation
	$: filteredAssetsTotal = filteredAssets.reduce((sum, a) => sum + a.valueEur, 0);
</script>

<div class="min-h-screen bg-gray-50">
	<header class="bg-white shadow">
		<div class="mx-auto max-w-7xl px-4 py-6">
			<div class="flex items-center justify-between">
				<div class="flex items-center gap-4">
					<a href="/portfolios/{portfolioId}" class="text-gray-500 hover:text-gray-700">&larr; Back</a>
					<div>
						<h1 class="text-3xl font-bold text-gray-900">Sleeves & Allocation</h1>
						{#if valuation}
							<p class="text-gray-600">{valuation.portfolioName}</p>
						{/if}
					</div>
				</div>
				<div class="flex items-center gap-4">
					<!-- View Mode Toggle -->
					<div class="flex items-center gap-2 bg-gray-100 rounded-lg p-1">
						<button
							onclick={() => setViewMode('invested')}
							class="px-3 py-1.5 rounded text-sm font-medium transition-colors {viewMode === 'invested' ? 'bg-white shadow text-gray-900' : 'text-gray-600 hover:text-gray-900'}"
						>
							Invested
						</button>
						<button
							onclick={() => setViewMode('total')}
							class="px-3 py-1.5 rounded text-sm font-medium transition-colors {viewMode === 'total' ? 'bg-white shadow text-gray-900' : 'text-gray-600 hover:text-gray-900'}"
						>
							Total
						</button>
					</div>
					<button
						onclick={refreshPrices}
						disabled={refreshingPrices}
						class="rounded bg-gray-100 px-4 py-2 text-gray-700 hover:bg-gray-200 disabled:opacity-50"
					>
						{refreshingPrices ? 'Refreshing...' : 'Refresh Prices'}
					</button>
					<button
						onclick={openCreateSleeveForm}
						class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
					>
						+ New Sleeve
					</button>
				</div>
			</div>
		</div>
	</header>

	<main class="mx-auto max-w-7xl px-4 py-8">
		{#if error}
			<div class="mb-6 rounded-lg bg-red-50 p-4 text-red-700">
				<p>{error}</p>
				<button onclick={() => (error = null)} class="mt-2 text-sm underline">Dismiss</button>
			</div>
		{/if}

		{#if refreshResult}
			<div class="mb-6 rounded-lg {refreshResult.errorCount > 0 ? 'bg-yellow-50' : 'bg-green-50'} p-4">
				<div class="flex items-start justify-between">
					<div>
						<p class="font-medium {refreshResult.errorCount > 0 ? 'text-yellow-800' : 'text-green-800'}">
							Price refresh complete: {refreshResult.successCount} succeeded, {refreshResult.errorCount} failed
							{#if refreshResult.resolvedCount && refreshResult.resolvedCount > 0}
								<span class="text-blue-600">({refreshResult.resolvedCount} symbols auto-resolved)</span>
							{/if}
						</p>
						{#if refreshResult.errors.length > 0}
							<details class="mt-2">
								<summary class="text-sm text-yellow-700 cursor-pointer">Show {refreshResult.errors.length} errors</summary>
								<ul class="mt-2 text-sm text-yellow-600 space-y-1">
									{#each refreshResult.errors as err}
										<li><code class="bg-yellow-100 px-1 rounded">{err.isin}</code>: {err.error}</li>
									{/each}
								</ul>
							</details>
						{/if}
					</div>
					<button onclick={() => (refreshResult = null)} class="text-gray-500 hover:text-gray-700">&times;</button>
				</div>
			</div>
		{/if}

		<!-- Sleeve Band Violation Banner (only in Invested view) -->
		{#if viewMode === 'invested' && valuation && valuation.violationCount > 0}
			<details class="mb-6 rounded-lg bg-yellow-50 border border-yellow-200">
				<summary class="p-4 cursor-pointer select-none flex items-center gap-2">
					<span class="w-3 h-3 rounded-full bg-yellow-500"></span>
					<span class="text-yellow-800 font-medium flex-1">
						{valuation.violationCount} sleeve{valuation.violationCount !== 1 ? 's' : ''} outside target tolerance
					</span>
					<span class="text-yellow-600 text-sm">Click to expand</span>
				</summary>
				<div class="px-4 pb-4 space-y-2">
					{#each valuation.sleeves.filter(s => s.status === 'warning') as sleeveVal}
						<div class="text-sm text-yellow-800 bg-yellow-100 rounded px-3 py-2">
							<strong>{sleeveVal.sleeveName}</strong> is at {formatPercent(sleeveVal.actualPercentInvested)} but should be between {formatBand(sleeveVal.band)}.
							{#if sleeveVal.deltaPercent > 0}
								Consider reducing by ~{formatPercent(sleeveVal.actualPercentInvested - sleeveVal.band.upper)}.
							{:else}
								Consider increasing by ~{formatPercent(sleeveVal.band.lower - sleeveVal.actualPercentInvested)}.
							{/if}
						</div>
					{/each}
				</div>
			</details>
		{/if}

		<!-- Concentration Violation Banner (only in Invested view) -->
		{#if viewMode === 'invested' && valuation && valuation.concentrationViolationCount > 0}
			<details class="mb-6 rounded-lg bg-orange-50 border border-orange-200">
				<summary class="p-4 cursor-pointer select-none flex items-center gap-2">
					<span class="w-3 h-3 rounded-full bg-orange-500"></span>
					<span class="text-orange-800 font-medium flex-1">
						{valuation.concentrationViolationCount} asset{valuation.concentrationViolationCount !== 1 ? 's' : ''} exceeding concentration limit
					</span>
					<span class="text-orange-600 text-sm">Click to expand</span>
				</summary>
				<div class="px-4 pb-4 space-y-2">
					{#each valuation.concentrationViolations as violation}
						<div class="text-sm text-orange-800 bg-orange-100 rounded px-3 py-2">
							<strong>{violation.assetName}</strong> ({violation.assetTicker}) is at {formatPercent(violation.actualPercent)} but rule "{violation.ruleName}" limits it to {formatPercent(violation.maxPercent)}.
							Consider reducing by ~{formatPercent(violation.actualPercent - violation.maxPercent)}.
						</div>
					{/each}
				</div>
			</details>
		{/if}

		{#if loading}
			<div class="text-center py-12">
				<div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-blue-600 border-r-transparent"></div>
			</div>
		{:else if valuation}
			<!-- Portfolio Summary -->
			<div class="mb-6 rounded-lg bg-white p-6 shadow">
				<!-- Cash Section (always visible) -->
				<div class="flex items-center justify-between mb-4 pb-4 border-b">
					<div class="flex items-center gap-3">
						<span class="text-2xl">$</span>
						<div>
							<p class="text-sm text-gray-500">Cash (not in allocation)</p>
							<p class="text-xl font-bold">{formatCurrency(valuation.cashEur)}</p>
						</div>
					</div>
					<a href="/" class="text-sm text-blue-600 hover:text-blue-800">
						Edit Cash
					</a>
				</div>

				<div class="grid grid-cols-2 md:grid-cols-4 gap-4">
					<div>
						<p class="text-sm text-gray-500">
							{viewMode === 'invested' ? 'Invested Value' : 'Total Portfolio'}
						</p>
						<p class="text-2xl font-bold">
							{formatCurrency(viewMode === 'invested' ? valuation.investedValueEur : valuation.totalValueEur)}
						</p>
						<p class="text-xs text-gray-400">
							{viewMode === 'invested' ? 'Assigned holdings' : 'Holdings + Cash'}
						</p>
					</div>
					<div>
						<p class="text-sm text-gray-500">Total Holdings</p>
						<p class="text-2xl font-bold">{formatCurrency(valuation.totalHoldingsValueEur)}</p>
					</div>
					<div>
						<p class="text-sm text-gray-500">Unassigned</p>
						<p class="text-2xl font-bold {valuation.unassignedValueEur > 0 ? 'text-yellow-600' : ''}">{formatCurrency(valuation.unassignedValueEur)}</p>
					</div>
					{#if viewMode === 'invested'}
						<div>
							<p class="text-sm text-gray-500">Status</p>
							<p class="text-2xl font-bold {valuation.violationCount === 0 ? 'text-green-600' : 'text-yellow-600'}">
								{valuation.violationCount === 0 ? 'On Target' : `${valuation.violationCount} Warning${valuation.violationCount !== 1 ? 's' : ''}`}
							</p>
						</div>
					{:else}
						<div>
							<p class="text-sm text-gray-500">Cash Impact</p>
							<p class="text-lg font-medium text-gray-600">
								{valuation.cashEur > 0 ? `−${((valuation.cashEur / valuation.totalValueEur) * 100).toFixed(1)}% from targets` : 'No cash'}
							</p>
						</div>
					{/if}
				</div>
				{#if valuation.unassignedValueEur > 0}
					<p class="mt-4 text-sm text-yellow-600">
						Unassigned assets are excluded from allocation percentages. Assign them to sleeves below.
					</p>
				{/if}
				{#if !valuation.hasAllPrices}
					<p class="mt-4 text-sm text-yellow-600">
						Some assets are using cost basis instead of market price. Click "Refresh Prices" to fetch current prices.
					</p>
				{/if}
			</div>

			<div class="grid gap-6 lg:grid-cols-2">
				<!-- Sleeve Allocation -->
				<div class="rounded-lg bg-white p-6 shadow">
					<!-- Breadcrumb Navigation -->
					<nav class="flex items-center gap-2 text-sm mb-4">
						{#each breadcrumbs as crumb, i}
							{#if i > 0}
								<span class="text-gray-400">/</span>
							{/if}
							{#if i === breadcrumbs.length - 1}
								<span class="font-medium text-gray-900">{crumb.name}</span>
							{:else}
								<button
									onclick={() => navigateTo(crumb.id)}
									class="text-blue-600 hover:text-blue-800 hover:underline"
								>
									{crumb.name}
								</button>
							{/if}
						{/each}
					</nav>

					<div class="flex items-center justify-between mb-4">
						<div>
							<h2 class="text-xl font-semibold text-gray-900">
								{currentParent ? currentParent.name : 'Portfolio'} Sleeves
							</h2>
							{#if currentParent}
								<p class="text-sm text-gray-500">
									Budget available: {formatPercent(currentParent.budgetPercent)}
								</p>
							{/if}
						</div>
						{#if !editingBudgets && currentSleeves.length > 0}
							<button onclick={startEditBudgets} class="text-sm text-blue-600 hover:text-blue-800">
								Edit Budgets
							</button>
						{/if}
					</div>

					{#if editingBudgets}
						<!-- Budget Edit Mode -->
						<div class="space-y-3">
							{#each currentSleeves as sleeve}
								<div class="flex items-center gap-3">
									<span class="flex-1 font-medium">{sleeve.name}</span>
									<input
										type="number"
										min="0"
										max={maxBudgetForLevel}
										step="0.1"
										bind:value={budgetEdits[sleeve.id]}
										class="w-20 rounded border px-2 py-1 text-right"
									/>
									<span class="text-gray-500 w-6">%</span>
								</div>
							{/each}
							<div class="flex items-center justify-between pt-3 border-t font-semibold">
								<span>Total:</span>
								<span class={budgetEditValid ? 'text-green-600' : 'text-red-600'}>
									{budgetEditTotal.toFixed(1)}% / {maxBudgetForLevel.toFixed(1)}%
								</span>
							</div>
							{#if !budgetEditValid}
								<p class="text-sm text-red-600">
									Must equal exactly {formatPercent(maxBudgetForLevel)}
									{#if currentParent}
										(the {currentParent.name} budget)
									{/if}
								</p>
							{/if}
							<div class="flex gap-2 pt-3">
								<button
									onclick={saveBudgets}
									disabled={saving || !budgetEditValid}
									class="rounded bg-blue-600 px-4 py-2 text-sm text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
								>
									{saving ? 'Saving...' : 'Save Budgets'}
								</button>
								<button
									onclick={cancelEditBudgets}
									class="rounded bg-gray-100 px-4 py-2 text-sm text-gray-700 hover:bg-gray-200"
								>
									Cancel
								</button>
							</div>
						</div>
					{:else}
						<!-- Allocation Display -->
						<div class="space-y-3">
							{#if currentSleeves.length === 0}
								<p class="text-gray-500 py-4">
									No sleeves at this level. Click "+ New Sleeve" to create one.
								</p>
							{/if}

							{#each currentSleeves as sleeve (sleeve.id)}
								{@const sleeveVal = getSleeveValuation(sleeve.id)}
								{@const children = getChildren(sleeve.id)}
								{@const hasChildren = children.length > 0}
								{@const actualPercent = sleeveVal ? (viewMode === 'invested' ? sleeveVal.actualPercentInvested : sleeveVal.actualPercentTotal) : 0}
								{@const isWarning = viewMode === 'invested' && sleeveVal?.status === 'warning'}
								
								<div class="rounded-lg border {isWarning ? 'border-yellow-300 bg-yellow-50/30' : 'border-gray-200'} p-4 cursor-pointer hover:border-blue-300 hover:bg-blue-50/50"
									onclick={() => navigateTo(sleeve.id)}
									role="button"
									tabindex={0}
									onkeydown={(e) => e.key === 'Enter' && navigateTo(sleeve.id)}
								>
									<!-- Header row: Name + Delete -->
									<div class="flex items-center justify-between mb-3">
										<div class="flex items-center gap-2">
											<span class="font-semibold text-gray-900">{sleeve.name}</span>
											{#if hasChildren}
												<span class="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded">
													{children.length} sub-sleeve{children.length !== 1 ? 's' : ''}
												</span>
												<span class="text-gray-400">&rarr;</span>
											{/if}
										</div>
										<button
											onclick={(e) => { e.stopPropagation(); deleteSleeve(sleeve.id, sleeve.name); }}
											class="text-red-500 hover:text-red-700 text-sm"
										>
											Delete
										</button>
									</div>
									
									{#if sleeveVal}
										<!-- Main stats row: Actual % (large) + Value -->
										<div class="flex items-baseline justify-between mb-2">
											<div class="flex items-baseline gap-3">
												<!-- Actual allocation - PRIMARY -->
												<span class="text-3xl font-bold {isWarning ? 'text-yellow-700' : 'text-gray-900'}">
													{formatPercent(actualPercent)}
												</span>
												<!-- Delta from target -->
												{#if viewMode === 'invested'}
													<span class="text-sm {sleeveVal.deltaPercent >= 0 ? 'text-green-600' : 'text-red-600'}">
														{sleeveVal.deltaPercent >= 0 ? '+' : ''}{formatPercent(sleeveVal.deltaPercent)}
													</span>
												{:else}
													{@const totalDelta = sleeveVal.actualPercentTotal - sleeveVal.budgetPercent}
													<span class="text-sm {totalDelta >= 0 ? 'text-green-600' : 'text-red-600'}">
														{totalDelta >= 0 ? '+' : ''}{formatPercent(totalDelta)}
													</span>
												{/if}
											</div>
											<span class="text-lg font-semibold text-gray-700">{formatCurrency(sleeveVal.totalValueEur)}</span>
										</div>

										<!-- Progress bar -->
										<div class="relative h-2 bg-gray-200 rounded overflow-hidden mb-2">
											<div 
												class="h-full {isWarning ? 'bg-yellow-500' : 'bg-blue-500'} transition-all"
												style="width: {Math.min((actualPercent / (maxBudgetForLevel || 100)) * 100, 100)}%"
											></div>
											<!-- Target marker -->
											<div 
												class="absolute top-0 h-full w-0.5 bg-gray-800"
												style="left: {(sleeveVal.budgetPercent / (maxBudgetForLevel || 100)) * 100}%"
											></div>
										</div>

										<!-- Target info - SECONDARY -->
										<div class="text-sm text-gray-500">
											Target: {formatPercent(sleeveVal.budgetPercent)}
											{#if viewMode === 'invested'}
												<span class="text-gray-400">(acceptable: {formatBand(sleeveVal.band)})</span>
											{/if}
										</div>

										<!-- Show direct assets -->
										{#if sleeveVal.directAssets && sleeveVal.directAssets.length > 0}
											<div class="mt-3 text-sm text-gray-600">
												{sleeveVal.directAssets.length} direct asset{sleeveVal.directAssets.length !== 1 ? 's' : ''}:
												{sleeveVal.directAssets.map(a => a.ticker).join(', ')}
												{#if hasChildren}
													<span class="text-gray-400 ml-1">({formatCurrency(sleeveVal.directValueEur)})</span>
												{/if}
											</div>
										{:else if !hasChildren}
											<div class="mt-3 text-sm text-gray-400">No assets assigned</div>
										{/if}

										<!-- Show breakdown hint for parent sleeves -->
										{#if hasChildren && sleeveVal.totalValueEur > (sleeveVal.directValueEur ?? 0)}
											<div class="mt-1 text-xs text-gray-400">
												Includes {formatCurrency(sleeveVal.totalValueEur - (sleeveVal.directValueEur ?? 0))} from sub-sleeves
											</div>
										{/if}
									{/if}
								</div>
							{/each}

							<!-- Cash row (only in Total view at root level) -->
							{#if viewMode === 'total' && currentParentId === null && valuation.cashEur > 0}
								<div class="rounded border border-dashed border-gray-300 bg-gray-50 p-4">
									<div class="flex items-center justify-between">
										<div class="flex items-center gap-2">
											<span class="text-gray-400">$</span>
											<span class="font-medium text-gray-600">Cash (uninvested)</span>
										</div>
										<span class="text-gray-600">{formatPercent((valuation.cashEur / valuation.totalValueEur) * 100)}</span>
									</div>
									<div class="mt-2 text-sm text-gray-500">
										{formatCurrency(valuation.cashEur)}
									</div>
								</div>
							{/if}

							<!-- Unassigned (only show at root level) -->
							{#if currentParentId === null && valuation.unassignedAssets.length > 0}
								<div class="rounded border border-yellow-300 bg-yellow-50 p-4">
									<div class="font-semibold text-yellow-800 mb-2">
										Unassigned ({valuation.unassignedAssets.length}) - Not in allocation %
									</div>
									<div class="text-sm text-yellow-700">
										{valuation.unassignedAssets.map(a => a.ticker).join(', ')}
									</div>
									<div class="text-sm font-medium text-yellow-800 mt-1">
										Value: {formatCurrency(valuation.unassignedValueEur)}
									</div>
								</div>
							{/if}
						</div>
					{/if}
				</div>

				<!-- Asset Assignment Table -->
				<div class="rounded-lg bg-white p-6 shadow">
					<div class="flex items-center justify-between mb-4">
						<div>
							<h2 class="text-xl font-semibold text-gray-900">
								{currentParent ? `Assets in ${currentParent.name}` : 'All Assets'}
							</h2>
							{#if currentParent && filteredAssets.length > 0}
								<p class="text-sm text-gray-500">
									Showing {filteredAssets.length} asset{filteredAssets.length !== 1 ? 's' : ''} ({formatCurrency(filteredAssetsTotal)})
								</p>
							{/if}
						</div>
					</div>

					{#if filteredAssets.length === 0}
						<p class="text-gray-500">
							{#if currentParent}
								No assets in this sleeve. Assign assets below or navigate to a different sleeve.
							{:else}
								No holdings to assign. <a href="/import" class="text-blue-600 hover:underline">Import orders</a> first.
							{/if}
						</p>
					{:else}
						<div class="overflow-x-auto">
							<table class="w-full text-sm">
								<thead class="bg-gray-50">
									<tr>
										<th class="px-3 py-2 text-left">Asset</th>
										<th class="px-3 py-2 text-right">Value</th>
										<th class="px-3 py-2 text-right">Alloc %</th>
										<th class="px-3 py-2 text-left">Sleeve</th>
									</tr>
								</thead>
								<tbody class="divide-y">
									{#each filteredAssets as asset}
										{@const allocPercent = valuation.investedValueEur > 0 ? (asset.valueEur / valuation.investedValueEur) * 100 : 0}
										<tr class="hover:bg-gray-50">
											<td class="px-3 py-2">
												<div class="font-medium">{asset.name}</div>
												<div class="text-xs text-gray-500">
													{asset.ticker} &middot; {asset.quantity} shares
													{#if asset.usingCostBasis}
														<span class="text-yellow-600">(cost basis)</span>
													{/if}
												</div>
											</td>
											<td class="px-3 py-2 text-right font-medium">
												{formatCurrency(asset.valueEur)}
											</td>
											<td class="px-3 py-2 text-right text-gray-600">
												{formatPercent(allocPercent)}
											</td>
											<td class="px-3 py-2">
												<select
													value={getAssetSleeveId(asset.isin) ?? ''}
													onchange={(e) => assignAsset(asset.isin, (e.target as HTMLSelectElement).value || null)}
													class="w-full rounded border-gray-300 text-sm"
												>
													<option value="">-- Unassigned --</option>
													{#each assignableSleeves as sleeve}
														{@const depth = getSleeveDepth(sleeve.id)}
														<option value={sleeve.id}>{'—'.repeat(depth)} {sleeve.name}</option>
													{/each}
												</select>
											</td>
										</tr>
									{/each}
								</tbody>
							</table>
						</div>
					{/if}
				</div>
			</div>
		{/if}
	</main>
</div>

<!-- Create Sleeve Modal -->
{#if showCreateForm}
	{@const selectedParent = newSleeveParentId ? sleeves.find(s => s.id === newSleeveParentId) : null}
	<div class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
		<div class="bg-white rounded-lg shadow-xl w-full max-w-md">
			<div class="p-6">
				<h2 class="text-xl font-semibold text-gray-900">New Sleeve</h2>

				<div class="mt-4 space-y-4">
					<label class="block">
						<span class="text-sm font-medium text-gray-700">Name</span>
						<input
							type="text"
							bind:value={newSleeveName}
							placeholder="e.g., Core, Satellite, Crypto..."
							class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
						/>
					</label>

					<label class="block">
						<span class="text-sm font-medium text-gray-700">Parent Sleeve</span>
						<select
							bind:value={newSleeveParentId}
							class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
						>
							<option value={null}>-- Top Level (Portfolio Root) --</option>
							{#each sleeves as sleeve}
								{@const depth = getSleeveDepth(sleeve.id)}
								<option value={sleeve.id}>{'—'.repeat(depth)} {sleeve.name}</option>
							{/each}
						</select>
					</label>

					<div class="text-sm text-gray-500 bg-gray-50 p-3 rounded">
						{#if selectedParent}
							<p>This sleeve will be a sub-sleeve of <strong>{selectedParent.name}</strong>.</p>
							<p class="mt-1">Its budget must fit within {selectedParent.name}'s {formatPercent(selectedParent.budgetPercent)} allocation.</p>
						{:else}
							<p>This will be a top-level sleeve.</p>
							<p class="mt-1">Top-level sleeve budgets must sum to 100%.</p>
						{/if}
					</div>

					<p class="text-sm text-gray-500">
						The new sleeve will start with 0% budget. After creating, you'll need to edit budgets to allocate.
					</p>
				</div>

				<div class="mt-6 flex justify-end gap-3">
					<button
						onclick={() => { showCreateForm = false; newSleeveName = ''; newSleeveParentId = null; }}
						class="rounded bg-gray-100 px-4 py-2 text-gray-700 hover:bg-gray-200"
					>
						Cancel
					</button>
					<button
						onclick={createSleeve}
						disabled={creating || !newSleeveName.trim()}
						class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
					>
						{creating ? 'Creating...' : 'Create Sleeve'}
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
