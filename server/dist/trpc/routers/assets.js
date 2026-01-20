import { z } from 'zod';
import { TRPCError } from '@trpc/server';
import { eq, gt, inArray } from 'drizzle-orm';
import { router, publicProcedure } from '../trpc';
import { assets, holdings, sleeveAssets } from '../../db/schema';
export const assetsRouter = router({
    list: publicProcedure
        .input(z.object({ includeSold: z.boolean().optional() }).optional())
        .query(async ({ ctx, input }) => {
        const includeSold = input?.includeSold ?? false;
        if (includeSold) {
            return ctx.db.select().from(assets).orderBy(assets.name);
        }
        // Only assets with holdings > 0
        const result = await ctx.db
            .select({ asset: assets })
            .from(assets)
            .innerJoin(holdings, eq(assets.isin, holdings.assetIsin))
            .where(gt(holdings.quantity, 0))
            .orderBy(assets.name);
        return result.map((r) => r.asset);
    }),
    listWithHoldings: publicProcedure
        .input(z.object({ includeSold: z.boolean().optional() }).optional())
        .query(async ({ ctx, input }) => {
        const includeSold = input?.includeSold ?? false;
        const result = await ctx.db
            .select({
            asset: assets,
            holding: holdings
        })
            .from(assets)
            .leftJoin(holdings, eq(assets.isin, holdings.assetIsin))
            .orderBy(assets.name);
        const mapped = result.map((row) => ({
            ...row.asset,
            quantity: row.holding?.quantity ?? 0,
            totalCostEur: row.holding?.totalCostEur ?? 0
        }));
        if (includeSold) {
            return mapped;
        }
        // Filter out zero-share assets
        return mapped.filter((a) => a.quantity > 0);
    }),
    get: publicProcedure.input(z.object({ isin: z.string() })).query(async ({ ctx, input }) => {
        const [asset] = await ctx.db
            .select()
            .from(assets)
            .where(eq(assets.isin, input.isin))
            .limit(1);
        if (!asset) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
        }
        return asset;
    }),
    update: publicProcedure
        .input(z.object({
        isin: z.string(),
        ticker: z.string().min(1).optional(),
        name: z.string().min(1).optional(),
        description: z.string().optional(),
        assetType: z.enum(['stock', 'etf', 'bond', 'fund', 'commodity', 'other']).optional(),
        currency: z.string().min(3).max(3).optional()
    }))
        .mutation(async ({ ctx, input }) => {
        const { isin, ...updates } = input;
        const [existing] = await ctx.db
            .select()
            .from(assets)
            .where(eq(assets.isin, isin))
            .limit(1);
        if (!existing) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
        }
        // Only update fields that were provided
        const fieldsToUpdate = Object.fromEntries(Object.entries(updates).filter(([, value]) => value !== undefined));
        if (Object.keys(fieldsToUpdate).length > 0) {
            await ctx.db.update(assets).set(fieldsToUpdate).where(eq(assets.isin, isin));
        }
        return { success: true };
    }),
    bulkUpdateType: publicProcedure
        .input(z.object({
        isins: z.array(z.string()).min(1),
        assetType: z.enum(['stock', 'etf', 'bond', 'fund', 'commodity', 'other'])
    }))
        .mutation(async ({ ctx, input }) => {
        const { isins, assetType } = input;
        // Verify all assets exist
        const existingAssets = await ctx.db
            .select({ isin: assets.isin })
            .from(assets)
            .where(inArray(assets.isin, isins));
        if (existingAssets.length !== isins.length) {
            const foundIsins = new Set(existingAssets.map((a) => a.isin));
            const missing = isins.filter((isin) => !foundIsins.has(isin));
            throw new TRPCError({
                code: 'NOT_FOUND',
                message: `Assets not found: ${missing.join(', ')}`
            });
        }
        // Bulk update
        await ctx.db.update(assets).set({ assetType }).where(inArray(assets.isin, isins));
        return { success: true, updatedCount: isins.length };
    }),
    setArchived: publicProcedure
        .input(z.object({
        isin: z.string(),
        archived: z.boolean()
    }))
        .mutation(async ({ ctx, input }) => {
        const { isin, archived } = input;
        // Verify asset exists
        const [existing] = await ctx.db
            .select()
            .from(assets)
            .where(eq(assets.isin, isin))
            .limit(1);
        if (!existing) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
        }
        // Update archived status
        await ctx.db.update(assets).set({ archived }).where(eq(assets.isin, isin));
        // If archiving, remove from all sleeves
        if (archived) {
            await ctx.db.delete(sleeveAssets).where(eq(sleeveAssets.assetIsin, isin));
        }
        return { success: true, archived };
    }),
    bulkSetArchived: publicProcedure
        .input(z.object({
        isins: z.array(z.string()).min(1),
        archived: z.boolean()
    }))
        .mutation(async ({ ctx, input }) => {
        const { isins, archived } = input;
        // Verify all assets exist
        const existingAssets = await ctx.db
            .select({ isin: assets.isin })
            .from(assets)
            .where(inArray(assets.isin, isins));
        if (existingAssets.length !== isins.length) {
            const foundIsins = new Set(existingAssets.map((a) => a.isin));
            const missing = isins.filter((isin) => !foundIsins.has(isin));
            throw new TRPCError({
                code: 'NOT_FOUND',
                message: `Assets not found: ${missing.join(', ')}`
            });
        }
        // Bulk update archived status
        await ctx.db.update(assets).set({ archived }).where(inArray(assets.isin, isins));
        // If archiving, remove from all sleeves
        if (archived) {
            await ctx.db.delete(sleeveAssets).where(inArray(sleeveAssets.assetIsin, isins));
        }
        return { success: true, updatedCount: isins.length, archived };
    })
});
