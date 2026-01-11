/**
 * Holdings Derivation
 *
 * Derives current holdings from all imported orders.
 * Holdings are global - aggregated across all orders.
 */
import type { Order, NewHolding } from '../db/schema';
export interface DerivedHolding {
    assetIsin: string;
    quantity: number;
    totalCostEur: number;
}
/**
 * Derive holdings from a list of orders
 *
 * For each ISIN:
 * - Sum all quantities (buy positive, sell negative)
 * - Sum all EUR amounts for cost basis
 */
export declare function deriveHoldings(orders: Order[]): DerivedHolding[];
/**
 * Convert derived holdings to database format
 */
export declare function toNewHoldings(derived: DerivedHolding[]): NewHolding[];
