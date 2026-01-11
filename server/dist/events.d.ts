/**
 * Event emitter for real-time updates
 * Used to broadcast price updates to connected WebSocket clients
 */
import { EventEmitter } from 'events';
export interface PriceUpdateEvent {
    type: 'price_update';
    isin: string;
    ticker: string;
    priceEur: number;
    currency: string;
    fetchedAt: Date;
}
export type SyncItemStatus = 'pending' | 'syncing' | 'done' | 'error';
export type SubTaskStatus = 'pending' | 'running' | 'done' | 'error' | 'skipped';
export interface SyncSubTasks {
    price: SubTaskStatus;
    historical: SubTaskStatus;
    intraday: SubTaskStatus;
}
export interface SyncQueueItem {
    ticker: string;
    isin: string;
    name: string;
    status: SyncItemStatus;
    subTasks: SyncSubTasks;
    error?: string;
}
export interface SyncQueueEvent {
    type: 'sync_queue';
    job: 'price';
    items: SyncQueueItem[];
}
export interface SyncItemUpdateEvent {
    type: 'sync_item_update';
    job: 'price';
    ticker: string;
    status: SyncItemStatus;
    subTasks?: Partial<SyncSubTasks>;
    error?: string;
}
export interface SyncCompleteEvent {
    type: 'sync_complete';
    job: 'price';
    successCount: number;
    errorCount: number;
    durationMs: number;
}
export type ServerEvent = PriceUpdateEvent | SyncQueueEvent | SyncItemUpdateEvent | SyncCompleteEvent;
declare class ServerEventEmitter extends EventEmitter {
    emitPriceUpdate(data: Omit<PriceUpdateEvent, 'type'>): void;
    emitSyncQueue(data: Omit<SyncQueueEvent, 'type'>): void;
    emitSyncItemUpdate(data: Omit<SyncItemUpdateEvent, 'type'>): void;
    emitSyncComplete(data: Omit<SyncCompleteEvent, 'type'>): void;
    onEvent(callback: (event: ServerEvent) => void): () => this;
}
export declare const serverEvents: ServerEventEmitter;
export {};
