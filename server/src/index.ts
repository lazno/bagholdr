/**
 * Bagholdr Server
 *
 * Standalone Hono server with:
 * - tRPC API endpoints (HTTP + WebSocket for subscriptions)
 * - Scheduled cron job for price sync (includes historical/intraday when needed)
 * - SQLite database with Drizzle ORM
 */

import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { trpcServer } from '@hono/trpc-server';
import { applyWSSHandler } from '@trpc/server/adapters/ws';
import { WebSocketServer } from 'ws';
import cron from 'node-cron';

import { appRouter } from './trpc/router';
import { createContext } from './trpc/context';
import { runPriceSyncJob } from './sync';
import { PORT, CORS_ORIGIN, CRON_PRICE_SYNC } from './config';

const app = new Hono();

// CORS - configured for tRPC batch requests
app.use('/*', cors({
	origin: CORS_ORIGIN,
	credentials: true,
	allowMethods: ['GET', 'POST', 'OPTIONS'],
	allowHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
	exposeHeaders: ['Content-Length'],
	maxAge: 86400
}));

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }));

// tRPC handler
app.use('/trpc/*', trpcServer({
	router: appRouter,
	createContext
}));

// =============================================================================
// Scheduled Jobs
// =============================================================================

// Price sync also handles historical and intraday data when needed
console.log(`[Cron] Scheduling price sync: ${CRON_PRICE_SYNC}`);
cron.schedule(CRON_PRICE_SYNC, runPriceSyncJob);

// =============================================================================
// Start Server
// =============================================================================

const WS_PORT = PORT + 1;

console.log(`Starting Bagholdr server on port ${PORT}...`);
console.log(`CORS origin: ${CORS_ORIGIN}`);

// HTTP server for REST/tRPC queries and mutations
serve({
	fetch: app.fetch,
	port: PORT
}, (info) => {
	console.log(`Server running at http://localhost:${info.port}`);
	console.log(`tRPC endpoint: http://localhost:${info.port}/trpc`);
	console.log(`Health check: http://localhost:${info.port}/health`);
});

// WebSocket server for tRPC subscriptions
const wss = new WebSocketServer({ port: WS_PORT });

applyWSSHandler({
	wss,
	router: appRouter,
	createContext
});

console.log(`WebSocket server running at ws://localhost:${WS_PORT}`);

// Handle graceful shutdown
process.on('SIGTERM', () => {
	console.log('SIGTERM received, shutting down...');
	wss.close();
	process.exit(0);
});

// Export for type inference
export type { AppRouter } from './trpc/router';
