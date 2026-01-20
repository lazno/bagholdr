BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "assets" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "isin" text NOT NULL,
    "ticker" text NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "assetType" text NOT NULL,
    "currency" text NOT NULL,
    "yahooSymbol" text,
    "metadata" text,
    "archived" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "asset_isin_idx" ON "assets" USING btree ("isin");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "daily_prices" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ticker" text NOT NULL,
    "date" text NOT NULL,
    "open" double precision NOT NULL,
    "high" double precision NOT NULL,
    "low" double precision NOT NULL,
    "close" double precision NOT NULL,
    "adjClose" double precision NOT NULL,
    "volume" bigint NOT NULL,
    "currency" text NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "daily_price_ticker_date_idx" ON "daily_prices" USING btree ("ticker", "date");
CREATE INDEX "daily_price_ticker_idx" ON "daily_prices" USING btree ("ticker");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "dividend_events" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ticker" text NOT NULL,
    "exDate" text NOT NULL,
    "amount" double precision NOT NULL,
    "currency" text NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "dividend_event_ticker_date_idx" ON "dividend_events" USING btree ("ticker", "exDate");
CREATE INDEX "dividend_event_ticker_idx" ON "dividend_events" USING btree ("ticker");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fx_cache" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "pair" text NOT NULL,
    "rate" double precision NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "fx_cache_pair_idx" ON "fx_cache" USING btree ("pair");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "global_cash" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "cashId" text NOT NULL,
    "amountEur" double precision NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "global_cash_id_idx" ON "global_cash" USING btree ("cashId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "holdings" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "assetId" uuid NOT NULL,
    "quantity" double precision NOT NULL,
    "totalCostEur" double precision NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "holding_asset_idx" ON "holdings" USING btree ("assetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "intraday_prices" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ticker" text NOT NULL,
    "timestamp" bigint NOT NULL,
    "open" double precision NOT NULL,
    "high" double precision NOT NULL,
    "low" double precision NOT NULL,
    "close" double precision NOT NULL,
    "volume" bigint NOT NULL,
    "currency" text NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "intraday_price_ticker_ts_idx" ON "intraday_prices" USING btree ("ticker", "timestamp");
CREATE INDEX "intraday_price_ticker_idx" ON "intraday_prices" USING btree ("ticker");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "orders" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "assetId" uuid NOT NULL,
    "orderDate" timestamp without time zone NOT NULL,
    "quantity" double precision NOT NULL,
    "priceNative" double precision NOT NULL,
    "totalNative" double precision NOT NULL,
    "totalEur" double precision NOT NULL,
    "currency" text NOT NULL,
    "orderReference" text,
    "importedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "order_asset_idx" ON "orders" USING btree ("assetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "portfolio_rules" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "portfolioId" uuid NOT NULL,
    "ruleType" text NOT NULL,
    "name" text NOT NULL,
    "config" text,
    "enabled" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "portfolio_rule_portfolio_idx" ON "portfolio_rules" USING btree ("portfolioId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "portfolios" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "bandRelativeTolerance" double precision NOT NULL,
    "bandAbsoluteFloor" double precision NOT NULL,
    "bandAbsoluteCap" double precision NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "price_cache" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ticker" text NOT NULL,
    "priceNative" double precision NOT NULL,
    "currency" text NOT NULL,
    "priceEur" double precision NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "price_cache_ticker_idx" ON "price_cache" USING btree ("ticker");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sleeve_assets" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "sleeveId" uuid NOT NULL,
    "assetId" uuid NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "sleeve_asset_unique_idx" ON "sleeve_assets" USING btree ("sleeveId", "assetId");
CREATE INDEX "sleeve_asset_sleeve_idx" ON "sleeve_assets" USING btree ("sleeveId");
CREATE INDEX "sleeve_asset_asset_idx" ON "sleeve_assets" USING btree ("assetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sleeves" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "portfolioId" uuid NOT NULL,
    "parentSleeveId" uuid,
    "name" text NOT NULL,
    "budgetPercent" double precision NOT NULL,
    "sortOrder" bigint NOT NULL,
    "isCash" boolean NOT NULL
);

-- Indexes
CREATE INDEX "sleeve_portfolio_idx" ON "sleeves" USING btree ("portfolioId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ticker_metadata" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ticker" text NOT NULL,
    "lastDailyDate" text,
    "lastSyncedAt" timestamp without time zone,
    "lastIntradaySyncedAt" timestamp without time zone,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "ticker_metadata_ticker_idx" ON "ticker_metadata" USING btree ("ticker");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "yahoo_symbols" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "assetId" uuid NOT NULL,
    "symbol" text NOT NULL,
    "exchange" text,
    "exchangeDisplay" text,
    "quoteType" text,
    "resolvedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "yahoo_symbol_asset_idx" ON "yahoo_symbols" USING btree ("assetId");
CREATE INDEX "yahoo_symbol_symbol_idx" ON "yahoo_symbols" USING btree ("symbol");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "holdings"
    ADD CONSTRAINT "holdings_fk_0"
    FOREIGN KEY("assetId")
    REFERENCES "assets"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "orders"
    ADD CONSTRAINT "orders_fk_0"
    FOREIGN KEY("assetId")
    REFERENCES "assets"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "portfolio_rules"
    ADD CONSTRAINT "portfolio_rules_fk_0"
    FOREIGN KEY("portfolioId")
    REFERENCES "portfolios"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sleeve_assets"
    ADD CONSTRAINT "sleeve_assets_fk_0"
    FOREIGN KEY("sleeveId")
    REFERENCES "sleeves"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sleeve_assets"
    ADD CONSTRAINT "sleeve_assets_fk_1"
    FOREIGN KEY("assetId")
    REFERENCES "assets"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sleeves"
    ADD CONSTRAINT "sleeves_fk_0"
    FOREIGN KEY("portfolioId")
    REFERENCES "portfolios"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sleeves"
    ADD CONSTRAINT "sleeves_fk_1"
    FOREIGN KEY("parentSleeveId")
    REFERENCES "sleeves"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "yahoo_symbols"
    ADD CONSTRAINT "yahoo_symbols_fk_0"
    FOREIGN KEY("assetId")
    REFERENCES "assets"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR bagholdr
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('bagholdr', '20260120195105638', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260120195105638', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
