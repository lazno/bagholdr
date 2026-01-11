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
import { eq, gt } from 'drizzle-orm';
import { router, publicProcedure } from '../trpc';
import {
	holdings,
	assets,
	sleeves,
	sleeveAssets,
	portfolios,
	priceCache,
	portfolioRules,
	globalCash
} from '$lib/server/db/schema';
import type { Sleeve, AssetType, ConcentrationLimitConfig, PortfolioRule } from '$lib/server/db/schema';
import {
	calculateBand,
	evaluateStatus,
	type BandConfig,
	type Band,
	type AllocationStatus
} from '$lib/utils/bands';

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

	// Sleeves (excluding cash sleeves)
	sleeves: SleeveAllocation[];

	// Unassigned assets
	unassignedAssets: AssetValuation[];

	// Band configuration
	bandConfig: BandConfig;

	// Summary - sleeve band violations
	violationCount: number; // Number of sleeves with status='warning'
	hasAllPrices: boolean;

	// Concentration rule violations
	concentrationViolations: ConcentrationViolation[];
	concentrationViolationCount: number;

	// Total rule violations (sleeves + concentration)
	totalViolationCount: number;

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

			// Get all holdings with assets (only those with quantity > 0)
			const allHoldings = await ctx.db
				.select({
					holding: holdings,
					asset: assets
				})
				.from(holdings)
				.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
				.where(gt(holdings.quantity, 0));

			// Get cached prices - use yahooSymbol for lookup
			const cachedPrices = await ctx.db.select().from(priceCache);
			const priceMap = new Map(cachedPrices.map((p) => [p.ticker, p.priceEur]));

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

			// Build asset valuations (we'll add percentOfInvested after calculating totals)
			const assetValuationsPartial = allHoldings.map((h) => {
				// Look up price by yahooSymbol if available, otherwise fall back to broker ticker
				const lookupKey = h.asset.yahooSymbol ?? h.asset.ticker;
				const cachedPrice = priceMap.get(lookupKey);
				const usingCostBasis = cachedPrice === undefined;
				const priceEur = cachedPrice ?? null;

				// Value: use price * quantity if we have price, else use cost basis
				const valueEur =
					priceEur !== null ? priceEur * h.holding.quantity : h.holding.totalCostEur;

				return {
					isin: h.asset.isin,
					ticker: h.asset.ticker,
					name: h.asset.name,
					assetType: h.asset.assetType as AssetType,
					quantity: h.holding.quantity,
					priceEur,
					costBasisEur: h.holding.totalCostEur,
					valueEur,
					usingCostBasis
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
				sleeves: sleeveAllocations,
				unassignedAssets,
				bandConfig,
				violationCount,
				hasAllPrices,
				concentrationViolations,
				concentrationViolationCount,
				totalViolationCount,
				// Legacy field
				allocatableValueEur: investedValueEur
			};
		})
});
