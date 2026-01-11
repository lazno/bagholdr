export declare function createContext(): {
    db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
        $client: import("better-sqlite3").Database;
    };
};
export type Context = ReturnType<typeof createContext>;
