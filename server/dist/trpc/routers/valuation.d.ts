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
export interface OrderDetail {
    date: string;
    type: 'buy' | 'sell' | 'commission';
    quantity: number;
    totalNative: number;
    totalEur: number;
    pricePerShareNative: number | null;
    pricePerShareEur: number | null;
    impliedFxRate: number | null;
}
export interface CalculationApproaches {
    avgPriceNative_fromNative: number;
    avgPriceNative_fromEurViaImpliedFx: number;
    avgPriceNative_fromEurViaCurrentFx: number | null;
    impliedFxRate: number | null;
    currentFxRate: number | null;
}
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
    currency: string;
    priceNative: number | null;
    costBasisNative: number;
    impliedHistoricalFxRate: number | null;
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
    totalCostBasisEur: number;
    sleeves: SleeveAllocation[];
    unassignedAssets: AssetValuation[];
    bandConfig: BandConfig;
    violationCount: number;
    hasAllPrices: boolean;
    missingSymbolAssets: MissingSymbolAsset[];
    stalePriceAssets: StalePriceAsset[];
    stalePriceThresholdHours: number;
    concentrationViolations: ConcentrationViolation[];
    concentrationViolationCount: number;
    totalViolationCount: number;
    lastSyncAt: Date | null;
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
    /**
     * Get historical chart data for portfolio value visualization.
     * Returns daily data points with portfolio value and cost basis over time.
     */
    getChartData: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            portfolioId: string;
            range?: "all" | "1y" | "1m" | "3m" | "6m" | undefined;
        };
        output: ChartDataResult;
        meta: object;
    }>;
    /**
     * Get historical returns for different time periods.
     * Calculates portfolio value at historical dates and compares to current value.
     */
    getHistoricalReturns: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            portfolioId: string;
        };
        output: HistoricalReturnsResult;
        meta: object;
    }>;
}>>;
export interface ChartDataPoint {
    date: string;
    investedValue: number;
    costBasis: number;
}
export interface ChartDataResult {
    dataPoints: ChartDataPoint[];
    hasData: boolean;
}
export type ReturnPeriod = 'today' | '1w' | '1m' | '6m' | 'ytd' | '1y' | 'all';
export interface PeriodReturn {
    period: ReturnPeriod;
    currentValue: number;
    startValue: number;
    absoluteReturn: number;
    compoundedReturn: number;
    annualizedReturn: number;
    periodYears: number;
    comparisonDate: string;
    netCashFlow: number;
    cashFlowCount: number;
    percentageReturn: number;
    comparisonValue: number;
}
export interface AssetPeriodReturn {
    isin: string;
    ticker: string;
    currentPrice: number | null;
    historicalPrice: number | null;
    absoluteReturn: number | null;
    compoundedReturn: number | null;
    annualizedReturn: number | null;
    periodYears: number | null;
    isShortHolding: boolean;
    holdingPeriodLabel: string | null;
    returnPercent: number | null;
}
export interface HistoricalReturnsResult {
    returns: Partial<Record<ReturnPeriod, PeriodReturn>>;
    currentValue: number;
    assetReturns: Partial<Record<ReturnPeriod, Record<string, AssetPeriodReturn>>>;
}
