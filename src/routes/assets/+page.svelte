<script lang="ts">
	import { onMount, onDestroy, tick } from 'svelte';
	import { browser } from '$app/environment';
	import { trpc } from '$lib/trpc/client';
	import { autoRefresh } from '$lib/stores/autoRefresh';
	import { serverEvents, isConnected, syncProgress, syncQueue, currentlySyncingTicker, recentlyUpdated } from '$lib/stores/serverEvents';
	import { DEFAULT_AUTO_REFRESH_INTERVAL_MS, MIN_AUTO_REFRESH_INTERVAL_MS } from '$lib/utils/config';
	import { createChart, type IChartApi, type ISeriesApi, type LineData, type Time, LineSeries } from 'lightweight-charts';

	type AssetWithHolding = Awaited<ReturnType<typeof trpc.assets.listWithHoldings.query>>[number];
	
	// Common shape for symbols (both from resolve mutation and query)
	interface YahooSymbol {
		symbol: string;
		exchange?: string | null;
		exchangeDisplay?: string | null;
		quoteType?: string | null;
	}

	let assets: AssetWithHolding[] = [];
	let loading = true;
	let error: string | null = null;
	let saving = false;

	// Show sold assets toggle
	let showSoldAssets = false;
	let initialLoadDone = false;

	// Price fetching
	let prices: Map<string, { priceEur: number; fetchedAt: Date | null; error?: string }> = new Map();
	let fetchingPrices = false;

	// Yahoo symbol resolution
	let resolvingSymbols: Set<string> = new Set();
	let yahooSymbolsMap: Map<string, { selected: string | null; symbols: YahooSymbol[] }> = new Map();

	// Edit modal state - consolidated for all asset fields including Yahoo symbol
	let editingAsset: AssetWithHolding | null = null;
	let loadingSymbols = false;
	let manualSymbolInput = '';

	// Auto-refresh settings modal
	let showAutoRefreshSettings = false;
	let autoRefreshIntervalMinutes = DEFAULT_AUTO_REFRESH_INTERVAL_MS / 60000;
	let clearingHistoricalData = false;
	let clearHistoricalDataResult: { success: boolean; message: string } | null = null;

	// Per-asset historical data clearing
	let clearingAssetHistoricalData = false;
	let clearAssetHistoricalDataResult: { success: boolean; message: string } | null = null;

	// Chart modal state
	let chartAsset: AssetWithHolding | null = null;
	let chartData: LineData<Time>[] = [];
	let chartLoading = false;
	let chartError: string | null = null;
	let chartContainer: HTMLDivElement | undefined;
	let chart: IChartApi | null = null;
	let lineSeries: ISeriesApi<'Line'> | null = null;
	let chartMode: 'daily' | 'intraday' = 'daily';

	onMount(async () => {
		// Start auto-refresh
		autoRefresh.start();
		autoRefreshIntervalMinutes = $autoRefresh.intervalMs / 60000;
		await loadAssets();
		initialLoadDone = true;
		// Auto-fetch prices on load
		await fetchAllPrices();
	});

	onDestroy(() => {
		// Store handles cleanup, but we could stop here if needed
	});

	async function loadAssets() {
		loading = true;
		error = null;
		try {
			assets = await trpc.assets.listWithHoldings.query({ includeSold: showSoldAssets });
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to load assets';
		} finally {
			loading = false;
		}
	}

	// Reload when showSoldAssets changes (only after initial load)
	// Using a separate variable to track the previous value
	let prevShowSoldAssets: boolean | null = null;
	$: if (browser && initialLoadDone) {
		if (prevShowSoldAssets !== null && prevShowSoldAssets !== showSoldAssets) {
			loadAssets();
		}
		prevShowSoldAssets = showSoldAssets;
	}

	async function fetchAllPrices() {
		fetchingPrices = true;
		try {
			const result = await trpc.oracle.getAllPrices.query();
			prices = new Map();
			for (const p of result.prices) {
				prices.set(p.isin, { 
					priceEur: p.priceEur, 
					fetchedAt: p.fetchedAt ? new Date(p.fetchedAt) : null,
					error: p.error 
				});
			}
			prices = prices; // Trigger reactivity
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to fetch prices';
		} finally {
			fetchingPrices = false;
		}
	}

	// Reload prices when auto-refresh completes
	let prevLastRefreshAt: Date | null = null;
	$: if (browser && $autoRefresh.lastRefreshAt && prevLastRefreshAt !== $autoRefresh.lastRefreshAt) {
		prevLastRefreshAt = $autoRefresh.lastRefreshAt;
		if (initialLoadDone) {
			fetchAllPrices();
		}
	}

	// Update prices in real-time from server events
	$: if (browser && $serverEvents.lastEvent?.type === 'price_update') {
		const event = $serverEvents.lastEvent;
		const existing = prices.get(event.isin);
		// Only update if this is newer than what we have
		if (!existing || !existing.fetchedAt || new Date(event.fetchedAt) > existing.fetchedAt) {
			prices.set(event.isin, {
				priceEur: event.priceEur,
				fetchedAt: new Date(event.fetchedAt),
				error: undefined
			});
			prices = prices; // Trigger reactivity
		}
	}

	// Helper to determine price staleness
	function getPriceAge(fetchedAt: Date | null): { label: string; isStale: boolean; isVeryStale: boolean } {
		if (!fetchedAt) return { label: 'Unknown', isStale: true, isVeryStale: true };
		
		const ageMs = Date.now() - fetchedAt.getTime();
		const ageMinutes = Math.floor(ageMs / 60000);
		const ageHours = Math.floor(ageMinutes / 60);
		
		if (ageMinutes < 1) {
			return { label: 'Just now', isStale: false, isVeryStale: false };
		} else if (ageMinutes < 60) {
			return { label: `${ageMinutes}m ago`, isStale: ageMinutes > 30, isVeryStale: false };
		} else if (ageHours < 24) {
			return { label: `${ageHours}h ago`, isStale: true, isVeryStale: ageHours > 6 };
		} else {
			const ageDays = Math.floor(ageHours / 24);
			return { label: `${ageDays}d ago`, isStale: true, isVeryStale: true };
		}
	}

	async function resolveYahooSymbol(isin: string) {
		resolvingSymbols.add(isin);
		resolvingSymbols = resolvingSymbols;
		error = null;
		try {
			const result = await trpc.oracle.resolveYahooSymbols.mutate({ isin });
			yahooSymbolsMap.set(isin, {
				selected: result.selectedSymbol,
				symbols: result.symbols
			});
			yahooSymbolsMap = yahooSymbolsMap;
			// Reload assets to get updated yahooSymbol
			await loadAssets();
			// Update editingAsset if we're editing this one
			if (editingAsset?.isin === isin) {
				const updated = assets.find(a => a.isin === isin);
				if (updated) editingAsset = { ...updated };
			}
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to resolve Yahoo symbol';
		} finally {
			resolvingSymbols.delete(isin);
			resolvingSymbols = resolvingSymbols;
		}
	}

	async function resolveAllSymbols() {
		const assetsWithoutSymbol = assets.filter(a => !a.yahooSymbol);
		for (const asset of assetsWithoutSymbol) {
			await resolveYahooSymbol(asset.isin);
			// Small delay to avoid rate limiting
			await new Promise(resolve => setTimeout(resolve, 500));
		}
	}

	async function openEditModal(asset: AssetWithHolding) {
		editingAsset = { ...asset };
		manualSymbolInput = '';
		clearAssetHistoricalDataResult = null;
		loadingSymbols = true;
		try {
			const result = await trpc.oracle.getYahooSymbols.query({ isin: asset.isin });
			yahooSymbolsMap.set(asset.isin, {
				selected: result.selectedSymbol,
				symbols: result.symbols
			});
			yahooSymbolsMap = yahooSymbolsMap;
		} catch (err) {
			// No symbols yet, that's ok
		} finally {
			loadingSymbols = false;
		}
	}

	async function selectYahooSymbol(isin: string, symbol: string | null) {
		try {
			await trpc.oracle.setYahooSymbol.mutate({ isin, symbol });
			const current = yahooSymbolsMap.get(isin);
			if (current) {
				yahooSymbolsMap.set(isin, { ...current, selected: symbol });
				yahooSymbolsMap = yahooSymbolsMap;
			}
			await loadAssets();
			// Update editingAsset
			if (editingAsset?.isin === isin) {
				const updated = assets.find(a => a.isin === isin);
				if (updated) editingAsset = { ...updated };
			}
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to set symbol';
		}
	}

	async function setManualSymbol() {
		if (!editingAsset || !manualSymbolInput.trim()) return;
		await selectYahooSymbol(editingAsset.isin, manualSymbolInput.trim());
		manualSymbolInput = '';
	}

	async function saveAsset() {
		if (!editingAsset) return;
		saving = true;
		try {
			await trpc.assets.update.mutate({
				isin: editingAsset.isin,
				ticker: editingAsset.ticker,
				name: editingAsset.name,
				assetType: editingAsset.assetType
			});
			editingAsset = null;
			await loadAssets();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to save';
		} finally {
			saving = false;
		}
	}

	function closeEditModal() {
		editingAsset = null;
		manualSymbolInput = '';
	}

	function formatCurrency(value: number): string {
		return value.toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });
	}

	function getTotalValue(): number {
		let total = 0;
		for (const asset of assets) {
			const price = prices.get(asset.isin);
			if (price && !price.error) {
				total += price.priceEur * asset.quantity;
			}
		}
		return total;
	}

	function getYahooFinanceUrl(symbol: string): string {
		return `https://finance.yahoo.com/quote/${encodeURIComponent(symbol)}`;
	}

	$: assetsWithoutSymbol = assets.filter(a => !a.yahooSymbol);
	$: editingSymbolData = editingAsset ? yahooSymbolsMap.get(editingAsset.isin) : null;

	// Chart functions
	async function openChart(asset: AssetWithHolding) {
		if (!asset.yahooSymbol) {
			error = 'No Yahoo symbol set for this asset. Resolve symbols first.';
			return;
		}

		chartAsset = asset;
		chartMode = 'daily';
		await loadChartData();
	}

	async function loadChartData() {
		if (!chartAsset) return;

		chartLoading = true;
		chartError = null;
		chartData = [];

		// Clean up any existing chart
		if (chart) {
			chart.remove();
			chart = null;
			lineSeries = null;
		}

		try {
			if (chartMode === 'daily') {
				// Fetch 1 year of data from cache
				const oneYearAgo = new Date();
				oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

				const result = await trpc.oracle.getHistoricalPrices.query({
					isin: chartAsset.isin,
					startDate: oneYearAgo.toISOString().split('T')[0]
				});

				// Convert to lightweight-charts format (use adjusted close for accurate history)
				chartData = result.candles.map((c) => ({
					time: c.date as Time,
					value: c.adjClose
				}));

				if (chartData.length === 0) {
					chartError = 'No historical data yet. Background sync will populate this.';
				}
			} else {
				// Intraday mode - fetch from cache
				const result = await trpc.oracle.getIntradayPrices.query({
					isin: chartAsset.isin
				});

				// Convert to lightweight-charts format (timestamps as Time)
				chartData = result.candles.map((c) => ({
					time: c.timestamp as Time,
					value: c.close
				}));

				if (chartData.length === 0) {
					chartError = 'No intraday data yet. Background sync will populate this.';
				}
			}
		} catch (err) {
			chartError = err instanceof Error ? err.message : 'Failed to load chart data';
		} finally {
			chartLoading = false;
		}

		// Wait for DOM update then initialize chart
		await tick();
		initializeChart();
	}

	async function switchChartMode(mode: 'daily' | 'intraday') {
		if (chartMode === mode) return;
		chartMode = mode;
		await loadChartData();
	}

	function initializeChart() {
		if (!chartContainer || chartData.length === 0 || chartLoading) return;

		// Clean up existing chart
		if (chart) {
			chart.remove();
			chart = null;
			lineSeries = null;
		}

		// Create new chart
		chart = createChart(chartContainer, {
			width: chartContainer.clientWidth,
			height: 400,
			layout: {
				background: { color: '#ffffff' },
				textColor: '#333'
			},
			grid: {
				vertLines: { color: '#e0e0e0' },
				horzLines: { color: '#e0e0e0' }
			},
			timeScale: {
				borderColor: '#ccc',
				// Show time for intraday charts
				timeVisible: chartMode === 'intraday',
				secondsVisible: false
			},
			rightPriceScale: {
				borderColor: '#ccc'
			}
		});

		// Add line series
		lineSeries = chart.addSeries(LineSeries, {
			color: chartMode === 'intraday' ? '#059669' : '#2563eb',
			lineWidth: 2,
			priceFormat: {
				type: 'price',
				precision: 2,
				minMove: 0.01
			}
		});

		lineSeries?.setData(chartData);
		chart.timeScale().fitContent();

		// Handle resize
		const handleResize = () => {
			if (chart && chartContainer) {
				chart.applyOptions({ width: chartContainer.clientWidth });
			}
		};
		window.addEventListener('resize', handleResize);
	}

	function closeChart() {
		if (chart) {
			chart.remove();
			chart = null;
			lineSeries = null;
		}
		chartAsset = null;
		chartData = [];
		chartError = null;
		chartMode = 'daily';
	}

	async function clearHistoricalData() {
		if (!confirm('This will delete all historical price data and force a complete re-sync.\n\nContinue?')) {
			return;
		}

		clearingHistoricalData = true;
		clearHistoricalDataResult = null;

		try {
			const result = await trpc.oracle.clearAllHistoricalData.mutate();
			clearHistoricalDataResult = {
				success: true,
				message: `Cleared ${result.dailyPricesDeleted} daily prices, ${result.intradayPricesDeleted} intraday prices, ${result.dividendsDeleted} dividends`
			};
		} catch (err) {
			clearHistoricalDataResult = {
				success: false,
				message: err instanceof Error ? err.message : 'Failed to clear data'
			};
		} finally {
			clearingHistoricalData = false;
		}
	}

	async function clearAssetHistoricalData(isin: string) {
		if (!confirm('This will delete historical price data for this asset and force a re-sync.\n\nUse this after changing the Yahoo symbol.\n\nContinue?')) {
			return;
		}

		clearingAssetHistoricalData = true;
		clearAssetHistoricalDataResult = null;

		try {
			const result = await trpc.oracle.clearHistoricalDataForAsset.mutate({ isin });
			clearAssetHistoricalDataResult = {
				success: true,
				message: `Cleared ${result.dailyPricesDeleted} daily, ${result.intradayPricesDeleted} intraday, ${result.dividendsDeleted} dividends`
			};
		} catch (err) {
			clearAssetHistoricalDataResult = {
				success: false,
				message: err instanceof Error ? err.message : 'Failed to clear data'
			};
		} finally {
			clearingAssetHistoricalData = false;
		}
	}
</script>

<div class="min-h-screen bg-gray-50">
	<header class="bg-white shadow">
		<div class="mx-auto max-w-7xl px-4 py-6">
			<div class="flex items-center justify-between">
				<div class="flex items-center gap-4">
					<a href="/" class="text-gray-500 hover:text-gray-700">&larr; Back</a>
					<h1 class="text-3xl font-bold text-gray-900">Assets</h1>
				</div>
				<div class="flex items-center gap-4">
					<!-- WebSocket connection status -->
					<div
						class="flex items-center gap-1.5 text-xs {$isConnected ? 'text-green-600' : 'text-gray-400'}"
						title={$isConnected ? 'Real-time updates connected' : 'Real-time updates disconnected'}
					>
						<span class="relative flex h-2 w-2">
							{#if $isConnected}
								<span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-green-400 opacity-75"></span>
							{/if}
							<span class="relative inline-flex h-2 w-2 rounded-full {$isConnected ? 'bg-green-500' : 'bg-gray-300'}"></span>
						</span>
						<span class="hidden sm:inline">Live</span>
					</div>

					<!-- Server sync progress indicator -->
					{#if $syncProgress}
						<div class="flex items-center gap-2 rounded-lg border border-blue-200 bg-blue-50 px-3 py-1.5 text-sm text-blue-700">
							<div class="h-4 w-4 animate-spin rounded-full border-2 border-blue-600 border-r-transparent"></div>
							<span>
								{$syncProgress.job === 'price' ? 'Prices' : 'Historical'}: {$syncProgress.done}/{$syncProgress.total}
								{#if $syncProgress.currentTicker}
									<span class="text-blue-500 font-mono text-xs ml-1">({$syncProgress.currentTicker})</span>
								{/if}
								{#if $syncProgress.errors > 0}
									<span class="text-red-500 ml-1">({$syncProgress.errors} errors)</span>
								{/if}
							</span>
						</div>
					{/if}

					<!-- Auto-refresh status indicator -->
					<button
						onclick={() => (showAutoRefreshSettings = true)}
						class="flex items-center gap-2 rounded-lg border px-3 py-1.5 text-sm transition-colors {$autoRefresh.enabled
							? 'border-green-200 bg-green-50 text-green-700 hover:bg-green-100'
							: 'border-gray-200 bg-gray-50 text-gray-500 hover:bg-gray-100'}"
						title="Auto-refresh settings"
					>
						{#if $autoRefresh.enabled}
							<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
							</svg>
							<span>Auto</span>
						{:else}
							<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z" />
							</svg>
							<span>Paused</span>
						{/if}
					</button>

					<div class="flex gap-2">
						{#if assetsWithoutSymbol.length > 0}
							<button
								onclick={resolveAllSymbols}
								disabled={resolvingSymbols.size > 0}
								class="rounded bg-yellow-500 px-4 py-2 text-white hover:bg-yellow-600 disabled:opacity-50"
							>
								{resolvingSymbols.size > 0 ? `Resolving (${resolvingSymbols.size})...` : `Resolve All (${assetsWithoutSymbol.length})`}
							</button>
						{/if}
						<button
							onclick={fetchAllPrices}
							disabled={fetchingPrices || assets.length === 0}
							class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
						>
							{fetchingPrices ? 'Fetching...' : 'Fetch Prices'}
						</button>
					</div>
				</div>
			</div>
			<div class="mt-3 flex items-center justify-between">
				<div class="flex items-center gap-4">
					{#if prices.size > 0}
						<p class="text-lg text-gray-600">
							Total Value: <span class="font-semibold">{formatCurrency(getTotalValue())}</span>
						</p>
					{/if}
				</div>
				<label class="flex items-center gap-2 text-sm text-gray-600">
					<input
						type="checkbox"
						bind:checked={showSoldAssets}
						class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
					/>
					Show sold assets (qty = 0)
				</label>
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

		{#if assetsWithoutSymbol.length > 0}
			<div class="mb-6 rounded-lg bg-yellow-50 border border-yellow-200 p-4">
				<p class="text-yellow-800 font-medium">
					{assetsWithoutSymbol.length} asset{assetsWithoutSymbol.length !== 1 ? 's' : ''} need Yahoo symbol resolution
				</p>
				<p class="text-sm text-yellow-700 mt-1">
					Click "Resolve All" or edit individual assets to enable price fetching.
				</p>
			</div>
		{/if}

		<!-- Sync Queue Panel -->
		{#if $syncQueue}
			{@const items = Array.from($syncQueue.items.values())}
			{@const doneCount = items.filter(i => i.status === 'done' || i.status === 'error').length}
			{@const errorCount = items.filter(i => i.status === 'error').length}
			{@const currentItem = items.find(i => i.status === 'syncing')}
			<div class="mb-6 rounded-lg bg-blue-50 border border-blue-200 p-4">
				<div class="flex items-center justify-between mb-3">
					<div class="flex items-center gap-2">
						<div class="h-4 w-4 animate-spin rounded-full border-2 border-blue-500 border-r-transparent"></div>
						<span class="font-medium text-blue-800">
							{$syncQueue.job === 'price' ? 'Price Sync' : 'Historical Sync'} in Progress
						</span>
					</div>
					<div class="flex items-center gap-3">
						<span class="text-sm text-blue-700">
							{doneCount}/{items.length} completed
							{#if errorCount > 0}
								<span class="text-red-600">({errorCount} errors)</span>
							{/if}
						</span>
						<button
							onclick={() => serverEvents.dismissSyncQueue()}
							class="text-blue-600 hover:text-blue-800 text-sm"
							title="Dismiss"
						>
							✕
						</button>
					</div>
				</div>

				<!-- Progress bar -->
				<div class="h-2 bg-blue-200 rounded-full overflow-hidden mb-3">
					<div
						class="h-full bg-blue-500 transition-all duration-300"
						style="width: {items.length > 0 ? (doneCount / items.length) * 100 : 0}%"
					></div>
				</div>

				<!-- Current item -->
				{#if currentItem}
					<p class="text-sm text-blue-700 mb-2">
						Currently syncing: <span class="font-medium">{currentItem.name}</span> ({currentItem.ticker})
					</p>
				{/if}

				<!-- Item list - collapsible -->
				<details class="mt-2">
					<summary class="text-sm text-blue-600 cursor-pointer hover:text-blue-800">
						Show details
					</summary>
					<div class="mt-2 max-h-48 overflow-y-auto">
						<div class="grid gap-1">
							{#each items as item}
								{@const st = item.subTasks}
								<div class="flex items-center gap-2 text-sm py-1 px-2 rounded {
									item.status === 'syncing' ? 'bg-blue-100' :
									item.status === 'done' ? 'bg-green-50' :
									item.status === 'error' ? 'bg-red-50' : 'bg-gray-50'
								}">
									<!-- Overall status icon -->
									{#if item.status === 'pending'}
										<span class="text-gray-400 w-4">○</span>
									{:else if item.status === 'syncing'}
										<div class="h-3 w-3 animate-spin rounded-full border-2 border-blue-500 border-r-transparent"></div>
									{:else if item.status === 'done'}
										<span class="text-green-500 w-4">✓</span>
									{:else if item.status === 'error'}
										<span class="text-red-500 w-4">✗</span>
									{/if}

									<!-- Name and ticker -->
									<span class="flex-1 truncate {item.status === 'pending' ? 'text-gray-500' : 'text-gray-700'}">
										{item.name}
									</span>
									<span class="text-xs text-gray-400 font-mono mr-2">{item.ticker}</span>

									<!-- Sub-task indicators -->
									{#if st}
										<div class="flex items-center gap-1 text-xs">
											<!-- Price -->
											<span class="px-1 py-0.5 rounded {
												st.price === 'running' ? 'bg-blue-200 text-blue-700' :
												st.price === 'done' ? 'bg-green-200 text-green-700' :
												st.price === 'error' ? 'bg-red-200 text-red-700' :
												st.price === 'skipped' ? 'bg-gray-100 text-gray-400' : 'bg-gray-100 text-gray-500'
											}" title="Price">
												{#if st.price === 'running'}
													<span class="inline-block animate-pulse">P</span>
												{:else}
													P
												{/if}
											</span>
											<!-- Historical -->
											<span class="px-1 py-0.5 rounded {
												st.historical === 'running' ? 'bg-blue-200 text-blue-700' :
												st.historical === 'done' ? 'bg-green-200 text-green-700' :
												st.historical === 'error' ? 'bg-red-200 text-red-700' :
												st.historical === 'skipped' ? 'bg-gray-100 text-gray-400 line-through' : 'bg-gray-100 text-gray-500'
											}" title="Historical">
												{#if st.historical === 'running'}
													<span class="inline-block animate-pulse">H</span>
												{:else}
													H
												{/if}
											</span>
											<!-- Intraday -->
											<span class="px-1 py-0.5 rounded {
												st.intraday === 'running' ? 'bg-blue-200 text-blue-700' :
												st.intraday === 'done' ? 'bg-green-200 text-green-700' :
												st.intraday === 'error' ? 'bg-red-200 text-red-700' :
												st.intraday === 'skipped' ? 'bg-gray-100 text-gray-400 line-through' : 'bg-gray-100 text-gray-500'
											}" title="Intraday">
												{#if st.intraday === 'running'}
													<span class="inline-block animate-pulse">I</span>
												{:else}
													I
												{/if}
											</span>
										</div>
									{/if}

									<!-- Error message -->
									{#if item.error}
										<span class="text-xs text-red-600 truncate max-w-32" title={item.error}>
											{item.error}
										</span>
									{/if}
								</div>
							{/each}
						</div>
					</div>
				</details>
			</div>
		{/if}

		{#if loading}
			<div class="text-center py-12">
				<div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-blue-600 border-r-transparent"></div>
				<p class="mt-4 text-gray-600">Loading assets...</p>
			</div>
		{:else if assets.length === 0}
			<div class="text-center py-12">
				<p class="text-gray-500">No assets yet.</p>
				<a href="/import" class="mt-4 inline-block rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">
					Import Orders
				</a>
			</div>
		{:else}
			<div class="rounded-lg bg-white shadow overflow-hidden">
				<table class="w-full">
					<thead class="bg-gray-50">
						<tr>
							<th class="px-4 py-3 text-left text-sm font-semibold text-gray-900">Asset</th>
							<th class="px-4 py-3 text-left text-sm font-semibold text-gray-900">ISIN</th>
							<th class="px-4 py-3 text-left text-sm font-semibold text-gray-900">Broker Ticker</th>
							<th class="px-4 py-3 text-left text-sm font-semibold text-gray-900">Yahoo Symbol</th>
							<th class="px-4 py-3 text-left text-sm font-semibold text-gray-900">Type</th>
							<th class="px-4 py-3 text-right text-sm font-semibold text-gray-900">Qty</th>
							<th class="px-4 py-3 text-right text-sm font-semibold text-gray-900">Price</th>
							<th class="px-4 py-3 text-right text-sm font-semibold text-gray-900">Value</th>
							<th class="px-4 py-3 text-right text-sm font-semibold text-gray-900">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-gray-200">
						{#each assets as asset}
							{@const price = prices.get(asset.isin)}
							{@const isResolving = resolvingSymbols.has(asset.isin)}
							{@const isSyncing = asset.yahooSymbol === $currentlySyncingTicker}
							{@const justUpdated = $recentlyUpdated.has(asset.isin)}
							<tr class="hover:bg-gray-50 transition-colors duration-300 {justUpdated ? 'bg-green-50' : ''}">
								<td class="px-4 py-3">
									<div class="font-medium text-gray-900">{asset.name}</div>
								</td>
								<td class="px-4 py-3 font-mono text-xs text-gray-500">{asset.isin}</td>
								<td class="px-4 py-3 text-gray-600">{asset.ticker}</td>
								<td class="px-4 py-3">
									{#if isResolving}
										<span class="text-yellow-600 text-sm">Resolving...</span>
									{:else if asset.yahooSymbol}
										<div class="flex items-center gap-1">
											{#if isSyncing}
												<div class="h-3 w-3 animate-spin rounded-full border-2 border-blue-500 border-r-transparent" title="Syncing..."></div>
											{/if}
											<span class="text-sm font-medium text-gray-900">{asset.yahooSymbol}</span>
											<a
												href={getYahooFinanceUrl(asset.yahooSymbol)}
												target="_blank"
												rel="noopener noreferrer"
												class="text-gray-400 hover:text-blue-600"
												title="View on Yahoo Finance"
											>
												<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
												</svg>
											</a>
										</div>
									{:else}
										<span class="text-gray-400 text-sm">Not set</span>
									{/if}
								</td>
								<td class="px-4 py-3">
									<span class="inline-flex rounded-full bg-gray-100 px-2 py-1 text-xs font-medium text-gray-600 capitalize">
										{asset.assetType}
									</span>
								</td>
								<td class="px-4 py-3 text-right text-gray-900">{asset.quantity}</td>
								<td class="px-4 py-3 text-right">
									{#if isSyncing}
										<div class="flex items-center justify-end gap-1">
											<div class="h-3 w-3 animate-spin rounded-full border-2 border-blue-500 border-r-transparent"></div>
											<span class="text-blue-600 text-xs">Fetching...</span>
										</div>
									{:else if !asset.yahooSymbol}
										<span class="text-gray-400 text-xs">No symbol</span>
									{:else if price?.error}
										<span class="text-red-500 text-xs" title={price.error}>Error</span>
									{:else if price}
										{@const age = getPriceAge(price.fetchedAt)}
										<div class="flex flex-col items-end">
											<div class="flex items-center gap-1">
												{#if justUpdated}
													<svg class="w-3 h-3 text-green-500" fill="currentColor" viewBox="0 0 20 20">
														<path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
													</svg>
												{/if}
												<span class="text-gray-900 {justUpdated ? 'font-semibold text-green-700' : ''}">{formatCurrency(price.priceEur)}</span>
											</div>
											<span
												class="text-xs {age.isVeryStale ? 'text-red-500' : age.isStale ? 'text-yellow-600' : 'text-green-600'}"
												title={price.fetchedAt ? price.fetchedAt.toLocaleString() : 'Unknown'}
											>
												{age.label}
											</span>
										</div>
									{:else}
										<span class="text-gray-400">-</span>
									{/if}
								</td>
								<td class="px-4 py-3 text-right">
									{#if price && !price.error}
										<span class="font-medium text-gray-900">
											{formatCurrency(price.priceEur * asset.quantity)}
										</span>
									{:else}
										<span class="text-gray-400">-</span>
									{/if}
								</td>
								<td class="px-4 py-3 text-right">
									<div class="flex items-center justify-end gap-2">
										{#if asset.yahooSymbol}
											<button
												onclick={() => openChart(asset)}
												class="text-green-600 hover:text-green-800 text-sm"
												title="View price chart"
											>
												Chart
											</button>
										{/if}
										<button
											onclick={() => openEditModal(asset)}
											class="text-blue-600 hover:text-blue-800 text-sm"
										>
											Edit
										</button>
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}

	</main>
</div>

<!-- Consolidated Edit Modal -->
{#if editingAsset}
	<div class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
		<div class="bg-white rounded-lg shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
			<div class="p-6">
				<h2 class="text-xl font-semibold text-gray-900">Edit Asset</h2>
				<p class="mt-1 text-sm text-gray-500 font-mono">{editingAsset.isin}</p>

				<div class="mt-6 space-y-5">
					<!-- Basic Info Section -->
					<div class="space-y-4">
						<label class="block">
							<span class="text-sm font-medium text-gray-700">Name</span>
							<input
								type="text"
								bind:value={editingAsset.name}
								class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
							/>
						</label>

						<label class="block">
							<span class="text-sm font-medium text-gray-700">Broker Ticker</span>
							<input
								type="text"
								bind:value={editingAsset.ticker}
								class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
							/>
							<p class="mt-1 text-xs text-gray-500">Original ticker from your broker</p>
						</label>

						<label class="block">
							<span class="text-sm font-medium text-gray-700">Type</span>
							<select
								bind:value={editingAsset.assetType}
								class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
							>
								<option value="stock">Stock</option>
								<option value="etf">ETF</option>
								<option value="bond">Bond</option>
								<option value="fund">Fund</option>
								<option value="commodity">Commodity</option>
								<option value="other">Other</option>
							</select>
							<p class="mt-1 text-xs text-gray-500">Used for concentration rules (e.g., "no single stock > 5%")</p>
						</label>
					</div>

					<!-- Yahoo Symbol Section -->
					<div class="pt-4 border-t">
						<div class="flex items-center justify-between mb-3">
							<span class="text-sm font-medium text-gray-700">Yahoo Finance Symbol</span>
							{#if editingAsset.yahooSymbol}
								<a
									href={getYahooFinanceUrl(editingAsset.yahooSymbol)}
									target="_blank"
									rel="noopener noreferrer"
									class="text-sm text-blue-600 hover:text-blue-800 flex items-center gap-1"
								>
									View on Yahoo
									<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
									</svg>
								</a>
							{/if}
						</div>

						{#if loadingSymbols}
							<div class="py-4 text-center">
								<div class="inline-block h-5 w-5 animate-spin rounded-full border-2 border-solid border-blue-600 border-r-transparent"></div>
								<span class="ml-2 text-sm text-gray-500">Loading symbols...</span>
							</div>
						{:else}
							<div class="space-y-3">
								<!-- Current symbol -->
								<div class="flex items-center gap-2 p-2 bg-gray-50 rounded">
									<span class="text-sm text-gray-600">Current:</span>
									<span class="text-sm font-medium">{editingAsset.yahooSymbol ?? 'Not set'}</span>
								</div>

								<!-- Available symbols from Yahoo -->
								{#if editingSymbolData && editingSymbolData.symbols.length > 0}
									<div>
										<p class="text-xs text-gray-500 mb-2">Select from available exchanges:</p>
										<div class="space-y-1.5 max-h-40 overflow-y-auto">
											{#each editingSymbolData.symbols as symbol}
												<button
													onclick={() => selectYahooSymbol(editingAsset!.isin, symbol.symbol)}
													class="w-full text-left px-3 py-2 rounded text-sm border transition-colors {editingAsset.yahooSymbol === symbol.symbol 
														? 'border-blue-500 bg-blue-50 text-blue-900' 
														: 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'}"
												>
													<div class="flex items-center justify-between">
														<span class="font-medium">{symbol.symbol}</span>
														<span class="text-xs text-gray-500">{symbol.exchange ?? ''}</span>
													</div>
													{#if symbol.exchangeDisplay}
														<p class="text-xs text-gray-500">{symbol.exchangeDisplay}</p>
													{/if}
												</button>
											{/each}
										</div>
									</div>
								{/if}

								<!-- Manual entry -->
								<div>
									<p class="text-xs text-gray-500 mb-2">Or enter manually:</p>
									<div class="flex gap-2">
										<input
											type="text"
											bind:value={manualSymbolInput}
											placeholder="e.g., AAPL"
											class="flex-1 rounded border-gray-300 text-sm"
										/>
										<button
											onclick={setManualSymbol}
											disabled={!manualSymbolInput.trim()}
											class="rounded bg-gray-100 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-200 disabled:opacity-50"
										>
											Set
										</button>
									</div>
								</div>

								<!-- Resolve button -->
								<button
									onclick={() => resolveYahooSymbol(editingAsset!.isin)}
									disabled={resolvingSymbols.has(editingAsset.isin)}
									class="text-sm text-blue-600 hover:text-blue-800 disabled:opacity-50"
								>
									{#if resolvingSymbols.has(editingAsset.isin)}
										Resolving...
									{:else if editingSymbolData && editingSymbolData.symbols.length > 0}
										Refresh from Yahoo
									{:else}
										Resolve from Yahoo
									{/if}
								</button>

								<!-- Clear historical data for this asset -->
								{#if editingAsset.yahooSymbol}
									<div class="pt-3 mt-3 border-t">
										<p class="text-xs text-gray-500 mb-2">
											Clear historical data after changing symbol:
										</p>
										<button
											onclick={() => clearAssetHistoricalData(editingAsset!.isin)}
											disabled={clearingAssetHistoricalData}
											class="text-sm text-red-600 hover:text-red-800 disabled:opacity-50"
										>
											{clearingAssetHistoricalData ? 'Clearing...' : 'Clear Historical Data'}
										</button>
										{#if clearAssetHistoricalDataResult}
											<p class="mt-1 text-xs {clearAssetHistoricalDataResult.success ? 'text-green-600' : 'text-red-600'}">
												{clearAssetHistoricalDataResult.message}
											</p>
										{/if}
									</div>
								{/if}
							</div>
						{/if}
					</div>
				</div>

				<div class="mt-6 pt-4 border-t flex justify-end gap-3">
					<button
						onclick={closeEditModal}
						class="rounded bg-gray-100 px-4 py-2 text-gray-700 hover:bg-gray-200"
					>
						Cancel
					</button>
					<button
						onclick={saveAsset}
						disabled={saving}
						class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
					>
						{saving ? 'Saving...' : 'Save'}
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}

<!-- Chart Modal -->
{#if chartAsset}
	<div class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
		<div class="bg-white rounded-lg shadow-xl w-full max-w-4xl">
			<div class="p-4 border-b flex justify-between items-center">
				<div>
					<h2 class="text-lg font-semibold text-gray-900">{chartAsset.name}</h2>
					<p class="text-sm text-gray-500">
						{chartAsset.yahooSymbol} - {chartMode === 'daily' ? '1 Year Daily (Adjusted Close)' : '5 Day Intraday (5-min)'}
					</p>
				</div>
				<div class="flex items-center gap-4">
					<!-- Chart mode toggle -->
					<div class="flex rounded-lg border border-gray-200 overflow-hidden">
						<button
							onclick={() => switchChartMode('daily')}
							disabled={chartLoading}
							class="px-3 py-1.5 text-sm font-medium transition-colors {chartMode === 'daily' 
								? 'bg-blue-600 text-white' 
								: 'bg-white text-gray-600 hover:bg-gray-50'} disabled:opacity-50"
						>
							1Y Daily
						</button>
						<button
							onclick={() => switchChartMode('intraday')}
							disabled={chartLoading}
							class="px-3 py-1.5 text-sm font-medium transition-colors {chartMode === 'intraday' 
								? 'bg-green-600 text-white' 
								: 'bg-white text-gray-600 hover:bg-gray-50'} disabled:opacity-50"
						>
							5D Intraday
						</button>
					</div>
					<button
						onclick={closeChart}
						class="text-gray-400 hover:text-gray-600 p-1"
						title="Close"
					>
						<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
						</svg>
					</button>
				</div>
			</div>
			<div class="p-4">
				{#if chartLoading}
					<div class="h-96 flex items-center justify-center">
						<div class="text-center">
							<div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid {chartMode === 'intraday' ? 'border-green-600' : 'border-blue-600'} border-r-transparent"></div>
							<p class="mt-4 text-gray-600">Loading {chartMode === 'intraday' ? 'intraday' : 'historical'} data...</p>
							<p class="text-sm text-gray-400">This may take a few seconds for the first load</p>
						</div>
					</div>
				{:else if chartError}
					<div class="h-96 flex items-center justify-center">
						<div class="text-center text-red-600">
							<p class="font-medium">Failed to load chart</p>
							<p class="text-sm mt-1">{chartError}</p>
						</div>
					</div>
				{:else if chartData.length === 0}
					<div class="h-96 flex items-center justify-center">
						<p class="text-gray-500">No data available</p>
					</div>
				{:else}
					<div bind:this={chartContainer} class="h-96 w-full"></div>
					<p class="mt-2 text-xs text-gray-400 text-center">
						{chartData.length} data points
						{#if chartMode === 'daily'}
							from {chartData[0]?.time} to {chartData[chartData.length - 1]?.time}
						{:else}
							({@const startDate = new Date((chartData[0]?.time as number) * 1000)}
							{@const endDate = new Date((chartData[chartData.length - 1]?.time as number) * 1000)}
							{startDate.toLocaleDateString()} {startDate.toLocaleTimeString()} - {endDate.toLocaleDateString()} {endDate.toLocaleTimeString()})
						{/if}
					</p>
				{/if}
			</div>
		</div>
	</div>
{/if}

<!-- Auto-Refresh Settings Modal -->
{#if showAutoRefreshSettings}
	<div class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
		<div class="bg-white rounded-lg shadow-xl w-full max-w-sm">
			<div class="p-6">
				<h2 class="text-xl font-semibold text-gray-900">Auto-Refresh Settings</h2>
				<p class="mt-1 text-sm text-gray-500">Configure automatic price updates</p>

				<div class="mt-6 space-y-5">
					<!-- Enable toggle -->
					<label class="flex items-center justify-between">
						<span class="text-sm font-medium text-gray-700">Enable auto-refresh</span>
						<button
							type="button"
							onclick={() => autoRefresh.setEnabled(!$autoRefresh.enabled)}
							class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 {$autoRefresh.enabled ? 'bg-blue-600' : 'bg-gray-200'}"
							role="switch"
							aria-checked={$autoRefresh.enabled}
							aria-label="Toggle auto-refresh"
						>
							<span
								class="pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out {$autoRefresh.enabled ? 'translate-x-5' : 'translate-x-0'}"
							></span>
						</button>
					</label>

					<!-- Interval selector -->
					<label class="block">
						<span class="text-sm font-medium text-gray-700">Refresh interval</span>
						<select
							value={autoRefreshIntervalMinutes}
							onchange={(e) => {
								const minutes = parseInt(e.currentTarget.value);
								autoRefreshIntervalMinutes = minutes;
								autoRefresh.setInterval(minutes * 60000);
							}}
							disabled={!$autoRefresh.enabled}
							class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 disabled:bg-gray-100 disabled:text-gray-500"
						>
							<option value={5}>5 minutes</option>
							<option value={10}>10 minutes</option>
							<option value={15}>15 minutes</option>
							<option value={30}>30 minutes</option>
							<option value={60}>1 hour</option>
						</select>
					</label>

					<!-- Status info -->
					<div class="rounded-lg bg-gray-50 p-3 text-sm">
						<div class="flex justify-between text-gray-600">
							<span>Status:</span>
							<span class="font-medium {$syncProgress ? 'text-green-600' : 'text-gray-900'}">
								{#if $syncProgress}
									Syncing {$syncProgress.done}/{$syncProgress.total}
								{:else if $autoRefresh.enabled}
									Idle
								{:else}
									Disabled
								{/if}
							</span>
						</div>
						<div class="mt-1 flex justify-between text-gray-600">
							<span>Connection:</span>
							<span class="font-medium {$isConnected ? 'text-green-600' : 'text-red-600'}">
								{$isConnected ? 'Connected' : 'Disconnected'}
							</span>
						</div>
						{#if $autoRefresh.lastRefreshAt}
							<div class="mt-1 flex justify-between text-gray-600">
								<span>Last trigger:</span>
								<span class="font-medium text-gray-900">
									{$autoRefresh.lastRefreshAt.toLocaleTimeString()}
								</span>
							</div>
						{/if}
						{#if $autoRefresh.nextRefreshAt && $autoRefresh.enabled}
							<div class="mt-1 flex justify-between text-gray-600">
								<span>Next trigger:</span>
								<span class="font-medium text-gray-900">
									{$autoRefresh.nextRefreshAt.toLocaleTimeString()}
								</span>
							</div>
						{/if}
						{#if $autoRefresh.error}
							<div class="mt-2 text-red-600">
								Error: {$autoRefresh.error}
							</div>
						{/if}
					</div>

					<!-- Refresh now button -->
					<button
						onclick={() => autoRefresh.refreshNow()}
						disabled={$syncProgress !== null}
						class="w-full rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
					>
						{$syncProgress ? 'Syncing...' : 'Refresh Now'}
					</button>

					<!-- Clear historical data section -->
					<div class="pt-4 border-t">
						<p class="text-xs text-gray-500 mb-2">
							Clear all cached historical data to force a fresh sync. Use this if charts show incorrect data.
						</p>
						<button
							onclick={clearHistoricalData}
							disabled={clearingHistoricalData || $syncProgress !== null}
							class="w-full rounded bg-red-600 px-4 py-2 text-white hover:bg-red-700 disabled:opacity-50"
						>
							{clearingHistoricalData ? 'Clearing...' : 'Clear Historical Data'}
						</button>
						{#if clearHistoricalDataResult}
							<p class="mt-2 text-xs {clearHistoricalDataResult.success ? 'text-green-600' : 'text-red-600'}">
								{clearHistoricalDataResult.message}
							</p>
						{/if}
					</div>
				</div>

				<div class="mt-6 pt-4 border-t flex justify-end">
					<button
						onclick={() => (showAutoRefreshSettings = false)}
						class="rounded bg-gray-100 px-4 py-2 text-gray-700 hover:bg-gray-200"
					>
						Close
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
