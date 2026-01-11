/**
 * Auto-refresh store for managing background price updates
 *
 * This store triggers backend sync jobs. Progress is received via WebSocket.
 */

import { writable, get } from 'svelte/store';
import { browser } from '$app/environment';
import { trpc } from '$lib/trpc/client';
import { DEFAULT_AUTO_REFRESH_INTERVAL_MS, MIN_AUTO_REFRESH_INTERVAL_MS } from '$lib/utils/config';

interface AutoRefreshState {
	enabled: boolean;
	intervalMs: number;
	lastRefreshAt: Date | null;
	nextRefreshAt: Date | null;
	error: string | null;
}

const STORAGE_KEY = 'autoRefresh';

function loadFromStorage(): Partial<AutoRefreshState> {
	if (!browser) return {};
	try {
		const stored = localStorage.getItem(STORAGE_KEY);
		if (stored) {
			const parsed = JSON.parse(stored);
			return {
				enabled: parsed.enabled ?? true,
				intervalMs: Math.max(parsed.intervalMs ?? DEFAULT_AUTO_REFRESH_INTERVAL_MS, MIN_AUTO_REFRESH_INTERVAL_MS)
			};
		}
	} catch {
		// Ignore parse errors
	}
	return {};
}

function saveToStorage(state: { enabled: boolean; intervalMs: number }) {
	if (!browser) return;
	try {
		localStorage.setItem(STORAGE_KEY, JSON.stringify({
			enabled: state.enabled,
			intervalMs: state.intervalMs
		}));
	} catch {
		// Ignore storage errors
	}
}

function createAutoRefreshStore() {
	const stored = loadFromStorage();

	const initialState: AutoRefreshState = {
		enabled: stored.enabled ?? true,
		intervalMs: stored.intervalMs ?? DEFAULT_AUTO_REFRESH_INTERVAL_MS,
		lastRefreshAt: null,
		nextRefreshAt: null,
		error: null
	};

	const { subscribe, set, update } = writable<AutoRefreshState>(initialState);

	let refreshTimer: ReturnType<typeof setTimeout> | null = null;

	function scheduleNextRefresh() {
		const state = get({ subscribe });
		if (!state.enabled || !browser) return;

		if (refreshTimer) {
			clearTimeout(refreshTimer);
		}

		const nextRefreshAt = new Date(Date.now() + state.intervalMs);
		update((s) => ({ ...s, nextRefreshAt }));

		console.log(`[AutoRefresh] Next sync scheduled for ${nextRefreshAt.toLocaleTimeString()}`);

		refreshTimer = setTimeout(() => {
			triggerSync();
		}, state.intervalMs);
	}

	async function triggerSync() {
		console.log('[AutoRefresh] Triggering backend sync...');

		try {
			const result = await trpc.oracle.triggerPriceSync.mutate();

			if (result.started) {
				console.log('[AutoRefresh] Sync started on backend');
				update((s) => ({
					...s,
					lastRefreshAt: new Date(),
					error: null
				}));
			} else {
				console.log(`[AutoRefresh] Sync not started: ${result.reason}`);
				update((s) => ({
					...s,
					error: result.reason ?? 'Sync not started'
				}));
			}
		} catch (err) {
			console.error('[AutoRefresh] Failed to trigger sync:', err);
			update((s) => ({
				...s,
				error: err instanceof Error ? err.message : 'Failed to trigger sync'
			}));
		}

		// Schedule next refresh regardless of result
		scheduleNextRefresh();
	}

	return {
		subscribe,

		/** Start auto-refresh (call on app mount) */
		start() {
			if (!browser) return;
			console.log('[AutoRefresh] Started');
			scheduleNextRefresh();
		},

		/** Stop auto-refresh */
		stop() {
			console.log('[AutoRefresh] Stopped');
			if (refreshTimer) {
				clearTimeout(refreshTimer);
				refreshTimer = null;
			}
			update((s) => ({ ...s, nextRefreshAt: null }));
		},

		/** Enable/disable auto-refresh */
		setEnabled(enabled: boolean) {
			console.log(enabled ? '[AutoRefresh] Enabled' : '[AutoRefresh] Disabled');
			update((s) => {
				const newState = { ...s, enabled };
				saveToStorage({ enabled, intervalMs: s.intervalMs });
				return newState;
			});

			if (enabled) {
				scheduleNextRefresh();
			} else {
				if (refreshTimer) {
					clearTimeout(refreshTimer);
					refreshTimer = null;
				}
				update((s) => ({ ...s, nextRefreshAt: null }));
			}
		},

		/** Set refresh interval in milliseconds */
		setInterval(intervalMs: number) {
			const safeInterval = Math.max(intervalMs, MIN_AUTO_REFRESH_INTERVAL_MS);
			console.log(`[AutoRefresh] Interval set to ${safeInterval / 60000} minutes`);
			update((s) => {
				const newState = { ...s, intervalMs: safeInterval };
				saveToStorage({ enabled: s.enabled, intervalMs: safeInterval });
				return newState;
			});

			// Reschedule with new interval
			const state = get({ subscribe });
			if (state.enabled) {
				scheduleNextRefresh();
			}
		},

		/** Manually trigger a refresh now */
		async refreshNow() {
			console.log('[AutoRefresh] Manual refresh triggered');
			await triggerSync();
		},

		/** Clear any error */
		clearError() {
			update((s) => ({ ...s, error: null }));
		}
	};
}

export const autoRefresh = createAutoRefreshStore();
