import { type ParsedOrder } from '../../import/directa-parser';
export declare const importRouter: import("@trpc/server").TRPCBuiltRouter<{
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
     * Parse CSV content and return preview
     * Does not persist anything - just parses and returns what would be imported
     */
    parseCSV: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            content: string;
        };
        output: {
            accountName: string;
            totalOrders: number;
            skippedRows: number;
            errors: {
                line: number;
                message: string;
            }[];
            assetSummaries: {
                isin: string;
                ticker: string;
                name: string;
                totalQuantity: number;
                totalAmountEur: number;
                buyCount: number;
                sellCount: number;
                orderCount: number;
            }[];
            orders: ParsedOrder[];
        };
        meta: object;
    }>;
    /**
     * Confirm import - persist orders and derive holdings
     * Skips orders with duplicate orderReference (already imported)
     */
    confirmImport: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            orders: {
                isin: string;
                ticker: string;
                name: string;
                transactionDate: unknown;
                transactionType: "Buy" | "Sell";
                quantity: number;
                amountEur: number;
                currencyAmount: number;
                currency: string;
                orderReference: string;
            }[];
        };
        output: {
            assetsCreated: number;
            ordersCreated: number;
            ordersReplaced: number;
            holdingsCount: number;
        };
        meta: object;
    }>;
}>>;
