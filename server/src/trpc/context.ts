import { db } from '../db/client';

export function createContext() {
	return {
		db
	};
}

export type Context = ReturnType<typeof createContext>;
