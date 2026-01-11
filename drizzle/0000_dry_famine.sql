CREATE TABLE `assets` (
	`isin` text PRIMARY KEY NOT NULL,
	`ticker` text NOT NULL,
	`name` text NOT NULL,
	`description` text,
	`asset_type` text NOT NULL,
	`currency` text NOT NULL,
	`metadata` text
);
--> statement-breakpoint
CREATE TABLE `budget_rules` (
	`id` text PRIMARY KEY NOT NULL,
	`portfolio_id` text NOT NULL,
	`type` text NOT NULL,
	`target_id` text NOT NULL,
	`scope` text NOT NULL,
	`scope_id` text,
	`target_percent` real NOT NULL,
	`band_relative_tolerance` real DEFAULT 10 NOT NULL,
	`band_absolute_floor` real,
	`band_absolute_ceiling` real,
	FOREIGN KEY (`portfolio_id`) REFERENCES `portfolios`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `exposure_rules` (
	`id` text PRIMARY KEY NOT NULL,
	`portfolio_id` text NOT NULL,
	`type` text NOT NULL,
	`category` text NOT NULL,
	`threshold_percent` real NOT NULL,
	`severity` text NOT NULL,
	FOREIGN KEY (`portfolio_id`) REFERENCES `portfolios`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `fx_cache` (
	`pair` text PRIMARY KEY NOT NULL,
	`rate` real NOT NULL,
	`fetched_at` integer NOT NULL
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
CREATE TABLE `portfolios` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`cash_eur` real DEFAULT 0 NOT NULL,
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
