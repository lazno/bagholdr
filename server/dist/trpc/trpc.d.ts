export declare const router: import("@trpc/server").TRPCRouterBuilder<{
    ctx: {
        db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
            $client: import("better-sqlite3").Database;
        };
    };
    meta: object;
    errorShape: import("@trpc/server").TRPCDefaultErrorShape;
    transformer: false;
}>;
export declare const publicProcedure: import("@trpc/server").TRPCProcedureBuilder<{
    db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
        $client: import("better-sqlite3").Database;
    };
}, object, object, import("@trpc/server").TRPCUnsetMarker, import("@trpc/server").TRPCUnsetMarker, import("@trpc/server").TRPCUnsetMarker, import("@trpc/server").TRPCUnsetMarker, false>;
export declare const middleware: <$ContextOverrides>(fn: import("@trpc/server").TRPCMiddlewareFunction<{
    db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
        $client: import("better-sqlite3").Database;
    };
}, object, object, $ContextOverrides, unknown>) => import("@trpc/server").TRPCMiddlewareBuilder<{
    db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
        $client: import("better-sqlite3").Database;
    };
}, object, $ContextOverrides, unknown>;
