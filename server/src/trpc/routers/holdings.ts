import { eq } from 'drizzle-orm';
import { router, publicProcedure } from '../trpc';
import { holdings, assets } from '../../db/schema';

export const holdingsRouter = router({
	list: publicProcedure.query(async ({ ctx }) => {
		const result = await ctx.db
			.select({
				holding: holdings,
				asset: assets
			})
			.from(holdings)
			.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
			.orderBy(assets.name);

		return result.map((row) => ({
			...row.holding,
			asset: row.asset
		}));
	}),

	/**
	 * Get total portfolio value from holdings
	 * Note: This is without prices - just quantity * cost basis
	 * For market value, use the oracle to get current prices
	 */
	getTotalCostBasis: publicProcedure.query(async ({ ctx }) => {
		const allHoldings = await ctx.db.select().from(holdings);

		const totalCostEur = allHoldings.reduce((sum, h) => sum + h.totalCostEur, 0);

		return {
			totalCostEur,
			holdingsCount: allHoldings.length
		};
	})
});
