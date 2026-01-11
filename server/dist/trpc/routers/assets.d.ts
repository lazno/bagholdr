export declare const assetsRouter: import("@trpc/server").TRPCBuiltRouter<{
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
        input: {
            includeSold?: boolean | undefined;
        } | undefined;
        output: {
            isin: string;
            ticker: string;
            name: string;
            description: string | null;
            assetType: "stock" | "etf" | "bond" | "fund" | "commodity" | "other";
            currency: string;
            metadata: import("../../db/schema").AssetMetadata | null;
            yahooSymbol: string | null;
        }[];
        meta: object;
    }>;
    listWithHoldings: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            includeSold?: boolean | undefined;
        } | undefined;
        output: {
            quantity: number;
            totalCostEur: number;
            isin: string;
            ticker: string;
            name: string;
            description: string | null;
            assetType: "stock" | "etf" | "bond" | "fund" | "commodity" | "other";
            currency: string;
            metadata: import("../../db/schema").AssetMetadata | null;
            yahooSymbol: string | null;
        }[];
        meta: object;
    }>;
    get: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
        };
        output: {
            isin: string;
            ticker: string;
            name: string;
            description: string | null;
            assetType: "stock" | "etf" | "bond" | "fund" | "commodity" | "other";
            currency: string;
            metadata: import("../../db/schema").AssetMetadata | null;
            yahooSymbol: string | null;
        };
        meta: object;
    }>;
    update: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            isin: string;
            ticker?: string | undefined;
            name?: string | undefined;
            description?: string | undefined;
            assetType?: "stock" | "etf" | "bond" | "fund" | "commodity" | "other" | undefined;
            currency?: string | undefined;
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
}>>;
