import { db } from '../db/client';
export function createContext() {
    return {
        db
    };
}
