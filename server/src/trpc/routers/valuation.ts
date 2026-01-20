/**
 * Valuation Router
 *
 * Calculates portfolio valuation and allocation percentages.
 * Uses cached prices if available, falls back to cost basis.
 * Supports n-ary tree structure for sleeves - parent sleeves include
 * the value of all their descendants.
 *
 * Key concepts:
 * - Cash is NOT a sleeve - it's shown separately
 * - "Invested Only" view: percentages relative to assigned holdings only
 * - "Total Portfolio" view: percentages relative to holdings + cash
 * - Band evaluation only applies to Invested view
 */

import { z } from 'zod';
import { eq, gt, and, gte, lte, inArray } from 'drizzle-orm';
import xirr from 'xirr';
import { router, publicProcedure } from '../trpc';
import {
	holdings,
	assets,
	sleeves,
	sleeveAssets,
	portfolios,
	priceCache,
	portfolioRules,
	globalCash,
	orders,
	dailyPrices,
	fxCache
} from '../../db/schema';
import type { Sleeve, AssetType, ConcentrationLimitConfig } from '../../db/schema';
import {
	calculateBand,
	evaluateStatus,
	type BandConfig,
	type Band,
	type AllocationStatus
} from '../../utils/bands';

// Debug: Order detail for investigation
export interface OrderDetail {
	date: string;
	type: 'buy' | 'sell' | 'commission';
	quantity: number;
	totalNative: number;
	totalEur: number;
	pricePerShareNative: number | null; // null for commission (qty=0)
	pricePerShareEur: number | null; // null for commission (qty=0)
	impliedFxRate: number | null; // EUR/Native, null for commission
}

// Debug: Different calculation approaches
export interface CalculationApproaches {
	// Approach 1: Direct from native amount
	avgPriceNative_fromNative: number;
	// Approach 2: From EUR converted to native using implied FX at buy
	avgPriceNative_fromEurViaImpliedFx: number;
	// Approach 3: From EUR converted using current FX (if available)
	avgPriceNative_fromEurViaCurrentFx: number | null;
	// The implied FX rate (EUR per 1 native unit)
	impliedFxRate: number | null;
	// Current FX rate from price cache
	currentFxRate: number | null;
}

export interface AssetValuation {
	isin: string;
	ticker: string;
	name: string;
	assetType: AssetType;
	quantity: number;
	priceEur: number | null; // null if no cached price
	costBasisEur: number;
	valueEur: number; // uses price if available, else cost basis
	usingCostBasis: boolean;
	// Concentration info (calculated per-asset)
	percentOfInvested: number;
	// Native currency info (for debugging)
	currency: string; // Asset's base currency
	priceNative: number | null; // Price in native currency
	// Historical cost in native currency (from orders)
	costBasisNative: number; // Sum of totalNative from buy orders
	impliedHistoricalFxRate: number | null; // costBasisEur / costBasisNative (rate used at import)
	// Debug: Order details and calculation approaches
	orders: OrderDetail[];
	calculations: CalculationApproaches;
}

export interface ConcentrationViolation {
	ruleId: string;
	ruleName: string;
	assetIsin: string;
	assetName: string;
	assetTicker: string;
	assetType: AssetType;
	actualPercent: number;
	maxPercent: number;
}

export interface MissingSymbolAsset {
	isin: string;
	ticker: string;
	name: string;
}

export interface StalePriceAsset {
	isin: string;
	ticker: string;
	name: string;
	lastFetchedAt: Date;
	hoursStale: number;
}

export interface SleeveAllocation {
	sleeveId: string;
	sleeveName: string;
	parentSleeveId: string | null;
	budgetPercent: number;

	// Direct assets assigned to this sleeve
	directAssets: AssetValuation[];
	directValueEur: number;

	// Total value including all descendants (direct + children's totals)
	totalValueEur: number;

	// Dual percentages for toggle support
	actualPercentInvested: number; // % of invested holdings (primary)
	actualPercentTotal: number; // % of total including cash (informational)

	// Band info (calculated against invested)
	band: Band;
	status: AllocationStatus;

	// Delta from target (uses invested)
	deltaPercent: number;

	// Legacy fields for backwards compatibility
	actualPercent: number; // alias for actualPercentInvested
	assets: AssetValuation[];
	actualValueEur: number;
}

export interface PortfolioValuation {
	portfolioId: string;
	portfolioName: string;

	// Cash (shown separately, not as a sleeve)
	cashEur: number;

	// Value breakdowns
	totalHoldingsValueEur: number; // All holdings
	assignedHoldingsValueEur: number; // Holdings assigned to sleeves
	unassignedValueEur: number; // Holdings not assigned to any sleeve
	investedValueEur: number; // = assignedHoldingsValueEur (the "100%" for invested view)
	totalValueEur: number; // = totalHoldingsValueEur + cashEur (the "100%" for total view)
	totalCostBasisEur: number; // Sum of all cost basis (for total return calculation)

	// Sleeves (excluding cash sleeves)
	sleeves: SleeveAllocation[];

	// Unassigned assets
	unassignedAssets: AssetValuation[];

	// Band configuration
	bandConfig: BandConfig;

	// Summary - sleeve band violations
	violationCount: number; // Number of sleeves with status='warning'
	hasAllPrices: boolean;

	// Health issues - missing Yahoo symbols
	missingSymbolAssets: MissingSymbolAsset[];

	// Health issues - stale prices (older than threshold)
	stalePriceAssets: StalePriceAsset[];
	stalePriceThresholdHours: number;

	// Concentration rule violations
	concentrationViolations: ConcentrationViolation[];
	concentrationViolationCount: number;

	// Total rule violations (sleeves + concentration)
	totalViolationCount: number;

	// Sync info
	lastSyncAt: Date | null; // Most recent price fetch time, null if no prices cached

	// Legacy field
	allocatableValueEur: number; // Deprecated: use investedValueEur
}

/**
 * Recursively calculate total value for a sleeve including all descendants
 */
function calculateSleeveTotal(
	sleeveId: string,
	childrenMap: Map<string | null, Sleeve[]>,
	directValueMap: Map<string, number>
): number {
	// Start with direct value of this sleeve
	let total = directValueMap.get(sleeveId) ?? 0;

	// Add totals from all children recursively (excluding cash sleeves)
	const children = (childrenMap.get(sleeveId) ?? []).filter((c) => !c.isCash);
	for (const child of children) {
		total += calculateSleeveTotal(child.id, childrenMap, directValueMap);
	}

	return total;
}

export const valuationRouter = router({
	/**
	 * Get full portfolio valuation with allocation breakdown
	 */
	getPortfolioValuation: publicProcedure
		.input(z.object({ portfolioId: z.string() }))
		.query(async ({ ctx, input }): Promise<PortfolioValuation> => {
			// Get portfolio
			const [portfolio] = await ctx.db
				.select()
				.from(portfolios)
				.where(eq(portfolios.id, input.portfolioId))
				.limit(1);

			if (!portfolio) {
				throw new Error('Portfolio not found');
			}

			// Build band configuration from portfolio settings
			const bandConfig: BandConfig = {
				relativeTolerance: portfolio.bandRelativeTolerance,
				absoluteFloor: portfolio.bandAbsoluteFloor,
				absoluteCap: portfolio.bandAbsoluteCap
			};

			// Get all holdings with assets (only those with quantity > 0 and not archived)
			const allHoldings = await ctx.db
				.select({
					holding: holdings,
					asset: assets
				})
				.from(holdings)
				.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
				.where(and(gt(holdings.quantity, 0), eq(assets.archived, false)));

			// Get cached prices - use yahooSymbol for lookup
			const cachedPrices = await ctx.db.select().from(priceCache);
			const priceMap = new Map(cachedPrices.map((p) => [p.ticker, p.priceEur]));
			// Full price cache for native currency data
			const fullPriceMap = new Map(cachedPrices.map((p) => [p.ticker, p]));

			// Get last sync time from cached prices
			const lastSyncAt =
				cachedPrices.length > 0
					? cachedPrices.reduce((latest, p) => (p.fetchedAt > latest ? p.fetchedAt : latest), cachedPrices[0].fetchedAt)
					: null;

			// Get portfolio rules for concentration limits
			const rules = await ctx.db
				.select()
				.from(portfolioRules)
				.where(eq(portfolioRules.portfolioId, input.portfolioId));

			// Get global cash
			const [cashRow] = await ctx.db
				.select()
				.from(globalCash)
				.where(eq(globalCash.id, 'default'))
				.limit(1);
			const cashEur = cashRow?.amountEur ?? 0;

			// Get all orders to calculate native currency cost basis using Average Cost Method
			const allOrders = await ctx.db.select().from(orders);

			// Calculate native cost basis per ISIN using Average Cost Method
			// (same algorithm as derive-holdings.ts)
			const nativeCostByIsin = new Map<string, number>();
			const ordersByIsin = new Map<string, typeof allOrders>();

			for (const order of allOrders) {
				const existing = ordersByIsin.get(order.assetIsin) ?? [];
				existing.push(order);
				ordersByIsin.set(order.assetIsin, existing);
			}

			for (const [isin, isinOrders] of ordersByIsin) {
				// Sort by date for chronological processing
				const sortedOrders = [...isinOrders].sort(
					(a, b) => a.orderDate.getTime() - b.orderDate.getTime()
				);

				let totalQty = 0;
				let totalCostNative = 0;

				for (const order of sortedOrders) {
					if (order.quantity > 0) {
						// BUY: add to cost basis
						totalQty += order.quantity;
						totalCostNative += order.totalNative;
					} else if (order.quantity < 0) {
						// SELL: reduce cost basis proportionally
						const soldQty = Math.abs(order.quantity);
						if (totalQty > 0) {
							const avgCostNative = totalCostNative / totalQty;
							totalCostNative = Math.max(0, totalCostNative - avgCostNative * soldQty);
							totalQty = Math.max(0, totalQty - soldQty);
						}
					} else {
						// COMMISSION (quantity = 0): add to cost basis
						totalCostNative += order.totalNative;
					}
				}

				nativeCostByIsin.set(isin, totalCostNative);
			}

			// Build asset valuations (we'll add percentOfInvested after calculating totals)
			const assetValuationsPartial = allHoldings.map((h) => {
				// Look up price by yahooSymbol if available, otherwise fall back to broker ticker
				const lookupKey = h.asset.yahooSymbol ?? h.asset.ticker;
				const cachedPrice = priceMap.get(lookupKey);
				const fullPrice = fullPriceMap.get(lookupKey);
				const usingCostBasis = cachedPrice === undefined;
				const priceEur = cachedPrice ?? null;

				// Value: use price * quantity if we have price, else use cost basis
				const valueEur =
					priceEur !== null ? priceEur * h.holding.quantity : h.holding.totalCostEur;

				// Native currency cost basis from orders
				const costBasisNative = nativeCostByIsin.get(h.asset.isin) ?? 0;
				// Implied FX rate at time of purchase (EUR per 1 unit of native currency)
				const impliedHistoricalFxRate =
					costBasisNative !== 0 ? h.holding.totalCostEur / costBasisNative : null;

				// Current FX rate (from current prices: priceEur / priceNative)
				const currentFxRate =
					fullPrice?.priceNative && fullPrice.priceNative !== 0
						? fullPrice.priceEur / fullPrice.priceNative
						: null;

				// Get order details for this asset
				const assetOrders = ordersByIsin.get(h.asset.isin) ?? [];
				const orderDetails: OrderDetail[] = assetOrders
					.sort((a, b) => a.orderDate.getTime() - b.orderDate.getTime())
					.map((o) => {
						// Determine order type: buy (qty > 0), sell (qty < 0), commission (qty = 0)
						const type: 'buy' | 'sell' | 'commission' =
							o.quantity > 0 ? 'buy' : o.quantity < 0 ? 'sell' : 'commission';
						const absQty = Math.abs(o.quantity);

						return {
							date: o.orderDate.toISOString().split('T')[0],
							type,
							quantity: absQty,
							totalNative: o.totalNative,
							totalEur: o.totalEur,
							// For commission (qty=0), these are null to avoid division by zero
							pricePerShareNative: absQty > 0 ? o.totalNative / absQty : null,
							pricePerShareEur: absQty > 0 ? o.totalEur / absQty : null,
							impliedFxRate: o.totalNative !== 0 ? o.totalEur / o.totalNative : null
						};
					});

				// Calculate different approaches for average price
				const qty = h.holding.quantity;
				const costEur = h.holding.totalCostEur;

				// Approach 1: Direct from native amount (native cost / qty)
				const avgPriceNative_fromNative = qty > 0 ? costBasisNative / qty : 0;

				// Approach 2: From EUR, converted via implied historical FX
				// avgPriceEur / impliedFxRate = avgPriceNative
				const avgPriceEur = qty > 0 ? costEur / qty : 0;
				const avgPriceNative_fromEurViaImpliedFx =
					impliedHistoricalFxRate && impliedHistoricalFxRate !== 0
						? avgPriceEur / impliedHistoricalFxRate
						: 0;

				// Approach 3: From EUR, converted via current FX rate
				const avgPriceNative_fromEurViaCurrentFx =
					currentFxRate && currentFxRate !== 0 ? avgPriceEur / currentFxRate : null;

				const calculations: CalculationApproaches = {
					avgPriceNative_fromNative,
					avgPriceNative_fromEurViaImpliedFx,
					avgPriceNative_fromEurViaCurrentFx,
					impliedFxRate: impliedHistoricalFxRate,
					currentFxRate
				};

				return {
					isin: h.asset.isin,
					ticker: h.asset.ticker,
					name: h.asset.name,
					assetType: h.asset.assetType as AssetType,
					quantity: h.holding.quantity,
					priceEur,
					costBasisEur: h.holding.totalCostEur,
					valueEur,
					usingCostBasis,
					// Native currency info
					currency: fullPrice?.currency ?? h.asset.currency,
					priceNative: fullPrice?.priceNative ?? null,
					// Historical cost basis info
					costBasisNative,
					impliedHistoricalFxRate,
					// Debug: Order details and calculation approaches
					orders: orderDetails,
					calculations
				};
			});

			// Get portfolio sleeves (all of them for tree traversal)
			const allPortfolioSleeves = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.portfolioId, input.portfolioId))
				.orderBy(sleeves.sortOrder);

			// Filter out cash sleeves for the result
			const portfolioSleeves = allPortfolioSleeves.filter((s) => !s.isCash);

			// Build sleeve maps for tree traversal (include cash for parent lookups)
			const childrenMap = new Map<string | null, Sleeve[]>();

			// Group sleeves by parent
			for (const sleeve of allPortfolioSleeves) {
				const parentId = sleeve.parentSleeveId;
				if (!childrenMap.has(parentId)) {
					childrenMap.set(parentId, []);
				}
				childrenMap.get(parentId)!.push(sleeve);
			}

			// Get sleeve asset assignments
			const allAssignments = await ctx.db.select().from(sleeveAssets);
			const sleeveIds = new Set(portfolioSleeves.map((s) => s.id));
			const portfolioAssignments = allAssignments.filter((a) => sleeveIds.has(a.sleeveId));

			// Calculate totals first (needed for percentages)
			const totalHoldingsValueEur = assetValuationsPartial.reduce((sum, a) => sum + a.valueEur, 0);
			const totalCostBasisEur = assetValuationsPartial.reduce((sum, a) => sum + a.costBasisEur, 0);
			const totalValueEur = totalHoldingsValueEur + cashEur;

			// Find unassigned assets
			const assignedIsins = new Set(portfolioAssignments.map((a) => a.assetIsin));
			const unassignedValueEur = assetValuationsPartial
				.filter((a) => !assignedIsins.has(a.isin))
				.reduce((sum, a) => sum + a.valueEur, 0);

			// Invested value = assigned holdings only (NO cash)
			const assignedHoldingsValueEur = totalHoldingsValueEur - unassignedValueEur;
			const investedValueEur = assignedHoldingsValueEur;

			// Now build full asset valuations with percentages
			const assetValuations: AssetValuation[] = assetValuationsPartial.map((a) => ({
				...a,
				percentOfInvested: investedValueEur > 0 ? (a.valueEur / investedValueEur) * 100 : 0
			}));

			// Create a map for quick asset lookup by ISIN
			const assetMap = new Map(assetValuations.map((a) => [a.isin, a]));

			// Build direct assets and values per sleeve
			const directAssetsMap = new Map<string, AssetValuation[]>();
			const directValueMap = new Map<string, number>();

			for (const sleeve of portfolioSleeves) {
				const sleeveAssetIsins = portfolioAssignments
					.filter((a) => a.sleeveId === sleeve.id)
					.map((a) => a.assetIsin);

				const directAssets = sleeveAssetIsins
					.map((isin) => assetMap.get(isin))
					.filter((a): a is AssetValuation => a !== undefined);

				const directValue = directAssets.reduce((sum, a) => sum + a.valueEur, 0);

				directAssetsMap.set(sleeve.id, directAssets);
				directValueMap.set(sleeve.id, directValue);
			}

			// Find unassigned assets (with full valuation info)
			const unassignedAssets = assetValuations.filter((a) => !assignedIsins.has(a.isin));

			// Build sleeve allocations with recursive totals and band evaluation
			let violationCount = 0;

			const sleeveAllocations: SleeveAllocation[] = portfolioSleeves.map((sleeve) => {
				const directAssets = directAssetsMap.get(sleeve.id) ?? [];
				const directValueEur = directValueMap.get(sleeve.id) ?? 0;

				// Calculate total including all descendants
				const sleeveTotal = calculateSleeveTotal(sleeve.id, childrenMap, directValueMap);

				// Dual percentages
				const actualPercentInvested =
					investedValueEur > 0 ? (sleeveTotal / investedValueEur) * 100 : 0;
				const actualPercentTotal = totalValueEur > 0 ? (sleeveTotal / totalValueEur) * 100 : 0;

				// Calculate band and status (based on invested percentage)
				const band = calculateBand(sleeve.budgetPercent, bandConfig);
				const status = evaluateStatus(actualPercentInvested, band);

				if (status === 'warning') {
					violationCount++;
				}

				const deltaPercent = actualPercentInvested - sleeve.budgetPercent;

				return {
					sleeveId: sleeve.id,
					sleeveName: sleeve.name,
					parentSleeveId: sleeve.parentSleeveId,
					budgetPercent: sleeve.budgetPercent,
					directAssets,
					directValueEur,
					totalValueEur: sleeveTotal,
					actualPercentInvested,
					actualPercentTotal,
					band,
					status,
					deltaPercent,
					// Legacy fields
					actualPercent: actualPercentInvested,
					assets: directAssets,
					actualValueEur: sleeveTotal
				};
			});

			// Check if all prices are available
			const hasAllPrices = assetValuations.every((a) => !a.usingCostBasis);

			// Find assets missing Yahoo symbols (holdings that have no yahooSymbol set)
			const missingSymbolAssets: MissingSymbolAsset[] = allHoldings
				.filter((h) => !h.asset.yahooSymbol)
				.map((h) => ({
					isin: h.asset.isin,
					ticker: h.asset.ticker,
					name: h.asset.name
				}));

			// Find assets with stale prices (older than 24 hours)
			const stalePriceThresholdHours = 24;
			const stalePriceThresholdMs = stalePriceThresholdHours * 60 * 60 * 1000;
			const now = Date.now();

			const stalePriceAssets: StalePriceAsset[] = allHoldings
				.map((h) => {
					const lookupKey = h.asset.yahooSymbol ?? h.asset.ticker;
					const priceEntry = fullPriceMap.get(lookupKey);
					if (!priceEntry) return null;

					const fetchedAt = priceEntry.fetchedAt;
					const ageMs = now - fetchedAt.getTime();
					if (ageMs > stalePriceThresholdMs) {
						return {
							isin: h.asset.isin,
							ticker: h.asset.ticker,
							name: h.asset.name,
							lastFetchedAt: fetchedAt,
							hoursStale: Math.floor(ageMs / (60 * 60 * 1000))
						};
					}
					return null;
				})
				.filter((a): a is StalePriceAsset => a !== null);

			// Evaluate concentration limit rules
			const concentrationViolations: ConcentrationViolation[] = [];

			// Only check assigned assets for concentration
			const assignedAssets = assetValuations.filter((a) => assignedIsins.has(a.isin));

			for (const rule of rules) {
				if (!rule.enabled || rule.ruleType !== 'concentration_limit') {
					continue;
				}

				const config = rule.config as ConcentrationLimitConfig;
				const maxPercent = config.maxPercent;
				const assetTypeFilter = config.assetTypes;

				for (const asset of assignedAssets) {
					// Skip if rule has asset type filter and this asset doesn't match
					if (assetTypeFilter && assetTypeFilter.length > 0) {
						if (!assetTypeFilter.includes(asset.assetType)) {
							continue;
						}
					}

					// Check if asset exceeds the limit
					if (asset.percentOfInvested > maxPercent) {
						concentrationViolations.push({
							ruleId: rule.id,
							ruleName: rule.name,
							assetIsin: asset.isin,
							assetName: asset.name,
							assetTicker: asset.ticker,
							assetType: asset.assetType,
							actualPercent: asset.percentOfInvested,
							maxPercent
						});
					}
				}
			}

			const concentrationViolationCount = concentrationViolations.length;
			const totalViolationCount = violationCount + concentrationViolationCount;

			return {
				portfolioId: portfolio.id,
				portfolioName: portfolio.name,
				cashEur,
				totalHoldingsValueEur,
				assignedHoldingsValueEur,
				unassignedValueEur,
				investedValueEur,
				totalValueEur,
				totalCostBasisEur,
				sleeves: sleeveAllocations,
				unassignedAssets,
				bandConfig,
				violationCount,
				hasAllPrices,
				missingSymbolAssets,
				stalePriceAssets,
				stalePriceThresholdHours,
				concentrationViolations,
				concentrationViolationCount,
				totalViolationCount,
				lastSyncAt,
				// Legacy field
				allocatableValueEur: investedValueEur
			};
		}),

	/**
	 * Get historical chart data for portfolio value visualization.
	 * Returns daily data points with portfolio value and cost basis over time.
	 */
	getChartData: publicProcedure
		.input(
			z.object({
				portfolioId: z.string(),
				range: z.enum(['1m', '3m', '6m', '1y', 'all']).default('6m')
			})
		)
		.query(async ({ ctx, input }): Promise<ChartDataResult> => {
			const now = new Date();
			const endDateStr = now.toISOString().split('T')[0];

			// Get portfolio to verify it exists
			const [portfolio] = await ctx.db
				.select()
				.from(portfolios)
				.where(eq(portfolios.id, input.portfolioId))
				.limit(1);

			if (!portfolio) {
				throw new Error('Portfolio not found');
			}

			// Get all non-archived assets with their Yahoo symbols
			const allAssets = await ctx.db.select().from(assets).where(eq(assets.archived, false));
			const assetMap = new Map(allAssets.map((a) => [a.isin, a]));
			const nonArchivedIsins = new Set(allAssets.map((a) => a.isin));

			// Get all orders for non-archived assets (we need to reconstruct position history)
			const allOrders = await ctx.db
				.select()
				.from(orders)
				.orderBy(orders.orderDate);

			// Filter orders to only include non-archived assets
			const filteredOrders = allOrders.filter((o) => nonArchivedIsins.has(o.assetIsin));

			if (filteredOrders.length === 0) {
				return { dataPoints: [], hasData: false };
			}

			// Find the earliest order date for 'all' range
			const firstOrderDate = filteredOrders.reduce(
				(earliest, order) => (order.orderDate < earliest ? order.orderDate : earliest),
				filteredOrders[0].orderDate
			);

			// Calculate start date based on range
			let startDate: Date;

			switch (input.range) {
				case '1m':
					startDate = new Date(now);
					startDate.setMonth(startDate.getMonth() - 1);
					break;
				case '3m':
					startDate = new Date(now);
					startDate.setMonth(startDate.getMonth() - 3);
					break;
				case '6m':
					startDate = new Date(now);
					startDate.setMonth(startDate.getMonth() - 6);
					break;
				case '1y':
					startDate = new Date(now);
					startDate.setFullYear(startDate.getFullYear() - 1);
					break;
				case 'all':
					// Use the earliest order date
					startDate = new Date(firstOrderDate);
					break;
			}

			const startDateStr = startDate.toISOString().split('T')[0];

			// Get all FX rates from cache for currency conversion
			const fxRates = await ctx.db.select().from(fxCache);
			const fxRateMap = new Map(fxRates.map((f) => [f.pair, f.rate]));

			// Build list of yahoo symbols we need prices for
			const yahooSymbols = new Set<string>();
			for (const asset of allAssets) {
				if (asset.yahooSymbol) {
					yahooSymbols.add(asset.yahooSymbol);
				}
			}

			// Get historical prices for all relevant tickers
			const pricesResult =
				yahooSymbols.size > 0
					? await ctx.db
							.select()
							.from(dailyPrices)
							.where(
								and(
									inArray(dailyPrices.ticker, Array.from(yahooSymbols)),
									gte(dailyPrices.date, startDateStr),
									lte(dailyPrices.date, endDateStr)
								)
							)
					: [];

			// Build price lookup: ticker -> date -> adjusted close price (in native currency)
			// Using adjClose instead of close for accurate historical comparison (accounts for splits/dividends)
			const priceByTickerDate = new Map<string, Map<string, { close: number; currency: string }>>();
			for (const p of pricesResult) {
				if (!priceByTickerDate.has(p.ticker)) {
					priceByTickerDate.set(p.ticker, new Map());
				}
				priceByTickerDate.get(p.ticker)!.set(p.date, { close: p.adjClose, currency: p.currency });
			}

			// Process orders chronologically to build position snapshots
			// For each date, we need: { isin -> { quantity, costBasisEur } }
			type PositionSnapshot = Map<string, { quantity: number; costBasisEur: number; avgCostEur: number }>;

			// Sort orders by date (use filteredOrders which excludes archived assets)
			const sortedOrders = [...filteredOrders].sort(
				(a, b) => a.orderDate.getTime() - b.orderDate.getTime()
			);

			// Find the earliest order date that's relevant
			const earliestOrderDate = sortedOrders[0]?.orderDate;
			const effectiveStartDate = earliestOrderDate && earliestOrderDate > startDate ? startDate : startDate;

			// Build position state changes by date
			// We'll track cumulative positions after processing all orders up to each date
			const positionsByDate = new Map<string, PositionSnapshot>();
			let currentPositions: PositionSnapshot = new Map();

			// Process orders and create position snapshots
			let lastDate = '';
			for (const order of sortedOrders) {
				const orderDateStr = order.orderDate.toISOString().split('T')[0];

				// If we've moved to a new date, save the current snapshot
				if (orderDateStr !== lastDate && lastDate !== '') {
					positionsByDate.set(lastDate, new Map(currentPositions));
				}

				// Update positions based on order
				const existing = currentPositions.get(order.assetIsin) ?? {
					quantity: 0,
					costBasisEur: 0,
					avgCostEur: 0
				};

				if (order.quantity > 0) {
					// BUY
					const newQuantity = existing.quantity + order.quantity;
					const newCostBasis = existing.costBasisEur + order.totalEur;
					currentPositions.set(order.assetIsin, {
						quantity: newQuantity,
						costBasisEur: newCostBasis,
						avgCostEur: newQuantity > 0 ? newCostBasis / newQuantity : 0
					});
				} else if (order.quantity < 0) {
					// SELL
					const soldQty = Math.abs(order.quantity);
					const costReduction = existing.avgCostEur * soldQty;
					const newQuantity = Math.max(0, existing.quantity - soldQty);
					const newCostBasis = Math.max(0, existing.costBasisEur - costReduction);
					currentPositions.set(order.assetIsin, {
						quantity: newQuantity,
						costBasisEur: newCostBasis,
						avgCostEur: existing.avgCostEur // Average cost doesn't change on sell
					});
				} else {
					// COMMISSION (quantity = 0)
					currentPositions.set(order.assetIsin, {
						...existing,
						costBasisEur: existing.costBasisEur + order.totalEur,
						avgCostEur:
							existing.quantity > 0
								? (existing.costBasisEur + order.totalEur) / existing.quantity
								: existing.avgCostEur
					});
				}

				lastDate = orderDateStr;
			}
			// Save final state
			if (lastDate) {
				positionsByDate.set(lastDate, new Map(currentPositions));
			}

			// Generate data points for each date in range
			// We'll sample dates that have price data to avoid too many points
			const uniqueDates = new Set<string>();
			for (const [, dateMap] of priceByTickerDate) {
				for (const date of dateMap.keys()) {
					if (date >= startDateStr && date <= endDateStr) {
						uniqueDates.add(date);
					}
				}
			}

			// Also include order dates
			for (const date of positionsByDate.keys()) {
				if (date >= startDateStr) {
					uniqueDates.add(date);
				}
			}

			const sortedDates = Array.from(uniqueDates).sort();

			// Helper: get FX rate to EUR
			function getFxRateToEur(currency: string): number {
				if (currency === 'EUR') return 1;
				const pair = `${currency}EUR`;
				return fxRateMap.get(pair) ?? 1; // Default to 1 if no rate
			}

			// Helper: get position snapshot for a date (finds most recent snapshot <= date)
			function getPositionsForDate(date: string): PositionSnapshot {
				let bestSnapshot: PositionSnapshot = new Map();
				let bestDate = '';

				for (const [snapshotDate, snapshot] of positionsByDate) {
					if (snapshotDate <= date && snapshotDate > bestDate) {
						bestDate = snapshotDate;
						bestSnapshot = snapshot;
					}
				}

				return bestSnapshot;
			}

			// Helper: get price for an asset on a date (or nearest prior date)
			function getPriceForDate(
				isin: string,
				date: string,
				sortedDatesForTicker: string[]
			): { price: number; currency: string } | null {
				const asset = assetMap.get(isin);
				if (!asset?.yahooSymbol) return null;

				const tickerPrices = priceByTickerDate.get(asset.yahooSymbol);
				if (!tickerPrices) return null;

				// Try exact date first
				const exactPrice = tickerPrices.get(date);
				if (exactPrice) return { price: exactPrice.close, currency: exactPrice.currency };

				// Find nearest prior date
				let nearestDate = '';
				for (const d of sortedDatesForTicker) {
					if (d <= date && d > nearestDate) {
						nearestDate = d;
					}
				}

				if (nearestDate) {
					const priceData = tickerPrices.get(nearestDate);
					if (priceData) return { price: priceData.close, currency: priceData.currency };
				}

				return null;
			}

			// Build sorted dates per ticker for lookups
			const sortedDatesByTicker = new Map<string, string[]>();
			for (const [ticker, dateMap] of priceByTickerDate) {
				sortedDatesByTicker.set(ticker, Array.from(dateMap.keys()).sort());
			}

			// Get current prices from priceCache for today's data point
			// This ensures the most recent chart point matches the header value
			const cachedPrices = await ctx.db.select().from(priceCache);
			const currentPriceMap = new Map<string, number>(); // yahooSymbol -> priceEur
			// Also derive FX rates from priceCache for consistency with displayed values
			const derivedFxRateMap = new Map<string, number>(); // yahooSymbol -> EUR/native rate
			for (const p of cachedPrices) {
				currentPriceMap.set(p.ticker, p.priceEur);
				// Calculate implied FX rate: priceEur / priceNative
				if (p.priceNative && p.priceNative !== 0) {
					derivedFxRateMap.set(p.ticker, p.priceEur / p.priceNative);
				}
			}

			// Calculate data points
			const dataPoints: ChartDataPoint[] = [];
			const todayStr = endDateStr; // Today's date

			for (const date of sortedDates) {
				const positions = getPositionsForDate(date);
				const isToday = date === todayStr;

				let investedValue = 0;
				let costBasis = 0;

				for (const [isin, position] of positions) {
					if (position.quantity <= 0) continue;

					costBasis += position.costBasisEur;

					const asset = assetMap.get(isin);
					if (!asset?.yahooSymbol) {
						// No price available, use cost basis as value
						investedValue += position.costBasisEur;
						continue;
					}

					// For today, use priceCache (current quotes) to match header
					// For historical dates, use dailyPrices
					if (isToday) {
						const currentPrice = currentPriceMap.get(asset.yahooSymbol);
						if (currentPrice !== undefined) {
							investedValue += currentPrice * position.quantity;
						} else {
							// Fallback to daily price or cost basis
							const tickerDates = sortedDatesByTicker.get(asset.yahooSymbol) ?? [];
							const priceData = getPriceForDate(isin, date, tickerDates);
							if (priceData) {
								const fxRate = getFxRateToEur(priceData.currency);
								investedValue += priceData.price * position.quantity * fxRate;
							} else {
								investedValue += position.costBasisEur;
							}
						}
					} else {
						const tickerDates = sortedDatesByTicker.get(asset.yahooSymbol) ?? [];
						const priceData = getPriceForDate(isin, date, tickerDates);

						if (priceData) {
							// Use derived FX rate from priceCache for consistency with displayed values
							// This ensures historical chart values are comparable to current value
							const derivedFxRate = derivedFxRateMap.get(asset.yahooSymbol);
							const fxRate = derivedFxRate ?? getFxRateToEur(priceData.currency);
							investedValue += priceData.price * position.quantity * fxRate;
						} else {
							// No price, use cost basis
							investedValue += position.costBasisEur;
						}
					}
				}

				dataPoints.push({
					date,
					investedValue: Math.round(investedValue * 100) / 100,
					costBasis: Math.round(costBasis * 100) / 100
				});
			}

			return {
				dataPoints,
				hasData: dataPoints.length > 0
			};
		}),

	/**
	 * Get historical returns for different time periods.
	 * Calculates portfolio value at historical dates and compares to current value.
	 */
	getHistoricalReturns: publicProcedure
		.input(z.object({ portfolioId: z.string() }))
		.query(async ({ ctx, input }): Promise<HistoricalReturnsResult> => {
			const now = new Date();
			const todayStr = now.toISOString().split('T')[0];

			// Get portfolio to verify it exists
			const [portfolio] = await ctx.db
				.select()
				.from(portfolios)
				.where(eq(portfolios.id, input.portfolioId))
				.limit(1);

			if (!portfolio) {
				throw new Error('Portfolio not found');
			}

			// Calculate comparison dates for each period
			const getComparisonDate = (period: ReturnPeriod, firstOrderDateStr: string | null): string => {
				const date = new Date(now);
				switch (period) {
					case 'today':
						// Previous trading day (simplified: just yesterday)
						date.setDate(date.getDate() - 1);
						break;
					case '1w':
						date.setDate(date.getDate() - 7);
						break;
					case '1m':
						date.setDate(date.getDate() - 30);
						break;
					case '6m':
						date.setMonth(date.getMonth() - 6);
						break;
					case 'ytd':
						// Dec 31 of previous year
						date.setFullYear(date.getFullYear() - 1);
						date.setMonth(11);
						date.setDate(31);
						break;
					case '1y':
						date.setFullYear(date.getFullYear() - 1);
						break;
					case 'all':
						// First order date (inception)
						if (firstOrderDateStr) {
							return firstOrderDateStr;
						}
						// Fallback to 1 year ago if no orders
						date.setFullYear(date.getFullYear() - 1);
						break;
				}
				return date.toISOString().split('T')[0];
			};

			// Will be populated after we get orders
			const periods: ReturnPeriod[] = ['today', '1w', '1m', '6m', 'ytd', '1y', 'all'];

			// Get all non-archived assets with their Yahoo symbols
			const allAssets = await ctx.db.select().from(assets).where(eq(assets.archived, false));
			const assetMap = new Map(allAssets.map((a) => [a.isin, a]));
			const nonArchivedIsins = new Set(allAssets.map((a) => a.isin));

			// Get all orders for non-archived assets (we need to reconstruct position history)
			const allOrders = await ctx.db
				.select()
				.from(orders)
				.orderBy(orders.orderDate);

			// Filter orders to only include non-archived assets
			const filteredOrders = allOrders.filter((o) => nonArchivedIsins.has(o.assetIsin));

			if (filteredOrders.length === 0) {
				return { returns: {}, currentValue: 0, assetReturns: {} };
			}

			// Find first order date for 'all' period
			const sortedOrders = [...filteredOrders].sort(
				(a, b) => a.orderDate.getTime() - b.orderDate.getTime()
			);
			const firstOrderDate = sortedOrders[0]?.orderDate;
			const firstOrderDateStr = firstOrderDate?.toISOString().split('T')[0] ?? null;

			// Build comparison dates now that we have order history
			const comparisonDates = new Map<ReturnPeriod, string>();
			for (const period of periods) {
				comparisonDates.set(period, getComparisonDate(period, firstOrderDateStr));
			}

			// Get all dates we need prices for (including today)
			const allDatesNeeded = new Set<string>([todayStr]);
			for (const date of comparisonDates.values()) {
				allDatesNeeded.add(date);
			}

			// Find the earliest date we need
			const sortedDatesForPrices = Array.from(allDatesNeeded).sort();
			const earliestDate = sortedDatesForPrices[0];

			// Get all FX rates from cache for currency conversion
			const fxRates = await ctx.db.select().from(fxCache);
			const fxRateMap = new Map(fxRates.map((f) => [f.pair, f.rate]));

			// Build list of yahoo symbols we need prices for
			const yahooSymbols = new Set<string>();
			for (const asset of allAssets) {
				if (asset.yahooSymbol) {
					yahooSymbols.add(asset.yahooSymbol);
				}
			}

			// Get historical prices for all relevant tickers
			// We need a wider range to handle weekends/holidays (go back 5 extra days)
			const lookbackDate = new Date(earliestDate);
			lookbackDate.setDate(lookbackDate.getDate() - 5);
			const lookbackDateStr = lookbackDate.toISOString().split('T')[0];

			const pricesResult =
				yahooSymbols.size > 0
					? await ctx.db
							.select()
							.from(dailyPrices)
							.where(
								and(
									inArray(dailyPrices.ticker, Array.from(yahooSymbols)),
									gte(dailyPrices.date, lookbackDateStr),
									lte(dailyPrices.date, todayStr)
								)
							)
					: [];

			// Build price lookup: ticker -> date -> adjusted close price
			const priceByTickerDate = new Map<string, Map<string, { close: number; currency: string }>>();
			for (const p of pricesResult) {
				if (!priceByTickerDate.has(p.ticker)) {
					priceByTickerDate.set(p.ticker, new Map());
				}
				priceByTickerDate.get(p.ticker)!.set(p.date, { close: p.adjClose, currency: p.currency });
			}

			// Process orders chronologically to build position snapshots
			type PositionSnapshot = Map<string, { quantity: number; costBasisEur: number; avgCostEur: number }>;

			// Note: sortedOrders is already declared above

			// Build position state changes by date
			const positionsByDate = new Map<string, PositionSnapshot>();
			let currentPositions: PositionSnapshot = new Map();

			// Process orders and create position snapshots
			let lastDate = '';
			for (const order of sortedOrders) {
				const orderDateStr = order.orderDate.toISOString().split('T')[0];

				// If we've moved to a new date, save the current snapshot
				if (orderDateStr !== lastDate && lastDate !== '') {
					positionsByDate.set(lastDate, new Map(currentPositions));
				}

				// Update positions based on order
				const existing = currentPositions.get(order.assetIsin) ?? {
					quantity: 0,
					costBasisEur: 0,
					avgCostEur: 0
				};

				if (order.quantity > 0) {
					// BUY
					const newQuantity = existing.quantity + order.quantity;
					const newCostBasis = existing.costBasisEur + order.totalEur;
					currentPositions.set(order.assetIsin, {
						quantity: newQuantity,
						costBasisEur: newCostBasis,
						avgCostEur: newQuantity > 0 ? newCostBasis / newQuantity : 0
					});
				} else if (order.quantity < 0) {
					// SELL
					const soldQty = Math.abs(order.quantity);
					const costReduction = existing.avgCostEur * soldQty;
					const newQuantity = Math.max(0, existing.quantity - soldQty);
					const newCostBasis = Math.max(0, existing.costBasisEur - costReduction);
					currentPositions.set(order.assetIsin, {
						quantity: newQuantity,
						costBasisEur: newCostBasis,
						avgCostEur: existing.avgCostEur
					});
				} else {
					// COMMISSION (quantity = 0)
					currentPositions.set(order.assetIsin, {
						...existing,
						costBasisEur: existing.costBasisEur + order.totalEur,
						avgCostEur:
							existing.quantity > 0
								? (existing.costBasisEur + order.totalEur) / existing.quantity
								: existing.avgCostEur
					});
				}

				lastDate = orderDateStr;
			}
			// Save final state
			if (lastDate) {
				positionsByDate.set(lastDate, new Map(currentPositions));
			}

			// Helper: get FX rate to EUR
			function getFxRateToEur(currency: string): number {
				if (currency === 'EUR') return 1;
				const pair = `${currency}EUR`;
				return fxRateMap.get(pair) ?? 1;
			}

			// Helper: get position snapshot for a date (finds most recent snapshot <= date)
			function getPositionsForDate(date: string): PositionSnapshot {
				let bestSnapshot: PositionSnapshot = new Map();
				let bestDate = '';

				for (const [snapshotDate, snapshot] of positionsByDate) {
					if (snapshotDate <= date && snapshotDate > bestDate) {
						bestDate = snapshotDate;
						bestSnapshot = snapshot;
					}
				}

				return bestSnapshot;
			}

			// Get all available dates per ticker for lookups
			const datesByTicker = new Map<string, string[]>();
			for (const [ticker, dateMap] of priceByTickerDate) {
				datesByTicker.set(ticker, Array.from(dateMap.keys()).sort());
			}

			// Helper: get price for an asset on a date (or nearest prior date)
			function getPriceForDate(
				isin: string,
				targetDate: string
			): { price: number; currency: string; actualDate: string } | null {
				const asset = assetMap.get(isin);
				if (!asset?.yahooSymbol) return null;

				const tickerPrices = priceByTickerDate.get(asset.yahooSymbol);
				if (!tickerPrices) return null;

				// Try exact date first
				const exactPrice = tickerPrices.get(targetDate);
				if (exactPrice) {
					return { price: exactPrice.close, currency: exactPrice.currency, actualDate: targetDate };
				}

				// Find nearest prior date
				const tickerDates = datesByTicker.get(asset.yahooSymbol) ?? [];
				let nearestDate = '';
				for (const d of tickerDates) {
					if (d <= targetDate && d > nearestDate) {
						nearestDate = d;
					}
				}

				if (nearestDate) {
					const priceData = tickerPrices.get(nearestDate);
					if (priceData) {
						return { price: priceData.close, currency: priceData.currency, actualDate: nearestDate };
					}
				}

				return null;
			}

			// Get current prices from priceCache for today's value (matches dashboard header)
			const cachedPrices = await ctx.db.select().from(priceCache);
			const currentPriceMap = new Map<string, number>(); // yahooSymbol -> priceEur
			const derivedFxRateMap = new Map<string, number>(); // yahooSymbol -> EUR/native rate
			for (const p of cachedPrices) {
				currentPriceMap.set(p.ticker, p.priceEur);
				if (p.priceNative && p.priceNative !== 0) {
					derivedFxRateMap.set(p.ticker, p.priceEur / p.priceNative);
				}
			}

			// Calculate portfolio value at a given date
			function calculatePortfolioValue(date: string, usePriceCache: boolean): number {
				const positions = getPositionsForDate(date);
				let totalValue = 0;

				for (const [isin, position] of positions) {
					if (position.quantity <= 0) continue;

					const asset = assetMap.get(isin);
					if (!asset?.yahooSymbol) {
						// No price available, use cost basis as value
						totalValue += position.costBasisEur;
						continue;
					}

					if (usePriceCache) {
						// Use current cached price
						const currentPrice = currentPriceMap.get(asset.yahooSymbol);
						if (currentPrice !== undefined) {
							totalValue += currentPrice * position.quantity;
						} else {
							totalValue += position.costBasisEur;
						}
					} else {
						// Use historical price
						const priceData = getPriceForDate(isin, date);
						if (priceData) {
							// Use derived FX rate from priceCache for consistency
							const derivedFxRate = derivedFxRateMap.get(asset.yahooSymbol);
							const fxRate = derivedFxRate ?? getFxRateToEur(priceData.currency);
							totalValue += priceData.price * position.quantity * fxRate;
						} else {
							totalValue += position.costBasisEur;
						}
					}
				}

				return Math.round(totalValue * 100) / 100;
			}

			// Calculate current value (using priceCache)
			const currentValue = calculatePortfolioValue(todayStr, true);

			// Calculate total cost basis (includes commissions)
			const totalCostBasis = Array.from(currentPositions.values()).reduce(
				(sum, pos) => sum + pos.costBasisEur,
				0
			);

			// Extract cash flows from orders for MWR calculation
			// Cash flows: buys are positive (money entering), sells are negative (money leaving)
			// Commissions are not external cash flows, so we exclude them
			const cashFlows: CashFlow[] = sortedOrders
				.filter((order) => order.quantity !== 0) // Exclude commissions
				.map((order) => ({
					date: order.orderDate.toISOString().split('T')[0],
					// For buys (qty > 0): positive cash flow (money entering portfolio)
					// For sells (qty < 0): negative cash flow (money leaving portfolio)
					// Note: totalEur is always positive, so we negate for sells
					amount: order.quantity > 0 ? order.totalEur : -Math.abs(order.totalEur)
				}));

			// Calculate returns for each period using MWR
			const returns: Partial<Record<ReturnPeriod, PeriodReturn>> = {};
			const assetReturns: Partial<Record<ReturnPeriod, Record<string, AssetPeriodReturn>>> = {};

			// Get current holdings for asset returns calculation
			const currentHoldings = getPositionsForDate(todayStr);
			const holdingIsins = Array.from(currentHoldings.keys()).filter(
				(isin) => (currentHoldings.get(isin)?.quantity ?? 0) > 0
			);

			// Helper: find first order date for an asset
			function getAssetFirstOrderDate(isin: string): string | null {
				const assetOrders = sortedOrders.filter((o) => o.assetIsin === isin && o.quantity > 0);
				if (assetOrders.length === 0) return null;
				return assetOrders[0].orderDate.toISOString().split('T')[0];
			}

			for (const period of periods) {
				const comparisonDate = comparisonDates.get(period)!;

				// Check if we have any price data for this comparison date (within 5 day lookback)
				const startValue = calculatePortfolioValue(comparisonDate, false);

				// Only include if we have a meaningful start value (not just cost basis)
				// and the comparison date is not after our first order
				if (firstOrderDate && new Date(comparisonDate) >= firstOrderDate && startValue > 0) {
					// Calculate MWR for accurate performance measurement
					const {
						annualizedReturn,
						compoundedReturn,
						netCashFlow,
						cashFlowCount,
						periodYears
					} = calculateMWR(
						comparisonDate,
						todayStr,
						startValue,
						currentValue,
						cashFlows
					);

					// For "All" period: use cost basis for absolute return and simple total return %
					// For other periods: use period start value for period-specific return
					const isAllPeriod = period === 'all';

					// Absolute return
					// - "All": Current - Cost Basis (total P/L including commissions)
					// - Other: Current - Start Value (period gain, before adjusting for cash flows)
					const absoluteReturn = isAllPeriod
						? currentValue - totalCostBasis
						: currentValue - startValue - netCashFlow;

					// Percentage return:
					// - "All": simple total return (Current - Cost) / Cost
					// - Periods < 1 year: show simple return (compoundedReturn from XIRR)
					// - Periods >= 1 year: show annualized return
					let displayReturnPercent: number;
					if (isAllPeriod) {
						// Total return since inception - simple percentage
						displayReturnPercent = totalCostBasis > 0
							? (currentValue - totalCostBasis) / totalCostBasis
							: 0;
					} else if (periodYears >= 1) {
						displayReturnPercent = annualizedReturn;
					} else {
						displayReturnPercent = compoundedReturn;
					}

					returns[period] = {
						period,
						currentValue,
						startValue,
						absoluteReturn: Math.round(absoluteReturn * 100) / 100,
						compoundedReturn: Math.round(displayReturnPercent * 10000) / 100,
						annualizedReturn: Math.round(annualizedReturn * 10000) / 100,
						periodYears: Math.round(periodYears * 100) / 100,
						comparisonDate,
						netCashFlow: Math.round(netCashFlow * 100) / 100,
						cashFlowCount,
						// Legacy fields for backwards compatibility
						percentageReturn: Math.round(compoundedReturn * 10000) / 100,
						comparisonValue: startValue
					};

					// Calculate per-asset returns for this period
					const periodAssetReturns: Record<string, AssetPeriodReturn> = {};
					const isAllPeriodForAssets = period === 'all';

					for (const isin of holdingIsins) {
						const asset = assetMap.get(isin);
						if (!asset) continue;

						// Get current price from priceCache
						const currentPrice = asset.yahooSymbol
							? currentPriceMap.get(asset.yahooSymbol) ?? null
							: null;

						// Get current position for this asset (for quantity and cost basis)
						const position = currentHoldings.get(isin);
						const quantity = position?.quantity ?? 0;
						const costBasisEur = position?.costBasisEur ?? 0;

						// Check if this asset was held at the start of the period
						const assetFirstOrder = getAssetFirstOrderDate(isin);
						const isShortHolding = assetFirstOrder !== null && assetFirstOrder > comparisonDate;

						// For short holdings, use inception date instead of period start
						const effectiveStartDate = isShortHolding ? assetFirstOrder : comparisonDate;

						// Get historical price from dailyPrices
						const historicalPriceData = getPriceForDate(isin, effectiveStartDate!);
						const historicalPrice = historicalPriceData
							? historicalPriceData.price *
							  (derivedFxRateMap.get(asset.yahooSymbol!) ?? getFxRateToEur(historicalPriceData.currency))
							: null;

						// Calculate return and period
						let compoundedReturnAsset: number | null = null;
						let annualizedReturnAsset: number | null = null;
						let periodYearsAsset: number | null = null;
						let absoluteReturnAsset: number | null = null;

						if (currentPrice !== null && quantity > 0) {
							const currentValue = currentPrice * quantity;

							if (isAllPeriodForAssets) {
								// For "All" period: absolute return = current value - cost basis
								absoluteReturnAsset = Math.round((currentValue - costBasisEur) * 100) / 100;
							} else if (historicalPrice !== null) {
								// For other periods: absolute return = current value - historical value
								const historicalValue = historicalPrice * quantity;
								absoluteReturnAsset = Math.round((currentValue - historicalValue) * 100) / 100;
							}

							if (historicalPrice !== null && historicalPrice > 0) {
								const simpleReturn = (currentPrice - historicalPrice) / historicalPrice;
								compoundedReturnAsset = Math.round(simpleReturn * 10000) / 100; // Convert to %

								// Calculate period in years for annualization
								const startDateObj = new Date(effectiveStartDate!);
								const endDateObj = new Date(todayStr);
								const periodMs = endDateObj.getTime() - startDateObj.getTime();
								periodYearsAsset = periodMs / (365.25 * 24 * 60 * 60 * 1000);

								// Annualize if period > 0
								if (periodYearsAsset > 0) {
									const annualized = Math.pow(1 + simpleReturn, 1 / periodYearsAsset) - 1;
									annualizedReturnAsset = Math.round(annualized * 10000) / 100;
								} else {
									annualizedReturnAsset = compoundedReturnAsset;
								}
							}
						}

						periodAssetReturns[isin] = {
							isin,
							ticker: asset.ticker,
							currentPrice,
							historicalPrice,
							absoluteReturn: absoluteReturnAsset,
							compoundedReturn: compoundedReturnAsset,
							annualizedReturn: annualizedReturnAsset,
							periodYears: periodYearsAsset !== null ? Math.round(periodYearsAsset * 100) / 100 : null,
							isShortHolding,
							holdingPeriodLabel: isShortHolding && periodYearsAsset !== null
								? formatPeriodLabel(periodYearsAsset)
								: null,
							// Legacy field
							returnPercent: compoundedReturnAsset
						};
					}

					assetReturns[period] = periodAssetReturns;
				}
			}

			return {
				returns,
				currentValue,
				assetReturns
			};
		})
});

// Chart data types
export interface ChartDataPoint {
	date: string; // YYYY-MM-DD
	investedValue: number;
	costBasis: number;
}

export interface ChartDataResult {
	dataPoints: ChartDataPoint[];
	hasData: boolean;
}

// Historical returns types
export type ReturnPeriod = 'today' | '1w' | '1m' | '6m' | 'ytd' | '1y' | 'all';

export interface PeriodReturn {
	period: ReturnPeriod;
	currentValue: number;
	startValue: number; // Portfolio value at period start (renamed from comparisonValue)
	absoluteReturn: number; // Profit = Current - Start - Net Deposits
	compoundedReturn: number; // Total % return over period (MWR)
	annualizedReturn: number; // % per year (p.a.)
	periodYears: number; // Length of period in years
	comparisonDate: string; // The date used for comparison
	netCashFlow: number; // Net deposits/withdrawals in period
	cashFlowCount: number; // Number of cash flows in the period
	// Legacy fields for backwards compatibility
	percentageReturn: number; // alias for compoundedReturn
	comparisonValue: number; // alias for startValue
}

// Per-asset return for a specific period
export interface AssetPeriodReturn {
	isin: string;
	ticker: string;
	currentPrice: number | null;
	historicalPrice: number | null;
	absoluteReturn: number | null; // Profit/loss in EUR for the period
	compoundedReturn: number | null; // Total % return over period
	annualizedReturn: number | null; // % per year (p.a.)
	periodYears: number | null; // Actual period used (may be < selected if short holding)
	isShortHolding: boolean; // True if using inception instead of selected period
	holdingPeriodLabel: string | null; // "6mo", "3mo", etc. if short holding
	// Legacy field for backwards compatibility
	returnPercent: number | null; // alias for compoundedReturn
}

export interface HistoricalReturnsResult {
	returns: Partial<Record<ReturnPeriod, PeriodReturn>>;
	currentValue: number;
	// Per-asset returns for each period (keyed by period, then by ISIN)
	assetReturns: Partial<Record<ReturnPeriod, Record<string, AssetPeriodReturn>>>;
}

// Cash flow for TWR calculation
interface CashFlow {
	date: string; // YYYY-MM-DD
	amount: number; // Positive for buys (inflows), negative for sells (outflows)
}

/**
 * Calculate Time-Weighted Return (TWR) for a period.
 *
 * TWR neutralizes the impact of cash flows by:
 * 1. Breaking the period into sub-periods at each cash flow
 * 2. Calculating return for each sub-period
 * 3. Geometrically linking the sub-period returns
 *
 * Formula: TWR = [(1 + R1) × (1 + R2) × ... × (1 + Rn)] - 1
 * Where Ri = (Ending Value - Beginning Value) / Beginning Value
 */
function calculateTWR(
	startDate: string,
	endDate: string,
	cashFlows: CashFlow[],
	getPortfolioValueAtDate: (date: string) => number
): { twr: number; cashFlowCount: number } {
	// Filter and sort cash flows within the range (exclusive start, inclusive end)
	const flowsInRange = cashFlows
		.filter((cf) => cf.date > startDate && cf.date <= endDate)
		.sort((a, b) => a.date.localeCompare(b.date));

	// If no cash flows, use simple return
	if (flowsInRange.length === 0) {
		const startValue = getPortfolioValueAtDate(startDate);
		const endValue = getPortfolioValueAtDate(endDate);
		if (startValue <= 0) return { twr: 0, cashFlowCount: 0 };
		return { twr: (endValue - startValue) / startValue, cashFlowCount: 0 };
	}

	// Group cash flows by date (in case multiple orders on same day)
	const flowsByDate = new Map<string, number>();
	for (const flow of flowsInRange) {
		flowsByDate.set(flow.date, (flowsByDate.get(flow.date) ?? 0) + flow.amount);
	}

	const uniqueDates = Array.from(flowsByDate.keys()).sort();

	// Helper: get previous date (subtract one day)
	function getPreviousDate(dateStr: string): string {
		const date = new Date(dateStr);
		date.setDate(date.getDate() - 1);
		return date.toISOString().split('T')[0];
	}

	// Calculate sub-period returns
	let twrProduct = 1;
	let subPeriodStart = startDate;
	let subPeriodStartValue = getPortfolioValueAtDate(startDate);

	for (const flowDate of uniqueDates) {
		// Get value at the END of the day BEFORE the cash flow
		// This represents the portfolio value just before the cash flow happens
		const dayBefore = getPreviousDate(flowDate);
		const valueBeforeFlow =
			dayBefore >= subPeriodStart
				? getPortfolioValueAtDate(dayBefore)
				: subPeriodStartValue;

		// Calculate sub-period return
		if (subPeriodStartValue > 0) {
			const subReturn = (valueBeforeFlow - subPeriodStartValue) / subPeriodStartValue;
			twrProduct *= 1 + subReturn;
		}

		// New starting value for next sub-period
		// After the cash flow, the portfolio value is: previous value + cash flow amount
		const cashFlowAmount = flowsByDate.get(flowDate)!;
		subPeriodStartValue = valueBeforeFlow + cashFlowAmount;
		subPeriodStart = flowDate;
	}

	// Final sub-period (from last cash flow to end date)
	const endValue = getPortfolioValueAtDate(endDate);
	if (subPeriodStartValue > 0) {
		const finalReturn = (endValue - subPeriodStartValue) / subPeriodStartValue;
		twrProduct *= 1 + finalReturn;
	}

	return {
		twr: twrProduct - 1,
		cashFlowCount: flowsInRange.length
	};
}

/**
 * Calculate Money-Weighted Return (MWR) using XIRR for a period.
 *
 * MWR (also called XIRR) finds the constant annual rate of return that would
 * produce the actual profit, given when money was added/removed.
 *
 * This gives users their actual rate of return on their money.
 *
 * @returns annualizedReturn - the annual rate (e.g., 0.085 for 8.5% p.a.)
 *          compoundedReturn - the total return over the period ((1 + annual)^years - 1)
 *          netCashFlow - total deposits minus withdrawals
 */
function calculateMWR(
	startDate: string,
	endDate: string,
	startValue: number,
	endValue: number,
	cashFlows: CashFlow[]
): {
	annualizedReturn: number;
	compoundedReturn: number;
	netCashFlow: number;
	cashFlowCount: number;
	periodYears: number;
} {
	// Filter cash flows within the range (exclusive start, inclusive end)
	const flowsInRange = cashFlows
		.filter((cf) => cf.date > startDate && cf.date <= endDate)
		.sort((a, b) => a.date.localeCompare(b.date));

	// Calculate period in years
	const startDateObj = new Date(startDate);
	const endDateObj = new Date(endDate);
	const periodMs = endDateObj.getTime() - startDateObj.getTime();
	const periodYears = periodMs / (365.25 * 24 * 60 * 60 * 1000);

	// Calculate net cash flow
	const netCashFlow = flowsInRange.reduce((sum, cf) => sum + cf.amount, 0);

	// Edge case: very short period (< 1 day) - use simple return
	if (periodYears < 1 / 365) {
		const simpleReturn = startValue > 0 ? (endValue - startValue - netCashFlow) / startValue : 0;
		return {
			annualizedReturn: simpleReturn,
			compoundedReturn: simpleReturn,
			netCashFlow,
			cashFlowCount: flowsInRange.length,
			periodYears
		};
	}

	// Edge case: no start value - can't calculate return
	if (startValue <= 0) {
		return {
			annualizedReturn: 0,
			compoundedReturn: 0,
			netCashFlow,
			cashFlowCount: flowsInRange.length,
			periodYears
		};
	}

	// If no cash flows, use simple annualized return
	if (flowsInRange.length === 0) {
		const simpleReturn = (endValue - startValue) / startValue;
		// Annualize: (1 + total)^(1/years) - 1
		const annualized = periodYears > 0 ? Math.pow(1 + simpleReturn, 1 / periodYears) - 1 : simpleReturn;
		return {
			annualizedReturn: annualized,
			compoundedReturn: simpleReturn,
			netCashFlow: 0,
			cashFlowCount: 0,
			periodYears
		};
	}

	// Build XIRR transactions
	// Convention: outflows (money invested) are negative, inflows (money received) are positive
	const transactions: Array<{ amount: number; when: Date }> = [];

	// Starting value as initial outflow (we "bought" the portfolio at start)
	transactions.push({
		amount: -startValue,
		when: startDateObj
	});

	// Cash flows during period
	// Buys (positive in our CashFlow) = money going into portfolio = outflow for XIRR = negative
	// Sells (negative in our CashFlow) = money coming from portfolio = inflow for XIRR = positive
	for (const cf of flowsInRange) {
		transactions.push({
			amount: -cf.amount, // Negate: our convention is opposite to XIRR
			when: new Date(cf.date)
		});
	}

	// Ending value as final inflow (we "sold" the portfolio at end)
	transactions.push({
		amount: endValue,
		when: endDateObj
	});

	try {
		// XIRR returns annualized rate directly
		const annualizedReturn = xirr(transactions);

		// Calculate compounded return: (1 + annual)^years - 1
		const compoundedReturn = Math.pow(1 + annualizedReturn, periodYears) - 1;

		return {
			annualizedReturn,
			compoundedReturn,
			netCashFlow,
			cashFlowCount: flowsInRange.length,
			periodYears
		};
	} catch {
		// XIRR failed to converge - fall back to simple return
		const simpleReturn = (endValue - startValue - netCashFlow) / startValue;
		const annualized = periodYears > 0 ? Math.pow(1 + simpleReturn, 1 / periodYears) - 1 : simpleReturn;
		return {
			annualizedReturn: annualized,
			compoundedReturn: simpleReturn,
			netCashFlow,
			cashFlowCount: flowsInRange.length,
			periodYears
		};
	}
}

/**
 * Helper: format a period duration for display
 * Returns "1d", "2w", "1mo", "3mo", "6mo", "1y", etc.
 */
function formatPeriodLabel(years: number): string {
	const days = Math.round(years * 365.25);
	if (days < 7) return `${days}d`;
	if (days < 30) return `${Math.round(days / 7)}w`;
	if (days < 365) return `${Math.round(days / 30)}mo`;
	return `${(years).toFixed(1)}y`;
}
