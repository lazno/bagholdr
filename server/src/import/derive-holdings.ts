/**
 * Holdings Derivation
 *
 * Derives current holdings from all imported orders.
 * Holdings are global - aggregated across all orders.
 */

import type { Order, NewHolding } from '../db/schema';
import { nanoid } from 'nanoid';

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
export function deriveHoldings(orders: Order[]): DerivedHolding[] {
	const holdingsByIsin = new Map<string, DerivedHolding>();

	for (const order of orders) {
		const existing = holdingsByIsin.get(order.assetIsin);

		if (existing) {
			existing.quantity += order.quantity;
			// For cost basis, we add buy amounts and subtract sell amounts
			// But since sells should reduce cost basis proportionally, we simplify:
			// Just accumulate absolute EUR amounts for now
			existing.totalCostEur += order.totalEur;
		} else {
			holdingsByIsin.set(order.assetIsin, {
				assetIsin: order.assetIsin,
				quantity: order.quantity,
				totalCostEur: order.totalEur
			});
		}
	}

	// Filter out positions with zero or negative quantity
	return Array.from(holdingsByIsin.values()).filter((h) => h.quantity > 0);
}

/**
 * Convert derived holdings to database format
 */
export function toNewHoldings(derived: DerivedHolding[]): NewHolding[] {
	return derived.map((h) => ({
		id: nanoid(),
		assetIsin: h.assetIsin,
		quantity: h.quantity,
		totalCostEur: h.totalCostEur
	}));
}
