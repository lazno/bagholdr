/**
 * Bagholdr Server
 *
 * Standalone Hono server with:
 * - tRPC API endpoints (HTTP + WebSocket for subscriptions)
 * - Scheduled cron job for price sync (includes historical/intraday when needed)
 * - SQLite database with Drizzle ORM
 */
export type { AppRouter } from './trpc/router';
