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
import { nanoid } from 'nanoid';

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
export function deriveHoldings(orders: Order[]): DerivedHolding[] {
	// Group orders by ISIN
	const ordersByIsin = new Map<string, Order[]>();
	for (const order of orders) {
		const existing = ordersByIsin.get(order.assetIsin) ?? [];
		existing.push(order);
		ordersByIsin.set(order.assetIsin, existing);
	}

	const holdings: DerivedHolding[] = [];

	for (const [isin, isinOrders] of ordersByIsin) {
		// Sort orders by date (chronological processing is essential for average cost)
		const sortedOrders = [...isinOrders].sort(
			(a, b) => a.orderDate.getTime() - b.orderDate.getTime()
		);

		let totalQty = 0;
		let totalCostEur = 0;
		let totalCostNative = 0;

		for (const order of sortedOrders) {
			if (order.quantity > 0) {
				// BUY: add to cost basis and quantity
				totalQty += order.quantity;
				totalCostEur += order.totalEur;
				totalCostNative += order.totalNative;
			} else if (order.quantity < 0) {
				// SELL: reduce cost basis proportionally using average cost
				const soldQty = Math.abs(order.quantity);

				if (totalQty > 0) {
					// Calculate average cost per share before this sale
					const avgCostEur = totalCostEur / totalQty;
					const avgCostNative = totalCostNative / totalQty;

					// Reduce cost basis by (sold quantity × average cost)
					const costReductionEur = avgCostEur * soldQty;
					const costReductionNative = avgCostNative * soldQty;

					totalCostEur = Math.max(0, totalCostEur - costReductionEur);
					totalCostNative = Math.max(0, totalCostNative - costReductionNative);
					totalQty = Math.max(0, totalQty - soldQty);
				}
			} else {
				// COMMISSION (quantity = 0): add to cost basis without changing quantity
				totalCostEur += order.totalEur;
				totalCostNative += order.totalNative;
			}
		}

		// Only include positions with remaining quantity
		if (totalQty > 0) {
			holdings.push({
				assetIsin: isin,
				quantity: totalQty,
				totalCostEur,
				totalCostNative
			});
		}
	}

	return holdings;
}

/**
 * Convert derived holdings to database format
 * Note: totalCostNative is not stored in DB, only used for calculations
 */
export function toNewHoldings(derived: DerivedHolding[]): NewHolding[] {
	return derived.map((h) => ({
		id: nanoid(),
		assetIsin: h.assetIsin,
		quantity: h.quantity,
		totalCostEur: h.totalCostEur
	}));
}
