export declare const appRouter: import("@trpc/server").TRPCBuiltRouter<{
    ctx: {
        db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
            $client: import("better-sqlite3").Database;
        };
    };
    meta: object;
    errorShape: import("@trpc/server").TRPCDefaultErrorShape;
    transformer: false;
}, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
    portfolios: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
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
                id: string;
                name: string;
                bandRelativeTolerance: number;
                bandAbsoluteFloor: number;
                bandAbsoluteCap: number;
                createdAt: Date;
                updatedAt: Date;
            }[];
            meta: object;
        }>;
        get: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                id: string;
            };
            output: {
                id: string;
                name: string;
                bandRelativeTolerance: number;
                bandAbsoluteFloor: number;
                bandAbsoluteCap: number;
                createdAt: Date;
                updatedAt: Date;
            };
            meta: object;
        }>;
        create: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                name: string;
            };
            output: {
                id: string;
            };
            meta: object;
        }>;
        update: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                id: string;
                name?: string | undefined;
                bandRelativeTolerance?: number | undefined;
                bandAbsoluteFloor?: number | undefined;
                bandAbsoluteCap?: number | undefined;
            };
            output: {
                success: boolean;
            };
            meta: object;
        }>;
        delete: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                id: string;
            };
            output: {
                success: boolean;
            };
            meta: object;
        }>;
    }>>;
    assets: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
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
                metadata: import("../db/schema").AssetMetadata | null;
                yahooSymbol: string | null;
                archived: boolean;
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
                metadata: import("../db/schema").AssetMetadata | null;
                yahooSymbol: string | null;
                archived: boolean;
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
                metadata: import("../db/schema").AssetMetadata | null;
                yahooSymbol: string | null;
                archived: boolean;
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
        bulkUpdateType: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isins: string[];
                assetType: "stock" | "etf" | "bond" | "fund" | "commodity" | "other";
            };
            output: {
                success: boolean;
                updatedCount: number;
            };
            meta: object;
        }>;
        setArchived: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isin: string;
                archived: boolean;
            };
            output: {
                success: boolean;
                archived: boolean;
            };
            meta: object;
        }>;
        bulkSetArchived: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isins: string[];
                archived: boolean;
            };
            output: {
                success: boolean;
                updatedCount: number;
                archived: boolean;
            };
            meta: object;
        }>;
    }>>;
    holdings: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
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
                    metadata: import("../db/schema").AssetMetadata | null;
                    yahooSymbol: string | null;
                    archived: boolean;
                };
                id: string;
                assetIsin: string;
                quantity: number;
                totalCostEur: number;
            }[];
            meta: object;
        }>;
        getTotalCostBasis: import("@trpc/server").TRPCQueryProcedure<{
            input: void;
            output: {
                totalCostEur: number;
                holdingsCount: number;
            };
            meta: object;
        }>;
    }>>;
    import: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
                $client: import("better-sqlite3").Database;
            };
        };
        meta: object;
        errorShape: import("@trpc/server").TRPCDefaultErrorShape;
        transformer: false;
    }, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
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
                orders: import("../import/directa-parser").ParsedOrder[];
            };
            meta: object;
        }>;
        confirmImport: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                orders: {
                    isin: string;
                    ticker: string;
                    name: string;
                    transactionDate: unknown;
                    transactionType: "Buy" | "Sell" | "Commission";
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
    oracle: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
                $client: import("better-sqlite3").Database;
            };
        };
        meta: object;
        errorShape: import("@trpc/server").TRPCDefaultErrorShape;
        transformer: false;
    }, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
        getPrice: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                isin: string;
            };
            output: import("../oracle/cache").CachedPrice;
            meta: object;
        }>;
        getAllPrices: import("@trpc/server").TRPCQueryProcedure<{
            input: void;
            output: {
                prices: {
                    isin: string;
                    ticker: string;
                    yahooSymbol: string | null;
                    name: string;
                    quantity: number;
                    priceEur: number;
                    valueEur: number;
                    currency: string;
                    fromCache: boolean;
                    fetchedAt: Date | null;
                    error?: string;
                }[];
                totalValueEur: number;
                fetchedCount: number;
                cachedCount: number;
                errorCount: number;
            };
            meta: object;
        }>;
        refreshAllPrices: import("@trpc/server").TRPCMutationProcedure<{
            input: void;
            output: {
                successCount: number;
                errorCount: number;
                resolvedCount: number;
                errors: {
                    isin: string;
                    error: string;
                }[];
            };
            meta: object;
        }>;
        getFxRate: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                from: string;
                to: string;
            };
            output: import("../oracle/cache").CachedFxRate;
            meta: object;
        }>;
        resolveYahooSymbols: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isin: string;
            };
            output: {
                symbols: {
                    symbol: string;
                    exchange?: string;
                    exchangeDisplay?: string;
                    quoteType?: string;
                    shortname?: string;
                    id: `${string}-${string}-${string}-${string}-${string}`;
                }[];
                selectedSymbol: string;
            };
            meta: object;
        }>;
        getYahooSymbols: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                isin: string;
            };
            output: {
                selectedSymbol: string | null;
                symbols: {
                    id: string;
                    assetIsin: string;
                    symbol: string;
                    exchange: string | null;
                    exchangeDisplay: string | null;
                    quoteType: string | null;
                    resolvedAt: Date;
                }[];
            };
            meta: object;
        }>;
        setYahooSymbol: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isin: string;
                symbol: string | null;
            };
            output: {
                success: boolean;
            };
            meta: object;
        }>;
        getStaleAssets: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                maxAgeMs?: number | undefined;
            } | undefined;
            output: {
                staleAssets: {
                    isin: string;
                    yahooSymbol: string;
                    name: string;
                    lastFetchedAt: Date | null;
                    ageMs: number | null;
                }[];
                totalHeld: number;
            };
            meta: object;
        }>;
        refreshSinglePrice: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isin: string;
            };
            output: {
                success: boolean;
                isin: string;
                priceEur: number;
                fromCache: boolean;
                error?: undefined;
            } | {
                success: boolean;
                isin: string;
                error: string;
                priceEur?: undefined;
                fromCache?: undefined;
            };
            meta: object;
        }>;
        getCacheStatus: import("@trpc/server").TRPCQueryProcedure<{
            input: void;
            output: {
                pricesCached: number;
                fxRatesCached: number;
                prices: {
                    ticker: string;
                    fetchedAt: Date;
                }[];
                fxRates: {
                    pair: string;
                    fetchedAt: Date;
                }[];
            };
            meta: object;
        }>;
        clearExpiredCache: import("@trpc/server").TRPCMutationProcedure<{
            input: void;
            output: {
                pricesCleared: number;
                fxCleared: number;
            };
            meta: object;
        }>;
        clearAllHistoricalData: import("@trpc/server").TRPCMutationProcedure<{
            input: void;
            output: {
                dailyPricesDeleted: number;
                intradayPricesDeleted: number;
                dividendsDeleted: number;
                message: string;
            };
            meta: object;
        }>;
        clearHistoricalDataForAsset: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isin: string;
            };
            output: {
                dailyPricesDeleted: number;
                intradayPricesDeleted: number;
                dividendsDeleted: number;
                message: string;
                ticker?: undefined;
            } | {
                ticker: string;
                dailyPricesDeleted: number;
                intradayPricesDeleted: number;
                dividendsDeleted: number;
                message: string;
            };
            meta: object;
        }>;
        getHistoricalPrices: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                isin: string;
                startDate?: string | undefined;
                endDate?: string | undefined;
            };
            output: {
                isin: string;
                ticker: string;
                candles: import("../oracle/historical").DailyPriceRecord[];
            };
            meta: object;
        }>;
        syncHistoricalData: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isin: string;
            };
            output: {
                isin: string;
                ticker: string;
                candlesUpserted: number;
                dividendsUpserted: number;
                latestDate: string | null;
            };
            meta: object;
        }>;
        getDividends: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                isin: string;
                startDate?: string | undefined;
            };
            output: {
                isin: string;
                dividends: never[];
                ticker?: undefined;
            } | {
                isin: string;
                ticker: string;
                dividends: {
                    exDate: string;
                    amount: number;
                    currency: string;
                }[];
            };
            meta: object;
        }>;
        getTickersNeedingHistoricalSync: import("@trpc/server").TRPCQueryProcedure<{
            input: void;
            output: {
                tickers: {
                    ticker: string;
                    isin: string | null;
                }[];
                totalWithSymbol: number;
            };
            meta: object;
        }>;
        needsHistoricalSync: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                isin: string;
            };
            output: {
                needsSync: boolean;
                reason: string;
            };
            meta: object;
        }>;
        getIntradayPrices: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                isin: string;
            };
            output: {
                isin: string;
                ticker: string;
                candles: import("../oracle/historical").IntradayPriceRecord[];
            };
            meta: object;
        }>;
        syncIntradayData: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                isin: string;
            };
            output: {
                isin: string;
                ticker: string;
                candlesUpserted: number;
                candlesPurged: number;
            };
            meta: object;
        }>;
        needsIntradaySync: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                isin: string;
            };
            output: {
                needsSync: boolean;
                reason: string;
            };
            meta: object;
        }>;
        getTickersNeedingIntradaySync: import("@trpc/server").TRPCQueryProcedure<{
            input: void;
            output: {
                tickers: {
                    ticker: string;
                    isin: string | null;
                }[];
                totalWithSymbol: number;
            };
            meta: object;
        }>;
        getSyncStatus: import("@trpc/server").TRPCQueryProcedure<{
            input: void;
            output: {
                isSyncing: boolean;
            };
            meta: object;
        }>;
        triggerPriceSync: import("@trpc/server").TRPCMutationProcedure<{
            input: void;
            output: {
                started: boolean;
                reason?: string;
            };
            meta: object;
        }>;
        onEvent: import("node_modules/@trpc/server/dist/unstable-core-do-not-import.d-CjQPvBRI.mjs").LegacyObservableSubscriptionProcedure<{
            input: void;
            output: import("../events").ServerEvent;
            meta: object;
        }>;
    }>>;
    sleeves: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
                $client: import("better-sqlite3").Database;
            };
        };
        meta: object;
        errorShape: import("@trpc/server").TRPCDefaultErrorShape;
        transformer: false;
    }, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
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
                    metadata: import("../db/schema").AssetMetadata | null;
                    yahooSymbol: string | null;
                    archived: boolean;
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
                    metadata: import("../db/schema").AssetMetadata | null;
                    yahooSymbol: string | null;
                    archived: boolean;
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
    valuation: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
                $client: import("better-sqlite3").Database;
            };
        };
        meta: object;
        errorShape: import("@trpc/server").TRPCDefaultErrorShape;
        transformer: false;
    }, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
        getPortfolioValuation: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                portfolioId: string;
            };
            output: import("./routers/valuation").PortfolioValuation;
            meta: object;
        }>;
        getChartData: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                portfolioId: string;
                range?: "all" | "1y" | "1m" | "3m" | "6m" | undefined;
            };
            output: import("./routers/valuation").ChartDataResult;
            meta: object;
        }>;
        getHistoricalReturns: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                portfolioId: string;
            };
            output: import("./routers/valuation").HistoricalReturnsResult;
            meta: object;
        }>;
    }>>;
    rules: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
                $client: import("better-sqlite3").Database;
            };
        };
        meta: object;
        errorShape: import("@trpc/server").TRPCDefaultErrorShape;
        transformer: false;
    }, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
        list: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                portfolioId: string;
            };
            output: {
                id: string;
                portfolioId: string;
                ruleType: string;
                name: string;
                config: import("../db/schema").ConcentrationLimitConfig;
                enabled: boolean;
                createdAt: Date;
            }[];
            meta: object;
        }>;
        get: import("@trpc/server").TRPCQueryProcedure<{
            input: {
                id: string;
            };
            output: {
                id: string;
                portfolioId: string;
                ruleType: string;
                name: string;
                config: import("../db/schema").ConcentrationLimitConfig;
                enabled: boolean;
                createdAt: Date;
            };
            meta: object;
        }>;
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
        delete: import("@trpc/server").TRPCMutationProcedure<{
            input: {
                id: string;
            };
            output: {
                success: boolean;
            };
            meta: object;
        }>;
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
    cash: import("@trpc/server").TRPCBuiltRouter<{
        ctx: {
            db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../db/schema")> & {
                $client: import("better-sqlite3").Database;
            };
        };
        meta: object;
        errorShape: import("@trpc/server").TRPCDefaultErrorShape;
        transformer: false;
    }, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
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
}>>;
export type AppRouter = typeof appRouter;
