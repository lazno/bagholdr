export declare const sleevesRouter: import("@trpc/server").TRPCBuiltRouter<{
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
     * List all sleeves for a portfolio with hierarchy info
     * Note: Cash sleeves are filtered out - cash is handled separately
     */
    list: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            portfolioId: string;
        };
        output: {
            id: string;
            portfolioId: string;
            parentSleeveId: string | null;
            name: string;
            budgetPercent: number;
            sortOrder: number;
            isCash: boolean;
        }[];
        meta: object;
    }>;
    /**
     * Get a single sleeve with its assigned assets
     */
    get: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            id: string;
        };
        output: {
            assets: {
                isin: string;
                ticker: string;
                name: string;
                description: string | null;
                assetType: "stock" | "etf" | "bond" | "fund" | "commodity" | "other";
                currency: string;
                metadata: import("../../db/schema").AssetMetadata | null;
                yahooSymbol: string | null;
            }[];
            id: string;
            portfolioId: string;
            parentSleeveId: string | null;
            name: string;
            budgetPercent: number;
            sortOrder: number;
            isCash: boolean;
        };
        meta: object;
    }>;
    /**
     * Create a new sleeve
     * Note: After creation, sibling budgets may not sum to 100% - user must adjust
     */
    create: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            portfolioId: string;
            parentSleeveId: string | null;
            name: string;
            budgetPercent: number;
        };
        output: {
            id: string;
        };
        meta: object;
    }>;
    /**
     * Update a sleeve
     */
    update: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            id: string;
            name?: string | undefined;
            budgetPercent?: number | undefined;
            parentSleeveId?: string | null | undefined;
            sortOrder?: number | undefined;
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
    /**
     * Delete a sleeve, its sub-sleeves, and reassign assets to parent
     * - Assets from deleted sleeve are moved to parent sleeve (or unassigned if no parent)
     * - Sub-sleeves are recursively deleted
     */
    delete: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            id: string;
        };
        output: {
            success: boolean;
            deletedCount: number;
            assetsReassigned: number;
        };
        meta: object;
    }>;
    /**
     * Validate sibling budgets sum to 100%
     */
    validateBudgets: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            portfolioId: string;
            parentSleeveId: string | null;
        };
        output: {
            valid: boolean;
            total: number;
            siblings: Array<{
                id: string;
                name: string;
                budgetPercent: number;
            }>;
        };
        meta: object;
    }>;
    /**
     * Bulk update budgets for siblings
     * - Root level sleeves must sum to 100%
     * - Sub-sleeves must sum to their parent's budget
     */
    updateBudgets: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            budgets: {
                sleeveId: string;
                budgetPercent: number;
            }[];
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
    /**
     * Assign an asset to a sleeve
     */
    assignAsset: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            sleeveId: string;
            assetIsin: string;
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
    /**
     * Remove an asset from a sleeve (make it unassigned)
     */
    unassignAsset: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            sleeveId: string;
            assetIsin: string;
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
    /**
     * Get all assets with their sleeve assignments for a portfolio
     */
    getAssetAssignments: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            portfolioId: string;
        };
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
            holding: {
                id: string;
                assetIsin: string;
                quantity: number;
                totalCostEur: number;
            };
            sleeveId: string | null;
            sleeveName: string | null;
        }[];
        meta: object;
    }>;
}>>;
