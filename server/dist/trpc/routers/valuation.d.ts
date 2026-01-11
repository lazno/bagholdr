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
import type { AssetType } from '../../db/schema';
import { type BandConfig, type Band, type AllocationStatus } from '../../utils/bands';
export interface AssetValuation {
    isin: string;
    ticker: string;
    name: string;
    assetType: AssetType;
    quantity: number;
    priceEur: number | null;
    costBasisEur: number;
    valueEur: number;
    usingCostBasis: boolean;
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
    directAssets: AssetValuation[];
    directValueEur: number;
    totalValueEur: number;
    actualPercentInvested: number;
    actualPercentTotal: number;
    band: Band;
    status: AllocationStatus;
    deltaPercent: number;
    actualPercent: number;
    assets: AssetValuation[];
    actualValueEur: number;
}
export interface PortfolioValuation {
    portfolioId: string;
    portfolioName: string;
    cashEur: number;
    totalHoldingsValueEur: number;
    assignedHoldingsValueEur: number;
    unassignedValueEur: number;
    investedValueEur: number;
    totalValueEur: number;
    sleeves: SleeveAllocation[];
    unassignedAssets: AssetValuation[];
    bandConfig: BandConfig;
    violationCount: number;
    hasAllPrices: boolean;
    concentrationViolations: ConcentrationViolation[];
    concentrationViolationCount: number;
    totalViolationCount: number;
    allocatableValueEur: number;
}
export declare const valuationRouter: import("@trpc/server").TRPCBuiltRouter<{
    ctx: {
        db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../../db/schema")> & {
            $client: import("better-sqlite3").Database;
        };
    };
    meta: object;
    errorShape: import("@trpc/server").TRPCDefaultErrorShape;
    transformer: false;
}, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
    /**
     * Get full portfolio valuation with allocation breakdown
     */
    getPortfolioValuation: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            portfolioId: string;
        };
        output: PortfolioValuation;
        meta: object;
    }>;
}>>;
