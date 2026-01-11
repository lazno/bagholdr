CREATE TABLE `assets` (
	`isin` text PRIMARY KEY NOT NULL,
	`ticker` text NOT NULL,
	`name` text NOT NULL,
	`description` text,
	`asset_type` text NOT NULL,
	`currency` text NOT NULL,
	`metadata` text,
	`yahoo_symbol` text
);
--> statement-breakpoint
CREATE TABLE `daily_prices` (
	`id` text PRIMARY KEY NOT NULL,
	`ticker` text NOT NULL,
	`date` text NOT NULL,
	`open` real NOT NULL,
	`high` real NOT NULL,
	`low` real NOT NULL,
	`close` real NOT NULL,
	`adj_close` real NOT NULL,
	`volume` integer NOT NULL,
	`currency` text NOT NULL,
	`fetched_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `dividend_events` (
	`id` text PRIMARY KEY NOT NULL,
	`ticker` text NOT NULL,
	`ex_date` text NOT NULL,
	`amount` real NOT NULL,
	`currency` text NOT NULL,
	`fetched_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `fx_cache` (
	`pair` text PRIMARY KEY NOT NULL,
	`rate` real NOT NULL,
	`fetched_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `global_cash` (
	`id` text PRIMARY KEY DEFAULT 'default' NOT NULL,
	`amount_eur` real DEFAULT 0 NOT NULL,
	`updated_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `holdings` (
	`id` text PRIMARY KEY NOT NULL,
	`asset_isin` text NOT NULL,
	`quantity` real NOT NULL,
	`total_cost_eur` real NOT NULL,
	FOREIGN KEY (`asset_isin`) REFERENCES `assets`(`isin`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `holdings_asset_isin_unique` ON `holdings` (`asset_isin`);--> statement-breakpoint
CREATE TABLE `intraday_prices` (
	`id` text PRIMARY KEY NOT NULL,
	`ticker` text NOT NULL,
	`timestamp` integer NOT NULL,
	`open` real NOT NULL,
	`high` real NOT NULL,
	`low` real NOT NULL,
	`close` real NOT NULL,
	`volume` integer NOT NULL,
	`currency` text NOT NULL,
	`fetched_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `orders` (
	`id` text PRIMARY KEY NOT NULL,
	`asset_isin` text NOT NULL,
	`order_date` integer NOT NULL,
	`quantity` real NOT NULL,
	`price_native` real NOT NULL,
	`total_native` real NOT NULL,
	`total_eur` real NOT NULL,
	`currency` text NOT NULL,
	`order_reference` text,
	`imported_at` integer NOT NULL,
	FOREIGN KEY (`asset_isin`) REFERENCES `assets`(`isin`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `portfolio_rules` (
	`id` text PRIMARY KEY NOT NULL,
	`portfolio_id` text NOT NULL,
	`rule_type` text NOT NULL,
	`name` text NOT NULL,
	`config` text NOT NULL,
	`enabled` integer DEFAULT true NOT NULL,
	`created_at` integer NOT NULL,
	FOREIGN KEY (`portfolio_id`) REFERENCES `portfolios`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `portfolios` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`band_relative_tolerance` real DEFAULT 20 NOT NULL,
	`band_absolute_floor` real DEFAULT 2 NOT NULL,
	`band_absolute_cap` real DEFAULT 10 NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `price_cache` (
	`ticker` text PRIMARY KEY NOT NULL,
	`price_native` real NOT NULL,
	`currency` text NOT NULL,
	`price_eur` real NOT NULL,
	`fetched_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `sleeve_assets` (
	`sleeve_id` text NOT NULL,
	`asset_isin` text NOT NULL,
	PRIMARY KEY(`sleeve_id`, `asset_isin`),
	FOREIGN KEY (`sleeve_id`) REFERENCES `sleeves`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`asset_isin`) REFERENCES `assets`(`isin`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `sleeves` (
	`id` text PRIMARY KEY NOT NULL,
	`portfolio_id` text NOT NULL,
	`parent_sleeve_id` text,
	`name` text NOT NULL,
	`budget_percent` real NOT NULL,
	`sort_order` integer DEFAULT 0 NOT NULL,
	`is_cash` integer DEFAULT false NOT NULL,
	FOREIGN KEY (`portfolio_id`) REFERENCES `portfolios`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `ticker_metadata` (
	`ticker` text PRIMARY KEY NOT NULL,
	`last_daily_date` text,
	`last_synced_at` integer,
	`last_intraday_synced_at` integer,
	`is_active` integer DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE `yahoo_symbols` (
	`id` text PRIMARY KEY NOT NULL,
	`asset_isin` text NOT NULL,
	`symbol` text NOT NULL,
	`exchange` text,
	`exchange_display` text,
	`quote_type` text,
	`resolved_at` integer NOT NULL,
	FOREIGN KEY (`asset_isin`) REFERENCES `assets`(`isin`) ON UPDATE no action ON DELETE cascade
);
