<script lang="ts">
	import { onMount } from 'svelte';
	import { trpc } from '$lib/trpc/client';

	let portfolios: Awaited<ReturnType<typeof trpc.portfolios.list.query>> = [];
	let holdings: Awaited<ReturnType<typeof trpc.holdings.list.query>> = [];
	let loading = true;
	let error: string | null = null;

	// Global cash
	let cashEur = 0;
	let editingCash = false;
	let cashInput = '';
	let savingCash = false;

	onMount(async () => {
		try {
			const [portfoliosResult, holdingsResult, cashResult] = await Promise.all([
				trpc.portfolios.list.query(),
				trpc.holdings.list.query(),
				trpc.cash.get.query()
			]);
			portfolios = portfoliosResult;
			holdings = holdingsResult;
			cashEur = cashResult.amountEur;
			cashInput = cashEur.toString();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to load data';
		} finally {
			loading = false;
		}
	});

	async function saveCash() {
		savingCash = true;
		try {
			const result = await trpc.cash.set.mutate({
				amountEur: parseFloat(cashInput) || 0
			});
			cashEur = result.amountEur;
			editingCash = false;
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to save cash';
		} finally {
			savingCash = false;
		}
	}

	function formatCurrency(value: number): string {
		return value.toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });
	}
</script>

<div class="min-h-screen bg-gray-50">
	<header class="bg-white shadow">
		<div class="mx-auto max-w-7xl px-4 py-6">
			<h1 class="text-3xl font-bold text-gray-900">FinancePal</h1>
			<p class="mt-1 text-gray-600">Portfolio Rebalancing</p>
		</div>
	</header>

	<main class="mx-auto max-w-7xl px-4 py-8">
		{#if loading}
			<div class="text-center py-12">
				<div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-blue-600 border-r-transparent"></div>
				<p class="mt-4 text-gray-600">Loading...</p>
			</div>
		{:else if error}
			<div class="rounded-lg bg-red-50 p-4 text-red-700">
				<p class="font-medium">Error</p>
				<p>{error}</p>
			</div>
		{:else}
			<!-- Cash Card -->
			<div class="mb-6 rounded-lg bg-white p-6 shadow">
				<div class="flex items-center justify-between">
					<div>
						<h2 class="text-xl font-semibold text-gray-900">Cash</h2>
						<p class="text-sm text-gray-500">Available cash not invested in assets</p>
					</div>
					{#if editingCash}
						<div class="flex items-center gap-2">
							<input
								type="number"
								step="0.01"
								bind:value={cashInput}
								class="w-32 rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
							/>
							<button
								onclick={saveCash}
								disabled={savingCash}
								class="rounded bg-blue-600 px-3 py-1.5 text-sm text-white hover:bg-blue-700 disabled:opacity-50"
							>
								{savingCash ? 'Saving...' : 'Save'}
							</button>
							<button
								onclick={() => { editingCash = false; cashInput = cashEur.toString(); }}
								class="rounded bg-gray-100 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-200"
							>
								Cancel
							</button>
						</div>
					{:else}
						<div class="flex items-center gap-4">
							<span class="text-2xl font-bold text-gray-900">{formatCurrency(cashEur)}</span>
							<button
								onclick={() => (editingCash = true)}
								class="text-sm text-blue-600 hover:text-blue-800"
							>
								Edit
							</button>
						</div>
					{/if}
				</div>
			</div>

			<div class="grid gap-6 md:grid-cols-2">
				<!-- Portfolios Card -->
				<div class="rounded-lg bg-white p-6 shadow">
					<h2 class="text-xl font-semibold text-gray-900">Portfolios</h2>
					{#if portfolios.length === 0}
						<p class="mt-4 text-gray-500">No portfolios yet.</p>
						<a href="/portfolios/new" class="mt-4 inline-block rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">
							Create Portfolio
						</a>
					{:else}
						<ul class="mt-4 space-y-2">
							{#each portfolios as portfolio}
								<a href="/portfolios/{portfolio.id}" class="flex items-center justify-between rounded border p-3 hover:bg-gray-50 transition-colors">
									<span class="font-medium">{portfolio.name}</span>
								</a>
							{/each}
						</ul>
						<a href="/portfolios/new" class="mt-4 inline-block text-blue-600 hover:text-blue-800 text-sm">
							+ Create another portfolio
						</a>
					{/if}
				</div>

				<!-- Holdings Card -->
				<div class="rounded-lg bg-white p-6 shadow">
					<h2 class="text-xl font-semibold text-gray-900">Holdings</h2>
					{#if holdings.length === 0}
						<p class="mt-4 text-gray-500">No holdings yet.</p>
						<a href="/import" class="mt-4 inline-block rounded bg-green-600 px-4 py-2 text-white hover:bg-green-700">
							Import CSV
						</a>
					{:else}
						<ul class="mt-4 space-y-2">
							{#each holdings as holding}
								<li class="flex items-center justify-between rounded border p-3">
									<div>
										<span class="font-medium">{holding.asset.name}</span>
										<span class="ml-2 text-sm text-gray-500">{holding.asset.ticker}</span>
									</div>
									<span class="text-gray-600">{holding.quantity} shares</span>
								</li>
							{/each}
						</ul>
					{/if}
				</div>
			</div>

			<!-- Quick Links -->
			<div class="mt-8 flex gap-4">
				<a href="/import" class="rounded bg-gray-100 px-4 py-2 text-gray-700 hover:bg-gray-200">
					Import Orders
				</a>
				<a href="/assets" class="rounded bg-gray-100 px-4 py-2 text-gray-700 hover:bg-gray-200">
					View Assets
				</a>
			</div>
		{/if}
	</main>
</div>
