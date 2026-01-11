export declare const cashRouter: import("@trpc/server").TRPCBuiltRouter<{
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
     * Get current cash balance
     */
    get: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            id: string;
            amountEur: number;
            updatedAt: Date;
        } | {
            amountEur: number;
            updatedAt: Date;
        };
        meta: object;
    }>;
    /**
     * Set cash balance
     */
    set: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            amountEur: number;
        };
        output: {
            amountEur: number;
            updatedAt: Date;
        };
        meta: object;
    }>;
}>>;
