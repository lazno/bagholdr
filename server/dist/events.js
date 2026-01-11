/**
 * Event emitter for real-time updates
 * Used to broadcast price updates to connected WebSocket clients
 */
import { EventEmitter } from 'events';
class ServerEventEmitter extends EventEmitter {
    emitPriceUpdate(data) {
        this.emit('event', { type: 'price_update', ...data });
    }
    emitSyncQueue(data) {
        this.emit('event', { type: 'sync_queue', ...data });
    }
    emitSyncItemUpdate(data) {
        this.emit('event', { type: 'sync_item_update', ...data });
    }
    emitSyncComplete(data) {
        this.emit('event', { type: 'sync_complete', ...data });
    }
    onEvent(callback) {
        this.on('event', callback);
        return () => this.off('event', callback);
    }
}
export const serverEvents = new ServerEventEmitter();
