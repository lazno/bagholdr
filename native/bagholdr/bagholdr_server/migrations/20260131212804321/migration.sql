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
-- ACTION CREATE TABLE: accounts
--
CREATE TABLE "accounts" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "accountType" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "account_name_idx" ON "accounts" USING btree ("name");

--
-- DATA MIGRATION: Create "Main Account" for existing data
--
INSERT INTO "accounts" ("id", "name", "accountType", "createdAt", "updatedAt")
VALUES (gen_random_uuid_v7(), 'Main Account', 'real', now(), now());

--
-- ACTION ALTER TABLE: Add accountId to orders (preserve existing data)
--
-- Step 1: Add nullable column
ALTER TABLE "orders" ADD COLUMN "accountId" uuid;

-- Step 2: Populate with Main Account ID
UPDATE "orders" SET "accountId" = (SELECT "id" FROM "accounts" WHERE "name" = 'Main Account' LIMIT 1);

-- Step 3: Make column NOT NULL
ALTER TABLE "orders" ALTER COLUMN "accountId" SET NOT NULL;

-- Step 4: Add index
CREATE INDEX "order_account_idx" ON "orders" USING btree ("accountId");

-- Step 5: Add foreign key
ALTER TABLE ONLY "orders"
    ADD CONSTRAINT "orders_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "accounts"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION ALTER TABLE: Add accountId to holdings (preserve existing data)
--
-- Step 1: Drop old unique index
DROP INDEX IF EXISTS "holding_asset_idx";

-- Step 2: Add nullable column
ALTER TABLE "holdings" ADD COLUMN "accountId" uuid;

-- Step 3: Populate with Main Account ID
UPDATE "holdings" SET "accountId" = (SELECT "id" FROM "accounts" WHERE "name" = 'Main Account' LIMIT 1);

-- Step 4: Make column NOT NULL
ALTER TABLE "holdings" ALTER COLUMN "accountId" SET NOT NULL;

-- Step 5: Create new unique index on (accountId, assetId)
CREATE UNIQUE INDEX "holding_account_asset_idx" ON "holdings" USING btree ("accountId", "assetId");

-- Step 6: Add foreign key
ALTER TABLE ONLY "holdings"
    ADD CONSTRAINT "holdings_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "accounts"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE TABLE: portfolio_accounts
--
CREATE TABLE "portfolio_accounts" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "portfolioId" uuid NOT NULL,
    "accountId" uuid NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "portfolio_account_unique_idx" ON "portfolio_accounts" USING btree ("portfolioId", "accountId");

-- Foreign keys
ALTER TABLE ONLY "portfolio_accounts"
    ADD CONSTRAINT "portfolio_accounts_fk_0"
    FOREIGN KEY("portfolioId")
    REFERENCES "portfolios"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "portfolio_accounts"
    ADD CONSTRAINT "portfolio_accounts_fk_1"
    FOREIGN KEY("accountId")
    REFERENCES "accounts"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- DATA MIGRATION: Link all existing portfolios to Main Account
--
INSERT INTO "portfolio_accounts" ("portfolioId", "accountId")
SELECT "id", (SELECT "id" FROM "accounts" WHERE "name" = 'Main Account' LIMIT 1)
FROM "portfolios";


--
-- MIGRATION VERSION FOR bagholdr
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('bagholdr', '20260131212804321', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260131212804321', "timestamp" = now();

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
