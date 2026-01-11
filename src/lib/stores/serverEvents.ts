/**
 * Server Events Store
 *
 * Subscribes to real-time events from the backend via WebSocket.
 * Exposes price updates, sync queue, and progress to the rest of the app.
 */

import { writable, derived, get } from 'svelte/store';
import { browser } from '$app/environment';
import {
	trpc,
	type ServerEvent,
	type PriceUpdateEvent,
	type SyncQueueItem,
	type SyncItemStatus,
	type SyncCompleteEvent,
	type SyncSubTasks,
	type SubTaskStatus
} from '$lib/trpc/client';

// How long to show "just updated" indicator (ms)
const RECENTLY_UPDATED_DURATION = 5000;

interface RecentUpdate {
	priceEur: number;
	updatedAt: Date;
}

interface SyncQueue {
	job: 'price';
	items: Map<string, SyncQueueItem>; // keyed by ticker
	startedAt: Date;
}

interface ServerEventsState {
	connected: boolean;
	lastEvent: ServerEvent | null;
	// Current sync queue (null when not syncing)
	syncQueue: SyncQueue | null;
	// Map of ISIN -> recent update info (for showing "just updated" animation)
	recentlyUpdated: Map<string, RecentUpdate>;
	// Map of ISIN -> latest price from server
	priceUpdates: Map<string, PriceUpdateEvent>;
	// Last sync completion info
	lastSyncComplete: SyncCompleteEvent | null;
	error: string | null;
}

function createServerEventsStore() {
	const { subscribe, update, set } = writable<ServerEventsState>({
		connected: false,
		lastEvent: null,
		syncQueue: null,
		recentlyUpdated: new Map(),
		priceUpdates: new Map(),
		lastSyncComplete: null,
		error: null
	});

	let unsubscribe: (() => void) | null = null;
	// Track timeouts for clearing "recently updated" state
	const recentUpdateTimeouts = new Map<string, ReturnType<typeof setTimeout>>();

	function connect() {
		if (!browser) return;

		// Already connected
		if (unsubscribe) return;

		try {
			// Subscribe to server events
			const subscription = trpc.oracle.onEvent.subscribe(undefined, {
				onData: (data) => {
					const event = data as ServerEvent;

					// Convert fetchedAt from string to Date if present (JSON serialization)
					if (event.type === 'price_update' && typeof (event as any).fetchedAt === 'string') {
						(event as any).fetchedAt = new Date((event as any).fetchedAt);
					}

					update((state) => {
						const newState = { ...state, lastEvent: event, error: null };

						if (event.type === 'price_update') {
							// Store price updates by ISIN
							const newPriceUpdates = new Map(state.priceUpdates);
							newPriceUpdates.set(event.isin, event);
							newState.priceUpdates = newPriceUpdates;

							// Mark as recently updated
							const newRecentlyUpdated = new Map(state.recentlyUpdated);
							newRecentlyUpdated.set(event.isin, {
								priceEur: event.priceEur,
								updatedAt: new Date()
							});
							newState.recentlyUpdated = newRecentlyUpdated;

							// Clear the "recently updated" state after duration
							const existingTimeout = recentUpdateTimeouts.get(event.isin);
							if (existingTimeout) clearTimeout(existingTimeout);

							const timeout = setTimeout(() => {
								update((s) => {
									const updated = new Map(s.recentlyUpdated);
									updated.delete(event.isin);
									return { ...s, recentlyUpdated: updated };
								});
								recentUpdateTimeouts.delete(event.isin);
							}, RECENTLY_UPDATED_DURATION);
							recentUpdateTimeouts.set(event.isin, timeout);

						} else if (event.type === 'sync_queue') {
							// New sync started - create queue from items
							const itemsMap = new Map<string, SyncQueueItem>();
							for (const item of event.items) {
								itemsMap.set(item.ticker, item);
							}
							newState.syncQueue = {
								job: event.job,
								items: itemsMap,
								startedAt: new Date()
							};

						} else if (event.type === 'sync_item_update') {
							// Update individual item in the queue
							if (state.syncQueue && state.syncQueue.job === event.job) {
								const newItems = new Map(state.syncQueue.items);
								const existing = newItems.get(event.ticker);
								if (existing) {
									// Merge subTasks if provided
									const updatedSubTasks = event.subTasks
										? { ...existing.subTasks, ...event.subTasks }
										: existing.subTasks;
									newItems.set(event.ticker, {
										...existing,
										status: event.status,
										subTasks: updatedSubTasks,
										error: event.error
									});
									newState.syncQueue = {
										...state.syncQueue,
										items: newItems
									};
								}
							}

						} else if (event.type === 'sync_complete') {
							// Sync completed - keep queue visible briefly, then clear
							newState.lastSyncComplete = event;
							setTimeout(() => {
								update((s) => ({ ...s, syncQueue: null }));
							}, 3000);
						}

						return newState;
					});
				},
				onError: (err) => {
					console.error('[ServerEvents] Subscription error:', err);
					update((state) => ({
						...state,
						connected: false,
						error: err instanceof Error ? err.message : 'Connection error'
					}));
				},
				onStarted: () => {
					console.log('[ServerEvents] Subscription started');
					update((state) => ({ ...state, connected: true, error: null }));
				},
				onStopped: () => {
					console.log('[ServerEvents] Subscription stopped');
					update((state) => ({ ...state, connected: false }));
				}
			});

			unsubscribe = () => {
				subscription.unsubscribe();
			};
		} catch (err) {
			console.error('[ServerEvents] Failed to connect:', err);
			update((state) => ({
				...state,
				error: err instanceof Error ? err.message : 'Failed to connect'
			}));
		}
	}

	function disconnect() {
		if (unsubscribe) {
			unsubscribe();
			unsubscribe = null;
		}
		// Clear all timeouts
		for (const timeout of recentUpdateTimeouts.values()) {
			clearTimeout(timeout);
		}
		recentUpdateTimeouts.clear();

		update((state) => ({
			...state,
			connected: false,
			syncQueue: null,
			recentlyUpdated: new Map()
		}));
	}

	// Get the latest price for an ISIN from real-time updates
	function getLatestPrice(isin: string): PriceUpdateEvent | undefined {
		const state = get({ subscribe });
		return state.priceUpdates.get(isin);
	}

	// Clear stored price updates (e.g., when manually refreshing)
	function clearPriceUpdates() {
		update((state) => ({
			...state,
			priceUpdates: new Map()
		}));
	}

	// Dismiss the sync queue panel
	function dismissSyncQueue() {
		update((state) => ({ ...state, syncQueue: null }));
	}

	return {
		subscribe,
		connect,
		disconnect,
		getLatestPrice,
		clearPriceUpdates,
		dismissSyncQueue
	};
}

export const serverEvents = createServerEventsStore();

// Derived stores for convenience
export const isConnected = derived(serverEvents, ($state) => $state.connected);
export const syncQueue = derived(serverEvents, ($state) => $state.syncQueue);
export const recentlyUpdated = derived(serverEvents, ($state) => $state.recentlyUpdated);
export const lastSyncComplete = derived(serverEvents, ($state) => $state.lastSyncComplete);
export const connectionError = derived(serverEvents, ($state) => $state.error);

// Derived: is currently syncing
export const isSyncing = derived(serverEvents, ($state) => $state.syncQueue !== null);

// Derived: currently syncing ticker
export const currentlySyncingTicker = derived(serverEvents, ($state) => {
	if (!$state.syncQueue) return null;
	for (const [ticker, item] of $state.syncQueue.items) {
		if (item.status === 'syncing') return ticker;
	}
	return null;
});

// Derived: sync progress summary
export const syncProgress = derived(serverEvents, ($state) => {
	if (!$state.syncQueue) return null;
	const items = Array.from($state.syncQueue.items.values());
	const total = items.length;
	const done = items.filter((i) => i.status === 'done' || i.status === 'error').length;
	const errors = items.filter((i) => i.status === 'error').length;
	const current = items.find((i) => i.status === 'syncing');
	return {
		job: $state.syncQueue.job,
		total,
		done,
		errors,
		currentTicker: current?.ticker ?? null,
		currentName: current?.name ?? null
	};
});
