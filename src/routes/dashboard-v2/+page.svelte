<script lang="ts">
  import { trpc } from '$lib/trpc/client';
  import { onMount, onDestroy, tick } from 'svelte';
  import { browser } from '$app/environment';
  import { createChart, type IChartApi, type ISeriesApi, type LineData, type Time, LineSeries, type LineSeriesOptions, type DeepPartial } from 'lightweight-charts';
  import { serverEvents, recentlyUpdated, isConnected } from '$lib/stores/serverEvents';

  // Privacy mode state (persisted in localStorage)
  let privacyMode = false;

  // Persist privacy mode changes to localStorage
  function togglePrivacyMode(): void {
    privacyMode = !privacyMode;
    if (browser) {
      localStorage.setItem('privacyMode', String(privacyMode));
    }
  }

  // Portfolio list state
  let portfolios: Array<{ id: string; name: string }> = [];
  let portfoliosLoading = true;
  let portfoliosError: string | null = null;

  // Portfolio valuation state (real data from API)
  let valuation: {
    investedValueEur: number;
    cashEur: number;
    totalValueEur: number;
    totalCostBasisEur: number;
    lastSyncAt: string | null;
    sleeves: Array<{
      sleeveId: string;
      sleeveName: string;
      parentSleeveId: string | null;
      budgetPercent: number;
      totalValueEur: number;
      actualPercentInvested: number;
      status: 'ok' | 'warning';
      deltaPercent: number;
    }>;
    unassignedAssets: Array<{
      isin: string;
      ticker: string;
      name: string;
    }>;
    missingSymbolAssets: Array<{
      isin: string;
      ticker: string;
      name: string;
    }>;
    stalePriceAssets: Array<{
      isin: string;
      ticker: string;
      name: string;
      lastFetchedAt: string;
      hoursStale: number;
    }>;
    concentrationViolations: Array<{
      assetTicker: string;
      actualPercent: number;
      maxPercent: number;
    }>;
    hasAllPrices: boolean;
  } | null = null;
  let valuationLoading = false;
  let valuationError: string | null = null;

  // Historical returns state
  type PeriodReturnData = {
    absoluteReturn: number;
    percentageReturn: number;
    compoundedReturn: number;
    annualizedReturn: number;
    periodYears: number;
    comparisonDate: string;
  };
  type AssetPeriodReturn = {
    isin: string;
    ticker: string;
    returnPercent: number | null;
    absoluteReturn: number | null;
    compoundedReturn: number | null;
    annualizedReturn: number | null;
    periodYears: number | null;
    isShortHolding: boolean;
    holdingPeriodLabel: string | null;
  };
  let historicalReturns: Partial<Record<ReturnPeriod, PeriodReturnData>> = {};
  let assetPeriodReturns: Partial<Record<ReturnPeriod, Record<string, AssetPeriodReturn>>> = {};
  let historicalReturnsLoading = false;

  // Return type for period data - includes both compounded and annualized MWR
  type ReturnData = {
    absolute: number;
    percentage: number; // compounded return (legacy)
    compounded: number; // MWR compounded over period
    annualized: number; // MWR annualized (p.a.)
    periodYears: number;
  } | null;

  // Calculate returns from historical returns data
  // All periods now use MWR from the API
  function getReturns(
    _val: typeof valuation,
    histReturns: typeof historicalReturns
  ): Record<ReturnPeriod, ReturnData> {
    // Map historical returns to return data
    const mapHistoricalReturn = (period: ReturnPeriod): ReturnData => {
      const histReturn = histReturns[period];
      if (!histReturn) return null;
      return {
        absolute: histReturn.absoluteReturn,
        percentage: histReturn.compoundedReturn, // legacy
        compounded: histReturn.compoundedReturn,
        annualized: histReturn.annualizedReturn,
        periodYears: histReturn.periodYears
      };
    };

    return {
      today: mapHistoricalReturn('today'),
      '1w': mapHistoricalReturn('1w'),
      '1m': mapHistoricalReturn('1m'),
      '6m': mapHistoricalReturn('6m'),
      ytd: mapHistoricalReturn('ytd'),
      '1y': mapHistoricalReturn('1y'),
      all: mapHistoricalReturn('all')
    };
  }

  $: returns = getReturns(valuation, historicalReturns);

  // Types
  type ReturnPeriod = 'today' | '1w' | '1m' | '6m' | 'ytd' | '1y' | 'all';
  type ChartRange = '1m' | '3m' | '6m' | '1y' | 'all';
  type BandStatus = 'ok' | 'over' | 'under';

  // State
  let selectedPortfolioId: string | null = null;
  let selectedPeriod: ReturnPeriod = 'all';
  let selectedChartRange: ChartRange = '6m';
  let selectedSleeveId: string = '';
  let sortColumn: 'ticker' | 'sleeve' | 'value' | 'weight' | 'pl' | 'return' = 'value';
  let sortDirection: 'asc' | 'desc' = 'desc';

  // Chart state
  let chartContainer: HTMLDivElement | undefined;
  let chart: IChartApi | null = null;
  let investedSeries: ISeriesApi<'Line'> | null = null;
  let costBasisSeries: ISeriesApi<'Line'> | null = null;
  let chartData: { date: string; investedValue: number; costBasis: number }[] = [];
  let chartLoading = false;
  let chartError: string | null = null;

  // Track the last refresh to debounce price update refreshes
  let lastRefreshTimestamp: number = 0;
  let refreshDebounceTimer: ReturnType<typeof setTimeout> | null = null;
  const REFRESH_DEBOUNCE_MS = 500; // Wait 500ms after last price update before refreshing

  // Fetch portfolios on mount and initialize privacy mode
  onMount(async () => {
    // Initialize privacy mode from localStorage
    if (browser) {
      const stored = localStorage.getItem('privacyMode');
      if (stored !== null) {
        privacyMode = stored === 'true';
      }
    }

    // Connect to WebSocket for real-time updates
    serverEvents.connect();

    try {
      const result = await trpc.portfolios.list.query();
      portfolios = result;
      // Auto-select first portfolio if available
      if (result.length > 0 && !selectedPortfolioId) {
        selectedPortfolioId = result[0].id;
      }
    } catch (err) {
      portfoliosError = err instanceof Error ? err.message : 'Failed to load portfolios';
    } finally {
      portfoliosLoading = false;
    }
  });

  // Fetch valuation when portfolio changes
  async function loadValuation(portfolioId: string) {
    valuationLoading = true;
    valuationError = null;
    try {
      const result = await trpc.valuation.getPortfolioValuation.query({ portfolioId });
      valuation = result;
    } catch (err) {
      valuationError = err instanceof Error ? err.message : 'Failed to load portfolio data';
      valuation = null;
    } finally {
      valuationLoading = false;
    }
  }

  // Fetch historical returns for period comparison (now using MWR)
  async function loadHistoricalReturns(portfolioId: string) {
    historicalReturnsLoading = true;
    try {
      const result = await trpc.valuation.getHistoricalReturns.query({ portfolioId });
      // Map the result to our expected format
      const mapped: typeof historicalReturns = {};
      for (const [period, data] of Object.entries(result.returns)) {
        if (data) {
          mapped[period as ReturnPeriod] = {
            absoluteReturn: data.absoluteReturn,
            percentageReturn: data.percentageReturn ?? data.compoundedReturn,
            compoundedReturn: data.compoundedReturn ?? data.percentageReturn,
            annualizedReturn: data.annualizedReturn ?? data.percentageReturn,
            periodYears: data.periodYears ?? 1,
            comparisonDate: data.comparisonDate
          };
        }
      }
      historicalReturns = mapped;
      // Store per-asset returns for each period (with MWR data)
      const mappedAssetReturns: typeof assetPeriodReturns = {};
      for (const [period, assets] of Object.entries(result.assetReturns)) {
        if (assets) {
          mappedAssetReturns[period as ReturnPeriod] = {};
          for (const [isin, asset] of Object.entries(assets)) {
            mappedAssetReturns[period as ReturnPeriod]![isin] = {
              isin: asset.isin,
              ticker: asset.ticker,
              returnPercent: asset.returnPercent ?? asset.compoundedReturn ?? null,
              absoluteReturn: (asset as any).absoluteReturn ?? null,
              compoundedReturn: asset.compoundedReturn ?? asset.returnPercent ?? null,
              annualizedReturn: asset.annualizedReturn ?? null,
              periodYears: asset.periodYears ?? null,
              isShortHolding: asset.isShortHolding ?? false,
              holdingPeriodLabel: asset.holdingPeriodLabel ?? null
            };
          }
        }
      }
      assetPeriodReturns = mappedAssetReturns;
    } catch (err) {
      // Silently fail - historical returns are nice-to-have
      console.error('Failed to load historical returns:', err);
      historicalReturns = {};
      assetPeriodReturns = {};
    } finally {
      historicalReturnsLoading = false;
    }
  }

  // React to portfolio selection changes
  $: if (selectedPortfolioId) {
    loadValuation(selectedPortfolioId);
    loadChartData(selectedPortfolioId, selectedChartRange);
    loadHistoricalReturns(selectedPortfolioId);
  }

  // React to chart range changes
  $: if (selectedPortfolioId && selectedChartRange) {
    loadChartData(selectedPortfolioId, selectedChartRange);
  }

  // Load chart data from API
  async function loadChartData(portfolioId: string, range: ChartRange) {
    const isUpdate = chart !== null; // Don't show loading spinner for updates
    if (!isUpdate) {
      chartLoading = true;
    }
    chartError = null;

    try {
      const result = await trpc.valuation.getChartData.query({
        portfolioId,
        range
      });

      chartData = result.dataPoints;

      if (!result.hasData || chartData.length === 0) {
        chartError = 'No historical data available yet. Data will appear after price sync.';
      }
    } catch (err) {
      chartError = err instanceof Error ? err.message : 'Failed to load chart data';
      chartData = [];
    } finally {
      chartLoading = false;
    }

    // Wait for DOM update then initialize or update chart
    await tick();
    if (chart && investedSeries && costBasisSeries) {
      // Chart exists - just update the data
      updateChartData();
    } else {
      // No chart yet - create it
      initializeChart();
    }
  }

  // Update chart data without recreating the chart
  function updateChartData() {
    if (!investedSeries || !costBasisSeries || chartData.length === 0) return;

    const investedData: LineData<Time>[] = chartData.map(d => ({
      time: d.date as Time,
      value: d.investedValue
    }));

    const costBasisData: LineData<Time>[] = chartData.map(d => ({
      time: d.date as Time,
      value: d.costBasis
    }));

    investedSeries.setData(investedData);
    costBasisSeries.setData(costBasisData);
    chart?.timeScale().fitContent();
  }

  // Initialize lightweight-charts
  function initializeChart() {
    if (!chartContainer || chartData.length === 0 || chartLoading) return;

    // Clean up existing chart
    if (chart) {
      chart.remove();
      chart = null;
      investedSeries = null;
      costBasisSeries = null;
    }

    // Custom formatter for large numbers (e.g., 110000 -> "110k")
    const formatLargeNumber = (value: number): string => {
      if (value >= 1000000) {
        return (value / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
      }
      if (value >= 1000) {
        return (value / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
      }
      return value.toFixed(0);
    };

    // Create new chart
    chart = createChart(chartContainer, {
      width: chartContainer.clientWidth,
      height: 200,
      layout: {
        background: { color: '#ffffff' },
        textColor: '#94a3b8'
      },
      grid: {
        vertLines: { color: '#f1f5f9' },
        horzLines: { color: '#f1f5f9' }
      },
      timeScale: {
        borderColor: '#e2e8f0',
        timeVisible: false,
        secondsVisible: false
      },
      rightPriceScale: {
        borderColor: '#e2e8f0',
        visible: !privacyMode
      },
      crosshair: {
        vertLine: { labelVisible: true },
        horzLine: { labelVisible: !privacyMode }
      },
      localization: {
        priceFormatter: formatLargeNumber
      }
    });

    // Add cost basis line (gray, dashed) - add first so it's behind
    costBasisSeries = chart.addSeries(LineSeries, {
      color: '#94a3b8',
      lineWidth: 1,
      lineStyle: 2, // Dashed
      priceFormat: {
        type: 'custom',
        formatter: formatLargeNumber
      }
    } as DeepPartial<LineSeriesOptions>);

    // Add invested value line (green, solid)
    investedSeries = chart.addSeries(LineSeries, {
      color: '#16a34a',
      lineWidth: 2,
      priceFormat: {
        type: 'custom',
        formatter: formatLargeNumber
      }
    } as DeepPartial<LineSeriesOptions>);

    // Convert data to chart format
    const investedData: LineData<Time>[] = chartData.map(d => ({
      time: d.date as Time,
      value: d.investedValue
    }));

    const costBasisData: LineData<Time>[] = chartData.map(d => ({
      time: d.date as Time,
      value: d.costBasis
    }));

    costBasisSeries.setData(costBasisData);
    investedSeries.setData(investedData);

    chart.timeScale().fitContent();

    // Handle resize
    const handleResize = () => {
      if (chart && chartContainer) {
        chart.applyOptions({ width: chartContainer.clientWidth });
      }
    };
    window.addEventListener('resize', handleResize);
  }

  // Clean up chart, timers, and WebSocket on component destroy
  onDestroy(() => {
    if (chart) {
      chart.remove();
      chart = null;
    }
    // Clear any pending refresh timer
    if (refreshDebounceTimer) {
      clearTimeout(refreshDebounceTimer);
      refreshDebounceTimer = null;
    }
    // Disconnect from WebSocket (optional - keeps connection for other components)
    // serverEvents.disconnect();
  });

  // Watch for price updates and refresh data (debounced)
  $: if ($recentlyUpdated.size > 0 && selectedPortfolioId && browser) {
    // Debounce: wait for price updates to settle before refreshing
    if (refreshDebounceTimer) {
      clearTimeout(refreshDebounceTimer);
    }
    refreshDebounceTimer = setTimeout(() => {
      const now = Date.now();
      // Only refresh if enough time has passed since last refresh
      if (now - lastRefreshTimestamp > REFRESH_DEBOUNCE_MS) {
        lastRefreshTimestamp = now;
        // Refresh all dashboard data
        loadValuation(selectedPortfolioId!);
        loadHistoricalReturns(selectedPortfolioId!);
        loadChartData(selectedPortfolioId!, selectedChartRange);
      }
      refreshDebounceTimer = null;
    }, REFRESH_DEBOUNCE_MS);
  }

  // Update chart visibility when privacy mode changes
  $: if (chart && browser) {
    chart.applyOptions({
      rightPriceScale: { visible: !privacyMode },
      crosshair: { horzLine: { labelVisible: !privacyMode } }
    });
  }


  // Helper to calculate weighted average return for a sleeve (both simple and annualized)
  function calculateSleeveReturns(
    sleeveId: string,
    allHoldings: typeof holdings,
    allSleeves: NonNullable<typeof valuation>['sleeves'],
    period: ReturnPeriod
  ): { returnPercent: number | null; annualizedReturn: number | null } {
    // Get direct holdings in this sleeve
    const sleeveHoldings = allHoldings.filter(h => h.sleeveId === sleeveId);

    // Also include holdings from child sleeves
    const childSleeveIds = allSleeves
      .filter(s => s.parentSleeveId === sleeveId)
      .map(s => s.sleeveId);
    const childHoldings = allHoldings.filter(h => childSleeveIds.includes(h.sleeveId));

    const allSleeveHoldings = [...sleeveHoldings, ...childHoldings];

    if (allSleeveHoldings.length === 0) return { returnPercent: null, annualizedReturn: null };

    const totalValue = allSleeveHoldings.reduce((sum, h) => sum + h.value, 0);
    const totalCost = allSleeveHoldings.reduce((sum, h) => sum + h.costBasis, 0);

    if (totalCost === 0) return { returnPercent: null, annualizedReturn: null };

    let returnPercent: number;
    if (period === 'all') {
      // For "all" period: use aggregate cost basis return (matches portfolio calculation)
      returnPercent = ((totalValue - totalCost) / totalCost) * 100;
    } else {
      // For other periods: use value-weighted average of period-specific returns
      // (since period returns are price-based, not cost-based)
      returnPercent = allSleeveHoldings.reduce((sum, h) => {
        const weight = h.value / totalValue;
        return sum + (h.returnPercent * weight);
      }, 0);
    }

    // For annualized return, use cost-weighted average of individual annualized returns
    // (since we don't have cash flow data at sleeve level for proper XIRR)
    const holdingsWithAnnualized = allSleeveHoldings.filter(h => h.annualizedReturn !== null);
    let weightedAnnualized: number | null = null;
    if (holdingsWithAnnualized.length > 0) {
      const annualizedTotalCost = holdingsWithAnnualized.reduce((sum, h) => sum + h.costBasis, 0);
      if (annualizedTotalCost > 0) {
        weightedAnnualized = holdingsWithAnnualized.reduce((sum, h) => {
          const weight = h.costBasis / annualizedTotalCost;
          return sum + ((h.annualizedReturn ?? 0) * weight);
        }, 0);
      }
    }

    return { returnPercent, annualizedReturn: weightedAnnualized };
  }

  // Build holdings list from valuation sleeves (only assets assigned to this portfolio)
  // Note: Reactive to valuation, selectedPeriod, and assetPeriodReturns
  $: holdings = valuation ? valuation.sleeves.flatMap(sleeve =>
    (sleeve as any).directAssets?.map((asset: any) => {
      const costBasisReturn = asset.costBasisEur > 0
        ? ((asset.valueEur - asset.costBasisEur) / asset.costBasisEur) * 100
        : 0;
      const shortHoldingInfo = getAssetShortHoldingInfo(asset.isin, selectedPeriod, assetPeriodReturns);
      return {
        id: asset.isin,
        ticker: asset.ticker,
        name: asset.name,
        sleeveId: sleeve.sleeveId,
        sleeveName: sleeve.sleeveName,
        quantity: asset.quantity,
        value: asset.valueEur,
        costBasis: asset.costBasisEur, // Include cost basis for accurate return calculations
        weight: asset.percentOfInvested,
        costBasisReturn, // Store cost basis return for reference
        returnPercent: getAssetReturnPercent(asset.isin, costBasisReturn, selectedPeriod, assetPeriodReturns),
        absoluteReturn: getAssetAbsoluteReturn(asset.isin, asset.valueEur, asset.costBasisEur, selectedPeriod, assetPeriodReturns),
        annualizedReturn: getAssetAnnualizedReturn(asset.isin, selectedPeriod, assetPeriodReturns),
        isShortHolding: shortHoldingInfo.isShort,
        holdingPeriodLabel: shortHoldingInfo.label
      };
    }) ?? []
  ) : [];

  // Helper: sort sleeves hierarchically so children appear directly after their parents
  function sortSleevesHierarchically<T extends { id: string; parentId: string | null }>(sleeves: T[]): T[] {
    const result: T[] = [];
    const childrenMap = new Map<string | null, T[]>();

    // Group sleeves by parent
    for (const sleeve of sleeves) {
      const parentId = sleeve.parentId;
      if (!childrenMap.has(parentId)) {
        childrenMap.set(parentId, []);
      }
      childrenMap.get(parentId)!.push(sleeve);
    }

    // Recursive function to add sleeve and its children
    function addSleeveWithChildren(sleeve: T) {
      result.push(sleeve);
      const children = childrenMap.get(sleeve.id) ?? [];
      for (const child of children) {
        addSleeveWithChildren(child);
      }
    }

    // Start with root sleeves (parentId = null)
    const rootSleeves = childrenMap.get(null) ?? [];
    for (const root of rootSleeves) {
      addSleeveWithChildren(root);
    }

    return result;
  }

  // Derived data from valuation
  // Note: sleeves depends on holdings which depends on selectedPeriod
  $: sleeves = (() => {
    if (!valuation) return [];

    // First, map the data
    const mappedSleeves = valuation.sleeves.map(s => {
      // Calculate depth based on parent
      const depth = s.parentSleeveId ? 1 : 0;
      // Determine band status for display
      let bandStatus: BandStatus = 'ok';
      if (s.deltaPercent > 0 && s.status === 'warning') bandStatus = 'over';
      else if (s.deltaPercent < 0 && s.status === 'warning') bandStatus = 'under';

      // Calculate sleeve returns (weighted average of asset returns)
      const sleeveReturns = calculateSleeveReturns(s.sleeveId, holdings, valuation!.sleeves, selectedPeriod);

      return {
        id: s.sleeveId,
        name: s.sleeveName,
        parentId: s.parentSleeveId,
        depth,
        value: s.totalValueEur,
        actualPercent: s.actualPercentInvested,
        targetPercent: s.budgetPercent,
        bandStatus,
        deviation: Math.round(s.deltaPercent),
        returnPercent: sleeveReturns.returnPercent,
        annualizedReturn: sleeveReturns.annualizedReturn
      };
    });

    // Then sort hierarchically so children appear directly after their parents
    return sortSleevesHierarchically(mappedSleeves);
  })();

  // Helper to get asset return for the selected period
  // Uses same logic as portfolio: annualized for >= 1 year, simple for shorter
  function getAssetReturnPercent(
    isin: string,
    costBasisReturn: number,
    period: ReturnPeriod,
    periodReturnsData: typeof assetPeriodReturns
  ): number {
    const periodReturns = periodReturnsData[period];
    if (!periodReturns || !periodReturns[isin]) {
      return costBasisReturn;
    }

    const assetData = periodReturns[isin];
    const periodYears = assetData.periodYears ?? 0;

    // For "all" period: always use cost basis return (consistent with portfolio calculation)
    // For >= 1 year: use annualized price return
    // For < 1 year: use simple price return
    if (period === 'all') {
      return costBasisReturn; // Use cost basis, not price-based return
    } else if (periodYears >= 1 && assetData.annualizedReturn !== null) {
      return assetData.annualizedReturn;
    } else if (assetData.compoundedReturn !== null) {
      return assetData.compoundedReturn;
    } else if (assetData.returnPercent !== null) {
      return assetData.returnPercent;
    }
    return costBasisReturn;
  }

  // Helper to get asset annualized return
  function getAssetAnnualizedReturn(
    isin: string,
    period: ReturnPeriod,
    periodReturnsData: typeof assetPeriodReturns
  ): number | null {
    const periodReturns = periodReturnsData[period];
    if (periodReturns && periodReturns[isin]?.annualizedReturn !== null && periodReturns[isin]?.annualizedReturn !== undefined) {
      return periodReturns[isin].annualizedReturn;
    }
    return null;
  }

  // Helper to check if asset is a short holding
  function getAssetShortHoldingInfo(
    isin: string,
    period: ReturnPeriod,
    periodReturnsData: typeof assetPeriodReturns
  ): { isShort: boolean; label: string | null } {
    const periodReturns = periodReturnsData[period];
    if (periodReturns && periodReturns[isin]) {
      return {
        isShort: periodReturns[isin].isShortHolding ?? false,
        label: periodReturns[isin].holdingPeriodLabel ?? null
      };
    }
    return { isShort: false, label: null };
  }

  // Helper to get asset absolute return (EUR) for the selected period
  function getAssetAbsoluteReturn(
    isin: string,
    value: number,
    costBasis: number,
    period: ReturnPeriod,
    periodReturnsData: typeof assetPeriodReturns
  ): number | null {
    // For "all" period: use local calculation (value - costBasis) as fallback
    // For other periods: use API-provided value
    const periodReturns = periodReturnsData[period];
    if (periodReturns && periodReturns[isin]?.absoluteReturn !== null && periodReturns[isin]?.absoluteReturn !== undefined) {
      return periodReturns[isin].absoluteReturn;
    }
    // Fallback for "all" period if API didn't provide it
    if (period === 'all' && costBasis > 0) {
      return Math.round((value - costBasis) * 100) / 100;
    }
    return null;
  }

  // Issue type with associated data for detailed view
  type Issue = {
    id: string;
    type: 'error' | 'warning' | 'allocation';
    label: string;
    detail: string;
    action: string;
    assets?: string[]; // List of affected asset tickers
  };

  // Build issues from valuation data
  function getIssues(val: typeof valuation): Issue[] {
    if (!val) return [];
    return [
      // Missing Yahoo symbols (Error - can't fetch prices at all)
      ...val.missingSymbolAssets.map(a => ({
        id: `missing-${a.isin}`,
        type: 'error' as const,
        label: `${a.ticker} missing symbol`,
        detail: `${a.name} (${a.ticker}) cannot fetch prices without a Yahoo Finance symbol.`,
        action: 'Go to Assets > Find this asset > Settings > Set Yahoo Symbol',
        assets: [a.ticker]
      })),
      // Stale prices (Warning)
      ...(val.stalePriceAssets.length > 0 ? [{
        id: 'stale-prices',
        type: 'warning' as const,
        label: `${val.stalePriceAssets.length} stale price${val.stalePriceAssets.length > 1 ? 's' : ''}`,
        detail: `These assets haven't updated in 24+ hours:\n${val.stalePriceAssets.map(a => `- ${a.ticker} (${a.hoursStale}h ago)`).join('\n')}`,
        action: 'Go to Settings > Price Sync > Check symbol mappings or trigger manual refresh',
        assets: val.stalePriceAssets.map(a => a.ticker)
      }] : []),
      // Unassigned assets (Warning)
      ...(val.unassignedAssets.length > 0 ? [{
        id: 'unassigned',
        type: 'warning' as const,
        label: `${val.unassignedAssets.length} unassigned`,
        detail: `These assets are not assigned to any sleeve:\n${val.unassignedAssets.map(a => `- ${a.ticker} (${a.name})`).join('\n')}`,
        action: 'Go to Portfolio > Sleeves > Drag assets to assign them',
        assets: val.unassignedAssets.map(a => a.ticker)
      }] : []),
      // Sleeve allocation warnings (Allocation)
      ...val.sleeves
        .filter(s => s.status === 'warning')
        .map(s => {
          const isOver = s.deltaPercent > 0;
          const actual = Math.round(s.actualPercentInvested);
          const target = Math.round(s.budgetPercent);
          const delta = Math.round(Math.abs(s.deltaPercent));
          return {
            id: `sleeve-${s.sleeveId}`,
            type: 'allocation' as const,
            label: `${s.sleeveName} ${isOver ? '+' : '-'}${delta}pp ${isOver ? 'over' : 'under'}`,
            detail: `${s.sleeveName} allocation is ${actual}% vs ${target}% target (${isOver ? '+' : '-'}${delta}pp).`,
            action: isOver
              ? `Go to Rebalance > View suggested sells to reduce ${s.sleeveName} exposure`
              : `Go to Rebalance > View suggested buys to increase ${s.sleeveName} exposure`
          };
        }),
      // Concentration violations (Allocation)
      ...val.concentrationViolations.map(v => ({
        id: `conc-${v.assetTicker}`,
        type: 'allocation' as const,
        label: `${v.assetTicker} >${Math.round(v.maxPercent)}% concentration`,
        detail: `${v.assetTicker} is ${v.actualPercent.toFixed(1)}% of portfolio, exceeding the ${v.maxPercent}% single-asset concentration limit.`,
        action: `Go to Rebalance > View suggested sells for ${v.assetTicker}, or adjust the concentration rule in Settings > Rules`,
        assets: [v.assetTicker]
      }))
    ];
  }

  $: issues = getIssues(valuation);

  // Computed
  const periodLabels: Record<ReturnPeriod, string> = {
    today: "Today's Return",
    '1w': '1W Return',
    '1m': '1M Return',
    '6m': '6M Return',
    ytd: 'YTD Return',
    '1y': '1Y Return',
    all: 'All Time Return'
  };

  // Helper: check if annualized return should be shown (periods > 1 year benefit from p.a.)
  function shouldShowAnnualized(period: ReturnPeriod, periodYears: number): boolean {
    // Show p.a. for periods over 1 year, or for 'all' regardless
    return period === 'all' || periodYears > 1;
  }

  $: currentReturn = returns[selectedPeriod];
  $: returnLabel = periodLabels[selectedPeriod];

  // Filter holdings by sleeve
  $: filteredHoldings = selectedSleeveId
    ? holdings.filter(h => {
        if (h.sleeveId === selectedSleeveId) return true;
        // Include children if parent sleeve selected
        const sleeve = sleeves.find(s => s.id === selectedSleeveId);
        if (sleeve && !sleeve.parentId) {
          // Parent sleeve - include children
          const childSleeves = sleeves.filter(s => s.parentId === selectedSleeveId);
          return childSleeves.some(cs => cs.id === h.sleeveId);
        }
        return false;
      })
    : holdings;

  // Sort holdings
  $: sortedHoldings = [...filteredHoldings].sort((a, b) => {
    let aVal: number | string | null;
    let bVal: number | string | null;

    switch (sortColumn) {
      case 'ticker': aVal = a.ticker; bVal = b.ticker; break;
      case 'sleeve': aVal = a.sleeveName || ''; bVal = b.sleeveName || ''; break;
      case 'value': aVal = a.value; bVal = b.value; break;
      case 'weight': aVal = a.weight; bVal = b.weight; break;
      case 'pl': aVal = a.absoluteReturn ?? 0; bVal = b.absoluteReturn ?? 0; break;
      case 'return': aVal = a.returnPercent; bVal = b.returnPercent; break;
    }

    if (typeof aVal === 'string') {
      return sortDirection === 'asc' ? aVal.localeCompare(bVal as string) : (bVal as string).localeCompare(aVal);
    }
    return sortDirection === 'asc' ? (aVal as number) - (bVal as number) : (bVal as number) - (aVal as number);
  });

  // Helpers
  function formatCurrency(value: number): string {
    return value.toLocaleString('de-DE', { style: 'currency', currency: 'EUR', maximumFractionDigits: 0 });
  }

  // Privacy placeholder for hidden values
  const PRIVACY_PLACEHOLDER = '•••••';

  function toggleSleeveFilter(sleeveId: string): void {
    selectedSleeveId = selectedSleeveId === sleeveId ? '' : sleeveId;
  }

  function handleSort(column: typeof sortColumn): void {
    if (sortColumn === column) {
      sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      sortColumn = column;
      sortDirection = column === 'ticker' || column === 'sleeve' ? 'asc' : 'desc';
    }
  }

  function showIssueDetails(issue: Issue): void {
    // Shows alert with issue details (will be modal in future)
    alert(`${issue.label}\n\n${issue.detail}\n\n→ ${issue.action}`);
  }
</script>

<svelte:head>
  <title>Dashboard - Bagholdr</title>
</svelte:head>

<style>
  /* Blink animation for recently updated values */
  @keyframes price-update-blink {
    0% { background-color: transparent; }
    20% { background-color: rgb(187 247 208); } /* green-200 */
    100% { background-color: transparent; }
  }

  .price-updated {
    animation: price-update-blink 1.5s ease-out;
  }
</style>

<div class="min-h-screen bg-slate-100">
  {#if portfoliosLoading}
    <!-- Loading state -->
    <div class="flex items-center justify-center min-h-[400px]">
      <div class="flex flex-col items-center gap-3">
        <div class="w-8 h-8 border-2 border-slate-300 border-t-slate-600 rounded-full animate-spin"></div>
        <span class="text-sm text-slate-500">Loading portfolios...</span>
      </div>
    </div>
  {:else if portfoliosError}
    <!-- Error state -->
    <div class="flex items-center justify-center min-h-[400px]">
      <div class="flex flex-col items-center gap-3 text-center">
        <div class="w-12 h-12 rounded-full bg-red-100 flex items-center justify-center">
          <svg class="w-6 h-6 text-red-500" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        <span class="text-sm font-medium text-slate-700">Failed to load portfolios</span>
        <span class="text-xs text-slate-500">{portfoliosError}</span>
      </div>
    </div>
  {:else if portfolios.length === 0}
    <!-- Empty state - no portfolios -->
    <div class="flex items-center justify-center min-h-[400px]">
      <div class="flex flex-col items-center gap-3 text-center">
        <div class="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center">
          <svg class="w-6 h-6 text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
          </svg>
        </div>
        <span class="text-sm font-medium text-slate-700">No portfolios found</span>
        <span class="text-xs text-slate-500">Create a portfolio to get started</span>
      </div>
    </div>
  {:else}
  <div class="mx-auto max-w-[1200px] px-6 py-6">
    <!-- Top Section -->
    <div class="rounded-xl border border-slate-200 bg-white p-5 mb-6">
      <!-- Header row with portfolio selector and sync status -->
      <div class="flex items-center justify-between mb-5">
        {#if portfolios.length > 1}
          <select
            bind:value={selectedPortfolioId}
            class="text-sm font-semibold px-3 py-1.5 pr-8 border border-slate-200 rounded-lg bg-white text-slate-900 cursor-pointer appearance-none bg-[url('data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2212%22%20height%3D%2212%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22%2364748b%22%20stroke-width%3D%222%22%3E%3Cpath%20d%3D%22M6%209l6%206%206-6%22%2F%3E%3C%2Fsvg%3E')] bg-no-repeat bg-[right_10px_center]"
          >
            {#each portfolios as portfolio}
              <option value={portfolio.id}>{portfolio.name}</option>
            {/each}
          </select>
        {:else}
          <span class="text-sm font-semibold text-slate-900">{portfolios[0]?.name}</span>
        {/if}

        <div class="flex items-center gap-3">
          <!-- Privacy mode toggle -->
          <button
            onclick={togglePrivacyMode}
            class="p-1.5 rounded-md text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
            title={privacyMode ? 'Show values' : 'Hide values'}
          >
            {#if privacyMode}
              <!-- Eye off icon -->
              <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
              </svg>
            {:else}
              <!-- Eye icon -->
              <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z" />
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            {/if}
          </button>

          <!-- Connection status -->
          <div class="flex items-center gap-1.5 text-xs text-slate-500" title={$isConnected ? 'Connected to server' : 'Disconnected from server'}>
            <span class="w-1.5 h-1.5 rounded-full {$isConnected ? 'bg-green-500' : 'bg-red-500'}"></span>
            {$isConnected ? 'Online' : 'Offline'}
          </div>
        </div>
      </div>

      <!-- Stats row -->
      <div class="flex items-end gap-10">
        <!-- Invested (primary) -->
        <div>
          <div class="text-[11px] uppercase tracking-wider text-slate-400 mb-1.5">Invested</div>
          <div class="text-[28px] font-bold tracking-tight text-slate-900 relative">
            <span class={privacyMode ? 'invisible' : ''}>{formatCurrency(valuation?.investedValueEur ?? 0)}</span>
            {#if privacyMode}<span class="absolute inset-0 flex items-center blur-[2px] select-none">{PRIVACY_PLACEHOLDER}</span>{/if}
          </div>
        </div>

        <!-- Return with period selector -->
        <div class="flex items-end gap-4">
          <div class="w-[260px]">
            <div class="text-[11px] uppercase tracking-wider text-slate-400 mb-1.5">{returnLabel}</div>
            {#if currentReturn}
              <div class="flex items-baseline gap-2">
                <span class="text-lg font-semibold tabular-nums {currentReturn.absolute >= 0 ? 'text-green-600' : 'text-red-600'} relative">
                  <span class={privacyMode ? 'invisible' : ''}>{currentReturn.absolute >= 0 ? '+' : ''}{formatCurrency(currentReturn.absolute)}</span>
                  {#if privacyMode}<span class="absolute inset-0 flex items-center blur-[2px] select-none">{PRIVACY_PLACEHOLDER}</span>{/if}
                </span>
                <span class="text-xs tabular-nums whitespace-nowrap {currentReturn.compounded >= 0 ? 'text-green-600' : 'text-red-600'}">
                  {currentReturn.compounded >= 0 ? '+' : ''}{currentReturn.compounded.toFixed(1)}%
                  {#if shouldShowAnnualized(selectedPeriod, currentReturn.periodYears)}
                    <span class="text-slate-400">({currentReturn.annualized >= 0 ? '+' : ''}{currentReturn.annualized.toFixed(1)}% p.a.)</span>
                  {/if}
                </span>
              </div>
            {:else}
              <div class="flex items-baseline gap-2">
                <span class="text-lg font-semibold text-slate-400">--</span>
                <span class="text-xs text-slate-400">N/A</span>
              </div>
            {/if}
          </div>

          <div class="flex">
            {#each ['today', '1w', '1m', '6m', 'ytd', '1y', 'all'] as period, i}
              <button
                onclick={() => selectedPeriod = period as typeof selectedPeriod}
                class="px-2 py-0.5 text-[10px] font-medium border border-slate-200 transition-colors
                  {i === 0 ? 'rounded-l' : ''}
                  {i === 6 ? 'rounded-r' : ''}
                  {i > 0 ? 'border-l-0' : ''}
                  {selectedPeriod === period ? 'bg-slate-900 text-white border-slate-900' : 'bg-white text-slate-500 hover:bg-slate-50'}"
              >
                {period === 'today' ? 'Today' : period === 'all' ? 'All' : period.toUpperCase()}
              </button>
            {/each}
          </div>
        </div>

        <!-- Spacer -->
        <div class="flex-1"></div>

        <!-- Cash (secondary) -->
        <div>
          <div class="text-[11px] uppercase tracking-wider text-slate-400 mb-1.5">Cash</div>
          <div class="text-[15px] font-semibold text-slate-500 relative">
            <span class={privacyMode ? 'invisible' : ''}>{formatCurrency(valuation?.cashEur ?? 0)}</span>
            {#if privacyMode}<span class="absolute inset-0 flex items-center blur-[2px] select-none">{PRIVACY_PLACEHOLDER}</span>{/if}
          </div>
        </div>

        <!-- Total Value (secondary) -->
        <div>
          <div class="text-[11px] uppercase tracking-wider text-slate-400 mb-1.5">Total Value</div>
          <div class="text-[15px] font-semibold text-slate-500 relative">
            <span class={privacyMode ? 'invisible' : ''}>{formatCurrency(valuation?.totalValueEur ?? 0)}</span>
            {#if privacyMode}<span class="absolute inset-0 flex items-center blur-[2px] select-none">{PRIVACY_PLACEHOLDER}</span>{/if}
          </div>
        </div>
      </div>
    </div>

    <!-- Issues Bar (only if issues exist) -->
    {#if issues.length > 0}
      <div class="flex items-center gap-2.5 px-3.5 py-2.5 bg-amber-50 border border-amber-200 rounded-xl mb-6 text-sm flex-wrap">
        <span class="font-semibold text-amber-800 whitespace-nowrap flex items-center gap-1.5">
          <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          {issues.length} Issues
        </span>
        <span class="w-px h-5 bg-amber-200"></span>

        {#each issues as issue}
          <button
            onclick={() => showIssueDetails(issue)}
            class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs cursor-pointer transition-colors
              {issue.type === 'error' ? 'bg-red-50 border border-red-200 hover:bg-red-100' : ''}
              {issue.type === 'warning' ? 'bg-amber-50 border border-amber-200 hover:bg-amber-100' : ''}
              {issue.type === 'allocation' ? 'bg-indigo-50 border border-indigo-200 hover:bg-indigo-100' : ''}"
          >
            <span class="w-1.5 h-1.5 rounded-full flex-shrink-0
              {issue.type === 'error' ? 'bg-red-500' : ''}
              {issue.type === 'warning' ? 'bg-amber-500' : ''}
              {issue.type === 'allocation' ? 'bg-indigo-500' : ''}"></span>
            <span>{issue.label}</span>
            <svg class="w-2.5 h-2.5 text-slate-400 ml-0.5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"/>
            </svg>
          </button>
        {/each}
      </div>
    {/if}

    <!-- Main Grid: Chart + Sleeves -->
    <div class="grid grid-cols-[1fr_420px] gap-6 mb-6">
      <!-- Chart Card -->
      <div class="rounded-xl border border-slate-200 bg-white overflow-hidden">
        <div class="p-5 pt-4">
          <!-- Chart header -->
          <div class="flex items-center justify-between mb-4">
            <span class="text-xs font-semibold uppercase tracking-wider text-slate-500">
              Invested Value
            </span>
            <div class="flex gap-0.5">
              {#each ['1m', '3m', '6m', '1y', 'all'] as range, i}
                <button
                  onclick={() => selectedChartRange = range as typeof selectedChartRange}
                  disabled={chartLoading}
                  class="px-2.5 py-1 text-[11px] font-medium border border-slate-200 transition-colors disabled:opacity-50
                    {i === 0 ? 'rounded-l-md' : ''}
                    {i === 4 ? 'rounded-r-md' : ''}
                    {selectedChartRange === range ? 'bg-slate-900 text-white border-slate-900' : 'bg-white text-slate-500 hover:bg-slate-50'}"
                >
                  {range.toUpperCase()}
                </button>
              {/each}
            </div>
          </div>

          <!-- Chart container -->
          <div class="relative h-[200px] mb-2">
            {#if chartLoading}
              <div class="absolute inset-0 flex items-center justify-center bg-white">
                <div class="flex flex-col items-center gap-2">
                  <div class="w-6 h-6 border-2 border-slate-300 border-t-slate-600 rounded-full animate-spin"></div>
                  <span class="text-xs text-slate-400">Loading chart...</span>
                </div>
              </div>
            {:else if chartError}
              <div class="absolute inset-0 flex items-center justify-center bg-slate-50 rounded">
                <div class="text-center text-sm text-slate-400 px-4">
                  <svg class="w-8 h-8 mx-auto mb-2 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                  <p>{chartError}</p>
                </div>
              </div>
            {:else if chartData.length === 0}
              <div class="absolute inset-0 flex items-center justify-center bg-slate-50 rounded">
                <p class="text-sm text-slate-400">No data available</p>
              </div>
            {:else}
              <div bind:this={chartContainer} class="w-full h-full"></div>
            {/if}
          </div>

          <!-- Legend -->
          <div class="flex gap-5 text-[11px] text-slate-500 pl-2">
            <div class="flex items-center gap-1.5">
              <span class="w-3.5 h-0.5 rounded bg-green-600"></span>
              Invested
            </div>
            <div class="flex items-center gap-1.5">
              <span class="w-3.5 h-0.5 rounded bg-slate-400"></span>
              Cost Basis
            </div>
          </div>
        </div>
      </div>

      <!-- Sleeves Card -->
      <div class="rounded-xl border border-slate-200 bg-white overflow-hidden">
        <div class="flex items-center justify-between px-5 py-3.5 border-b border-slate-100">
          <span class="text-xs font-semibold uppercase tracking-wider text-slate-500">Sleeves</span>
        </div>

        {#if sleeves.length === 0}
          <div class="px-4 py-8 text-center text-sm text-slate-400">
            No sleeves configured
          </div>
        {:else}
          <div class="divide-y divide-slate-100">
            {#each sleeves as sleeve}
              <button
                onclick={() => toggleSleeveFilter(sleeve.id)}
                class="w-full grid grid-cols-[1fr_70px_80px_70px] items-center gap-3 pl-4 pr-6 py-2.5 cursor-pointer transition-colors
                  {selectedSleeveId === sleeve.id ? 'bg-slate-100' : 'hover:bg-slate-50'}
                  {sleeve.depth > 0 ? 'bg-slate-50/50' : ''}"
              >
                <!-- Name -->
                <span class="font-medium text-left truncate {sleeve.depth > 0 ? 'pl-3 text-slate-600 text-[13px] font-normal' : 'text-slate-900'}">
                  {#if sleeve.depth > 0}<span class="text-slate-300 mr-1">└</span>{/if}{sleeve.name}
                </span>

                <!-- Value -->
                <span class="text-slate-500 tabular-nums text-right relative {sleeve.depth > 0 ? 'text-[13px]' : ''}">
                  <span class={privacyMode ? 'invisible' : ''}>{formatCurrency(sleeve.value)}</span>
                  {#if privacyMode}<span class="absolute inset-0 flex items-center justify-end blur-[2px] select-none">{PRIVACY_PLACEHOLDER}</span>{/if}
                </span>

                <!-- Return with annualized for "all" period -->
                <div class="flex flex-col items-end tabular-nums {sleeve.depth > 0 ? 'text-[13px]' : ''}">
                  {#if sleeve.returnPercent !== null}
                    <span class="font-semibold {sleeve.returnPercent >= 0 ? 'text-green-600' : 'text-red-600'}">
                      {sleeve.returnPercent >= 0 ? '+' : ''}{sleeve.returnPercent.toFixed(1)}%
                    </span>
                    {#if selectedPeriod === 'all' && sleeve.annualizedReturn !== null}
                      <span class="text-slate-400 text-[10px]">({sleeve.annualizedReturn >= 0 ? '+' : ''}{sleeve.annualizedReturn.toFixed(0)}% p.a.)</span>
                    {/if}
                  {:else}
                    <span class="text-slate-300">--</span>
                  {/if}
                </div>

                <!-- Allocation: Actual / Target with color coding -->
                <span class="tabular-nums text-right pl-2 {sleeve.depth > 0 ? 'text-[13px]' : ''}
                  {sleeve.bandStatus === 'ok' ? 'text-slate-600' : ''}
                  {sleeve.bandStatus === 'over' ? 'text-amber-600' : ''}
                  {sleeve.bandStatus === 'under' ? 'text-blue-600' : ''}">
                  <span class="font-semibold">{sleeve.actualPercent.toFixed(1)}%</span><span class="text-slate-400 font-normal text-[11px]">/{sleeve.targetPercent.toFixed(0)}%</span>
                </span>
              </button>
            {/each}
          </div>
        {/if}
      </div>
    </div>

    <!-- Assets Table Card -->
    <div class="rounded-xl border border-slate-200 bg-white overflow-hidden">
      <!-- Table header with title and filter -->
      <div class="flex items-center justify-between px-5 py-3.5 border-b border-slate-100">
        <span class="text-xs font-semibold uppercase tracking-wider text-slate-500">Assets</span>

        <select
          bind:value={selectedSleeveId}
          class="text-xs px-2.5 py-1.5 border border-slate-200 rounded-md text-slate-500"
        >
          <option value="">All Sleeves</option>
          {#each sleeves as sleeve}
            <option value={sleeve.id}>{sleeve.depth > 0 ? '└ ' : ''}{sleeve.name}</option>
          {/each}
        </select>
      </div>

      <!-- Table -->
      <div class="max-h-[480px] overflow-y-auto">
        <table class="w-full">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-200 sticky top-0 z-10">
              <th
                onclick={() => handleSort('ticker')}
                class="px-4 py-2.5 text-left text-[10px] font-semibold uppercase tracking-wider text-slate-400 cursor-pointer hover:text-slate-600"
              >
                Asset {sortColumn === 'ticker' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th
                onclick={() => handleSort('sleeve')}
                class="px-4 py-2.5 text-left text-[10px] font-semibold uppercase tracking-wider text-slate-400 cursor-pointer hover:text-slate-600"
              >
                Sleeve {sortColumn === 'sleeve' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th
                onclick={() => handleSort('weight')}
                class="px-4 py-2.5 text-right text-[10px] font-semibold uppercase tracking-wider text-slate-400 cursor-pointer hover:text-slate-600"
              >
                Weight {sortColumn === 'weight' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th
                onclick={() => handleSort('value')}
                class="px-4 py-2.5 text-right text-[10px] font-semibold uppercase tracking-wider text-slate-400 cursor-pointer hover:text-slate-600"
              >
                Value {sortColumn === 'value' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th
                onclick={() => handleSort('pl')}
                class="px-4 py-2.5 text-right text-[10px] font-semibold uppercase tracking-wider text-slate-400 cursor-pointer hover:text-slate-600"
                title={selectedPeriod === 'all' ? 'Profit/Loss since inception' : `Profit/Loss for ${selectedPeriod === 'today' ? 'Today' : selectedPeriod.toUpperCase()} period`}
              >
                P/L {sortColumn === 'pl' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th
                onclick={() => handleSort('return')}
                class="px-4 py-2.5 text-right text-[10px] font-semibold uppercase tracking-wider text-slate-400 cursor-pointer hover:text-slate-600"
                title={selectedPeriod === 'all' ? 'Return since inception (MWR)' : `Return for ${selectedPeriod === 'today' ? 'Today' : selectedPeriod.toUpperCase()} period`}
              >
                {selectedPeriod === 'all' ? 'Return' : selectedPeriod === 'today' ? 'Today' : selectedPeriod.toUpperCase()} {sortColumn === 'return' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
            </tr>
          </thead>
          <tbody>
            {#each sortedHoldings as holding (holding.id)}
              <tr class="border-b border-slate-100 hover:bg-slate-50 {$recentlyUpdated.has(holding.id) ? 'price-updated' : ''}">
                <td class="px-4 py-2.5">
                  <span class="font-semibold text-slate-900">{holding.ticker}</span>
                  <span class="text-slate-500 text-xs ml-1">{holding.name}</span>
                </td>
                <td class="px-4 py-2.5">
                  <span class="inline-block px-2 py-0.5 bg-slate-100 rounded text-[11px] font-medium text-slate-500">{holding.sleeveName}</span>
                </td>
                <td class="px-4 py-2.5 text-right tabular-nums">{holding.weight.toFixed(1)}%</td>
                <td class="px-4 py-2.5 text-right tabular-nums relative">
                  <span class={privacyMode ? 'invisible' : ''}>{holding.value.toLocaleString('de-DE')}</span>
                  {#if privacyMode}<span class="absolute inset-0 flex items-center justify-end blur-[2px] select-none">{PRIVACY_PLACEHOLDER}</span>{/if}
                </td>
                <td class="px-4 py-2.5 text-right tabular-nums relative">
                  {#if holding.absoluteReturn !== null}
                    <span class={privacyMode ? 'invisible' : ''}>
                      <span class="font-semibold {holding.absoluteReturn >= 0 ? 'text-green-600' : 'text-red-600'}">
                        {holding.absoluteReturn >= 0 ? '+' : ''}{holding.absoluteReturn.toLocaleString('de-DE', { maximumFractionDigits: 0 })}
                      </span>
                    </span>
                    {#if privacyMode}<span class="absolute inset-0 flex items-center justify-end blur-[2px] select-none">{PRIVACY_PLACEHOLDER}</span>{/if}
                  {:else}
                    <span class="text-slate-300">--</span>
                  {/if}
                </td>
                <td class="px-4 py-2.5 text-right tabular-nums">
                  <div class="flex flex-col items-end">
                    <div class="flex items-center gap-1">
                      {#if holding.isShortHolding}
                        <span class="text-[9px] px-1 py-0.5 bg-slate-100 text-slate-500 rounded" title="Held for shorter than selected period">
                          {holding.holdingPeriodLabel}
                        </span>
                      {/if}
                      <span class="font-semibold {holding.returnPercent >= 0 ? 'text-green-600' : 'text-red-600'}">
                        {holding.returnPercent >= 0 ? '+' : ''}{holding.returnPercent.toFixed(1)}%
                      </span>
                    </div>
                    {#if holding.annualizedReturn !== null && selectedPeriod === 'all'}
                      <span class="text-[10px] text-slate-400">
                        ({holding.annualizedReturn >= 0 ? '+' : ''}{holding.annualizedReturn.toFixed(0)}% p.a.)
                      </span>
                    {/if}
                  </div>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>

      <!-- Table footer -->
      <div class="px-4 py-3 border-t border-slate-100 text-center text-xs text-slate-400">
        {#if holdings.length === 0}
          No holdings in this portfolio
        {:else}
          Showing {sortedHoldings.length} of {holdings.length} assets
          {#if selectedSleeveId}
            ({sleeves.find(s => s.id === selectedSleeveId)?.name})
          {/if}
        {/if}
      </div>
    </div>
  </div>
  {/if}
</div>
