import { createTRPCClient, httpBatchLink, splitLink, createWSClient, wsLink } from '@trpc/client';
import type { AppRouter } from '../../server-types';

// Backend URLs - configurable via environment variables
const BACKEND_URL = import.meta.env.VITE_BACKEND_URL ?? 'http://localhost:3001';
const WS_URL = import.meta.env.VITE_WS_URL ?? 'ws://localhost:3002';

// WebSocket client for subscriptions
const wsClient = createWSClient({
	url: WS_URL
});

export const trpc = createTRPCClient<AppRouter>({
	links: [
		// Use splitLink to route subscriptions to WebSocket, everything else to HTTP
		splitLink({
			condition: (op) => op.type === 'subscription',
			true: wsLink({ client: wsClient }),
			false: httpBatchLink({
				url: `${BACKEND_URL}/trpc`
			})
		})
	]
});

// Export ServerEvent types for use in components
export type {
	ServerEvent,
	PriceUpdateEvent,
	SyncQueueEvent,
	SyncQueueItem,
	SyncItemUpdateEvent,
	SyncItemStatus,
	SyncCompleteEvent,
	SyncSubTasks,
	SubTaskStatus
} from '../../../server/src/events';
