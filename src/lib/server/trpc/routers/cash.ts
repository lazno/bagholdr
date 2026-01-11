import { z } from 'zod';
import { router, publicProcedure } from '../trpc';
import { globalCash } from '$lib/server/db/schema';
import { eq } from 'drizzle-orm';

const CASH_ID = 'default';

export const cashRouter = router({
	/**
	 * Get current cash balance
	 */
	get: publicProcedure.query(async ({ ctx }) => {
		const [cash] = await ctx.db
			.select()
			.from(globalCash)
			.where(eq(globalCash.id, CASH_ID))
			.limit(1);

		if (!cash) {
			// Initialize with 0 if not exists
			const now = new Date();
			await ctx.db.insert(globalCash).values({
				id: CASH_ID,
				amountEur: 0,
				updatedAt: now
			});
			return { amountEur: 0, updatedAt: now };
		}

		return cash;
	}),

	/**
	 * Set cash balance
	 */
	set: publicProcedure
		.input(z.object({ amountEur: z.number().min(0) }))
		.mutation(async ({ ctx, input }) => {
			const now = new Date();

			await ctx.db
				.insert(globalCash)
				.values({
					id: CASH_ID,
					amountEur: input.amountEur,
					updatedAt: now
				})
				.onConflictDoUpdate({
					target: globalCash.id,
					set: {
						amountEur: input.amountEur,
						updatedAt: now
					}
				});

			return { amountEur: input.amountEur, updatedAt: now };
		})
});
