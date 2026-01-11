import type { RequestEvent } from '@sveltejs/kit';
import { db } from '$lib/server/db/client';

export function createContext(event: RequestEvent) {
	return {
		db,
		event
	};
}

export type Context = ReturnType<typeof createContext>;
