import { z } from 'zod';
import { nanoid } from 'nanoid';
import { router, publicProcedure } from '../trpc';
import { parseDirectaCSV, type ParsedOrder } from '../../import/directa-parser';
import { deriveHoldings } from '../../import/derive-holdings';
import { assets, orders, holdings } from '../../db/schema';
import { eq, inArray } from 'drizzle-orm';

export const importRouter = router({
	/**
	 * Parse CSV content and return preview
	 * Does not persist anything - just parses and returns what would be imported
	 */
	parseCSV: publicProcedure
		.input(z.object({ content: z.string() }))
		.mutation(async ({ input }) => {
			const result = parseDirectaCSV(input.content);

			// Group orders by ISIN to show summary
			const byIsin = new Map<string, { ticker: string; name: string; orders: ParsedOrder[] }>();

			for (const order of result.orders) {
				const existing = byIsin.get(order.isin);
				if (existing) {
					existing.orders.push(order);
				} else {
					byIsin.set(order.isin, {
						ticker: order.ticker,
						name: order.name,
						orders: [order]
					});
				}
			}

			const assetSummaries = Array.from(byIsin.entries()).map(([isin, data]) => {
				const totalQuantity = data.orders.reduce((sum, o) => sum + o.quantity, 0);
				const totalAmountEur = data.orders.reduce((sum, o) => sum + o.amountEur, 0);
				const buyCount = data.orders.filter((o) => o.transactionType === 'Buy').length;
				const sellCount = data.orders.filter((o) => o.transactionType === 'Sell').length;

				return {
					isin,
					ticker: data.ticker,
					name: data.name,
					totalQuantity,
					totalAmountEur,
					buyCount,
					sellCount,
					orderCount: data.orders.length
				};
			});

			return {
				accountName: result.accountName,
				totalOrders: result.orders.length,
				skippedRows: result.skippedRows,
				errors: result.errors,
				assetSummaries,
				// Include raw orders for confirmation step
				orders: result.orders
			};
		}),

	/**
	 * Confirm import - persist orders and derive holdings
	 * Skips orders with duplicate orderReference (already imported)
	 */
	confirmImport: publicProcedure
		.input(
			z.object({
				orders: z.array(
					z.object({
						isin: z.string(),
						ticker: z.string(),
						name: z.string(),
						transactionDate: z.coerce.date(),
						transactionType: z.enum(['Buy', 'Sell', 'Commission']),
						quantity: z.number(),
						amountEur: z.number(),
						currencyAmount: z.number(),
						currency: z.string(),
						orderReference: z.string()
					})
				)
			})
		)
		.mutation(async ({ ctx, input }) => {
			const now = new Date();
			let assetsCreated = 0;
			let ordersCreated = 0;
			let ordersReplaced = 0;

			// Group orders by orderReference for upsert logic
			const ordersByRef = new Map<string, typeof input.orders>();
			for (const order of input.orders) {
				const ref = order.orderReference || '';
				const group = ordersByRef.get(ref) || [];
				group.push(order);
				ordersByRef.set(ref, group);
			}

			// Get unique order references from input (excluding empty)
			const incomingRefs = Array.from(ordersByRef.keys()).filter((ref) => ref !== '');

			// Delete existing orders with these order references (will be replaced)
			if (incomingRefs.length > 0) {
				const deleteResult = await ctx.db
					.delete(orders)
					.where(inArray(orders.orderReference, incomingRefs));
				ordersReplaced = deleteResult.changes ?? 0;
			}

			// Process each order
			for (const order of input.orders) {
				// Find or create asset
				const [existingAsset] = await ctx.db
					.select()
					.from(assets)
					.where(eq(assets.isin, order.isin))
					.limit(1);

				if (!existingAsset) {
					await ctx.db.insert(assets).values({
						isin: order.isin,
						ticker: order.ticker,
						name: order.name,
						assetType: 'other', // Will be updated when we fetch from Yahoo
						currency: order.currency,
						metadata: null
					});
					assetsCreated++;
				}

				// Insert order
				await ctx.db.insert(orders).values({
					id: nanoid(),
					assetIsin: order.isin,
					orderDate: order.transactionDate,
					quantity: order.quantity,
					priceNative:
						order.currencyAmount !== 0
							? order.currencyAmount / Math.abs(order.quantity)
							: order.amountEur / Math.abs(order.quantity),
					totalNative: order.currencyAmount !== 0 ? order.currencyAmount : order.amountEur,
					totalEur: order.amountEur,
					currency: order.currency,
					orderReference: order.orderReference,
					importedAt: now
				});
				ordersCreated++;
			}

			// Re-derive all holdings from all orders
			const allOrders = await ctx.db.select().from(orders);
			const derivedHoldings = deriveHoldings(allOrders);

			// Clear existing holdings and insert new ones
			await ctx.db.delete(holdings);

			for (const holding of derivedHoldings) {
				await ctx.db.insert(holdings).values({
					id: nanoid(),
					assetIsin: holding.assetIsin,
					quantity: holding.quantity,
					totalCostEur: holding.totalCostEur
				});
			}

			return {
				assetsCreated,
				ordersCreated,
				ordersReplaced,
				holdingsCount: derivedHoldings.length
			};
		})
});
