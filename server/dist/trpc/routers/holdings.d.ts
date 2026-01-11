export declare const holdingsRouter: import("@trpc/server").TRPCBuiltRouter<{
    ctx: {
        db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../../db/schema")> & {
            $client: import("better-sqlite3").Database;
        };
    };
    meta: object;
    errorShape: import("@trpc/server").TRPCDefaultErrorShape;
    transformer: false;
}, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
    list: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            asset: {
                isin: string;
                ticker: string;
                name: string;
                description: string | null;
                assetType: "stock" | "etf" | "bond" | "fund" | "commodity" | "other";
                currency: string;
                metadata: import("../../db/schema").AssetMetadata | null;
                yahooSymbol: string | null;
            };
            id: string;
            assetIsin: string;
            quantity: number;
            totalCostEur: number;
        }[];
        meta: object;
    }>;
    /**
     * Get total portfolio value from holdings
     * Note: This is without prices - just quantity * cost basis
     * For market value, use the oracle to get current prices
     */
    getTotalCostBasis: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            totalCostEur: number;
            holdingsCount: number;
        };
        meta: object;
    }>;
}>>;
