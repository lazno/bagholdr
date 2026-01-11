import { z } from 'zod';
import { TRPCError } from '@trpc/server';
import { eq } from 'drizzle-orm';
import { nanoid } from 'nanoid';
import { router, publicProcedure } from '../trpc';
import { portfolioRules, portfolios } from '../../db/schema';
// Zod schemas for rule configs
const assetTypeSchema = z.enum(['stock', 'etf', 'bond', 'fund', 'commodity', 'other']);
const concentrationLimitConfigSchema = z.object({
    maxPercent: z.number().min(1).max(100),
    assetTypes: z.array(assetTypeSchema).optional()
});
export const rulesRouter = router({
    /**
     * List all rules for a portfolio
     */
    list: publicProcedure
        .input(z.object({ portfolioId: z.string() }))
        .query(async ({ ctx, input }) => {
        const rules = await ctx.db
            .select()
            .from(portfolioRules)
            .where(eq(portfolioRules.portfolioId, input.portfolioId))
            .orderBy(portfolioRules.createdAt);
        return rules;
    }),
    /**
     * Get a single rule by ID
     */
    get: publicProcedure.input(z.object({ id: z.string() })).query(async ({ ctx, input }) => {
        const [rule] = await ctx.db
            .select()
            .from(portfolioRules)
            .where(eq(portfolioRules.id, input.id))
            .limit(1);
        if (!rule) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Rule not found' });
        }
        return rule;
    }),
    /**
     * Create a concentration limit rule
     */
    createConcentrationLimit: publicProcedure
        .input(z.object({
        portfolioId: z.string(),
        name: z.string().min(1).max(100),
        config: concentrationLimitConfigSchema
    }))
        .mutation(async ({ ctx, input }) => {
        // Verify portfolio exists
        const [portfolio] = await ctx.db
            .select()
            .from(portfolios)
            .where(eq(portfolios.id, input.portfolioId))
            .limit(1);
        if (!portfolio) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Portfolio not found' });
        }
        const ruleId = nanoid();
        const config = {
            maxPercent: input.config.maxPercent,
            assetTypes: input.config.assetTypes
        };
        await ctx.db.insert(portfolioRules).values({
            id: ruleId,
            portfolioId: input.portfolioId,
            ruleType: 'concentration_limit',
            name: input.name,
            config,
            enabled: true,
            createdAt: new Date()
        });
        return { id: ruleId };
    }),
    /**
     * Update a rule
     */
    update: publicProcedure
        .input(z.object({
        id: z.string(),
        name: z.string().min(1).max(100).optional(),
        config: concentrationLimitConfigSchema.optional(),
        enabled: z.boolean().optional()
    }))
        .mutation(async ({ ctx, input }) => {
        const [existing] = await ctx.db
            .select()
            .from(portfolioRules)
            .where(eq(portfolioRules.id, input.id))
            .limit(1);
        if (!existing) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Rule not found' });
        }
        const updates = {};
        if (input.name !== undefined) {
            updates.name = input.name;
        }
        if (input.config !== undefined) {
            updates.config = input.config;
        }
        if (input.enabled !== undefined) {
            updates.enabled = input.enabled;
        }
        await ctx.db.update(portfolioRules).set(updates).where(eq(portfolioRules.id, input.id));
        return { success: true };
    }),
    /**
     * Delete a rule
     */
    delete: publicProcedure.input(z.object({ id: z.string() })).mutation(async ({ ctx, input }) => {
        const [existing] = await ctx.db
            .select()
            .from(portfolioRules)
            .where(eq(portfolioRules.id, input.id))
            .limit(1);
        if (!existing) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Rule not found' });
        }
        await ctx.db.delete(portfolioRules).where(eq(portfolioRules.id, input.id));
        return { success: true };
    }),
    /**
     * Toggle a rule's enabled state
     */
    toggle: publicProcedure.input(z.object({ id: z.string() })).mutation(async ({ ctx, input }) => {
        const [existing] = await ctx.db
            .select()
            .from(portfolioRules)
            .where(eq(portfolioRules.id, input.id))
            .limit(1);
        if (!existing) {
            throw new TRPCError({ code: 'NOT_FOUND', message: 'Rule not found' });
        }
        await ctx.db
            .update(portfolioRules)
            .set({ enabled: !existing.enabled })
            .where(eq(portfolioRules.id, input.id));
        return { enabled: !existing.enabled };
    })
});
