/**
 * Holdings Derivation
 *
 * Derives current holdings from all imported orders using the Average Cost Method.
 * Holdings are global - aggregated across all orders.
 *
 * Average Cost Method:
 * - On buys: add to total cost basis and quantity
 * - On sells: reduce cost basis proportionally based on average cost per share
 * - The average cost per share only changes on buys, not on sells
 *
 * Example:
 * - Buy 100 @ $10 = $1000 cost, avg = $10.00
 * - Buy 50 @ $14 = $700 cost, total = $1700, qty = 150, avg = $11.33
 * - Sell 75 @ $15 → reduce cost by 75 × $11.33 = $850, remaining = $850, qty = 75, avg still = $11.33
 */
import type { Order, NewHolding } from '../db/schema';
export interface DerivedHolding {
    assetIsin: string;
    quantity: number;
    totalCostEur: number;
    totalCostNative: number;
}
/**
 * Derive holdings from a list of orders using Average Cost Method
 *
 * Orders are processed chronologically. For each ISIN:
 * - Buys: add cost and quantity
 * - Sells: reduce cost proportionally (avgCost × soldQty)
 */
export declare function deriveHoldings(orders: Order[]): DerivedHolding[];
/**
 * Convert derived holdings to database format
 * Note: totalCostNative is not stored in DB, only used for calculations
 */
export declare function toNewHoldings(derived: DerivedHolding[]): NewHolding[];
