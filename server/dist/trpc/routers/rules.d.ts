import type { ConcentrationLimitConfig } from '../../db/schema';
export declare const rulesRouter: import("@trpc/server").TRPCBuiltRouter<{
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
     * List all rules for a portfolio
     */
    list: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            portfolioId: string;
        };
        output: {
            id: string;
            portfolioId: string;
            ruleType: string;
            name: string;
            config: ConcentrationLimitConfig;
            enabled: boolean;
            createdAt: Date;
        }[];
        meta: object;
    }>;
    /**
     * Get a single rule by ID
     */
    get: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            id: string;
        };
        output: {
            id: string;
            portfolioId: string;
            ruleType: string;
            name: string;
            config: ConcentrationLimitConfig;
            enabled: boolean;
            createdAt: Date;
        };
        meta: object;
    }>;
    /**
     * Create a concentration limit rule
     */
    createConcentrationLimit: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            portfolioId: string;
            name: string;
            config: {
                maxPercent: number;
                assetTypes?: ("stock" | "etf" | "bond" | "fund" | "commodity" | "other")[] | undefined;
            };
        };
        output: {
            id: string;
        };
        meta: object;
    }>;
    /**
     * Update a rule
     */
    update: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            id: string;
            name?: string | undefined;
            config?: {
                maxPercent: number;
                assetTypes?: ("stock" | "etf" | "bond" | "fund" | "commodity" | "other")[] | undefined;
            } | undefined;
            enabled?: boolean | undefined;
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
    /**
     * Delete a rule
     */
    delete: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            id: string;
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
    /**
     * Toggle a rule's enabled state
     */
    toggle: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            id: string;
        };
        output: {
            enabled: boolean;
        };
        meta: object;
    }>;
}>>;
