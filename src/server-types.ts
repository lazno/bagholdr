/**
 * Re-exports server types for the frontend
 *
 * This file provides type-only exports from the server package
 * so the frontend can have type-safe tRPC calls.
 */

// Re-export the AppRouter type from the server
export type { AppRouter } from '../server/src/trpc/router';
