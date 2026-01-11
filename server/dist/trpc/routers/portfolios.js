import { z } from 'zod';
import { TRPCError } from '@trpc/server';
import { eq } from 'drizzle-orm';
import { nanoid } from 'nanoid';
import { router, publicProcedure } from '../trpc';
import { portfolios } from '../../db/schema';
import { DEFAULT_BAND_CONFIG } from '../../utils/bands';
export const portfoliosRouter = router({
    list: publicProcedure.query(async ({ ctx }) => {
        return ctx.db.select().from(portfolios).orderBy(portfolios.name);
    }),
    get: publicProcedure.input(z.object({ id: z.string() })).query(async ({ ctx, input }) => {
        const [portfolio] = await ctx.db
            .select()
            .from(portfolios)
            .where(eq(portfolios.id, input.id))
            .limit(1);
        if (!portfolio) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Portfolio not found' });
        }
        return portfolio;
    }),
    create: publicProcedure
        .input(z.object({
        name: z.string().min(1).max(100)
    }))
        .mutation(async ({ ctx, input }) => {
        const now = new Date();
        const portfolioId = nanoid();
        // Create portfolio with default band configuration
        await ctx.db.insert(portfolios).values({
            id: portfolioId,
            name: input.name,
            bandRelativeTolerance: DEFAULT_BAND_CONFIG.relativeTolerance,
            bandAbsoluteFloor: DEFAULT_BAND_CONFIG.absoluteFloor,
            bandAbsoluteCap: DEFAULT_BAND_CONFIG.absoluteCap,
            createdAt: now,
            updatedAt: now
        });
        // Note: No default Cash sleeve - cash is handled separately from sleeves
        // Users create sleeves for their invested assets only
        return { id: portfolioId };
    }),
    update: publicProcedure
        .input(z.object({
        id: z.string(),
        name: z.string().min(1).max(100).optional(),
        // Band configuration
        bandRelativeTolerance: z.number().min(1).max(100).optional(),
        bandAbsoluteFloor: z.number().min(0).max(50).optional(),
        bandAbsoluteCap: z.number().min(1).max(50).optional()
    }))
        .mutation(async ({ ctx, input }) => {
        const { id, ...updates } = input;
        const [existing] = await ctx.db
            .select()
            .from(portfolios)
            .where(eq(portfolios.id, id))
            .limit(1);
        if (!existing) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Portfolio not found' });
        }
        // Validate band config: floor must be <= cap
        if (updates.bandAbsoluteFloor !== undefined &&
            updates.bandAbsoluteCap !== undefined &&
            updates.bandAbsoluteFloor > updates.bandAbsoluteCap) {
            throw new TRPCError({
                code: 'BAD_REQUEST',
                message: 'Band floor cannot be greater than cap'
            });
        }
        await ctx.db
            .update(portfolios)
            .set({
            ...updates,
            updatedAt: new Date()
        })
            .where(eq(portfolios.id, id));
        return { success: true };
    }),
    delete: publicProcedure.input(z.object({ id: z.string() })).mutation(async ({ ctx, input }) => {
        const [existing] = await ctx.db
            .select()
            .from(portfolios)
            .where(eq(portfolios.id, input.id))
            .limit(1);
        if (!existing) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Portfolio not found' });
        }
        // Cascade delete will handle sleeves, sleeveAssets, rules
        await ctx.db.delete(portfolios).where(eq(portfolios.id, input.id));
        return { success: true };
    })
});
