import { z } from 'zod';
import { TRPCError } from '@trpc/server';
import { eq, and, isNull, inArray } from 'drizzle-orm';
import { nanoid } from 'nanoid';
import { router, publicProcedure } from '../trpc';
import { sleeves, sleeveAssets, holdings, assets } from '../../db/schema';

import type { DbClient } from '../../db/client';
import type { Sleeve } from '../../db/schema';

/**
 * Validate that sibling sleeves sum to exactly 100%
 * Note: Cash sleeves are excluded from this validation as they're deprecated
 */
async function validateSiblingBudgets(
	db: DbClient,
	portfolioId: string,
	parentSleeveId: string | null,
	excludeSleeveId?: string
): Promise<{ valid: boolean; total: number; siblings: Array<{ id: string; name: string; budgetPercent: number }> }> {
	const query = db
		.select()
		.from(sleeves)
		.where(
			parentSleeveId === null
				? and(eq(sleeves.portfolioId, portfolioId), isNull(sleeves.parentSleeveId))
				: and(eq(sleeves.portfolioId, portfolioId), eq(sleeves.parentSleeveId, parentSleeveId))
		);

	const siblings: Sleeve[] = await query;
	// Filter out cash sleeves and any excluded sleeve
	const filtered = siblings
		.filter((s) => !s.isCash)
		.filter((s) => s.id !== excludeSleeveId);

	const total = filtered.reduce((sum: number, s: Sleeve) => sum + s.budgetPercent, 0);

	return {
		valid: Math.abs(total - 100) < 0.01, // Allow tiny floating point errors
		total,
		siblings: filtered.map((s) => ({ id: s.id, name: s.name, budgetPercent: s.budgetPercent }))
	};
}

export const sleevesRouter = router({
	/**
	 * List all sleeves for a portfolio with hierarchy info
	 * Note: Cash sleeves are filtered out - cash is handled separately
	 */
	list: publicProcedure
		.input(z.object({ portfolioId: z.string() }))
		.query(async ({ ctx, input }) => {
			const allSleeves = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.portfolioId, input.portfolioId))
				.orderBy(sleeves.sortOrder);

			// Filter out cash sleeves - cash is now handled separately from sleeves
			return allSleeves.filter((s) => !s.isCash);
		}),

	/**
	 * Get a single sleeve with its assigned assets
	 */
	get: publicProcedure
		.input(z.object({ id: z.string() }))
		.query(async ({ ctx, input }) => {
			const [sleeve] = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.id, input.id))
				.limit(1);

			if (!sleeve) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Sleeve not found' });
			}

			const assignedAssets = await ctx.db
				.select({
					sleeveAsset: sleeveAssets,
					asset: assets
				})
				.from(sleeveAssets)
				.innerJoin(assets, eq(sleeveAssets.assetIsin, assets.isin))
				.where(eq(sleeveAssets.sleeveId, input.id));

			return {
				...sleeve,
				assets: assignedAssets.map((a) => a.asset)
			};
		}),

	/**
	 * Create a new sleeve
	 * Note: After creation, sibling budgets may not sum to 100% - user must adjust
	 */
	create: publicProcedure
		.input(
			z.object({
				portfolioId: z.string(),
				parentSleeveId: z.string().nullable(),
				name: z.string().min(1).max(100),
				budgetPercent: z.number().min(0).max(100)
			})
		)
		.mutation(async ({ ctx, input }) => {
			// Get max sort order for siblings (excluding cash sleeves)
			const siblings = await ctx.db
				.select()
				.from(sleeves)
				.where(
					input.parentSleeveId === null
						? and(eq(sleeves.portfolioId, input.portfolioId), isNull(sleeves.parentSleeveId))
						: and(eq(sleeves.portfolioId, input.portfolioId), eq(sleeves.parentSleeveId, input.parentSleeveId))
				);

			const nonCashSiblings = siblings.filter((s) => !s.isCash);
			const maxOrder = nonCashSiblings.reduce((max, s) => Math.max(max, s.sortOrder), -1);

			const id = nanoid();
			await ctx.db.insert(sleeves).values({
				id,
				portfolioId: input.portfolioId,
				parentSleeveId: input.parentSleeveId,
				name: input.name,
				budgetPercent: input.budgetPercent,
				sortOrder: maxOrder + 1,
				isCash: false // Never create cash sleeves anymore
			});

			return { id };
		}),

	/**
	 * Update a sleeve
	 */
	update: publicProcedure
		.input(
			z.object({
				id: z.string(),
				name: z.string().min(1).max(100).optional(),
				budgetPercent: z.number().min(0).max(100).optional(),
				parentSleeveId: z.string().nullable().optional(),
				sortOrder: z.number().optional()
			})
		)
		.mutation(async ({ ctx, input }) => {
			const [existing] = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.id, input.id))
				.limit(1);

			if (!existing) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Sleeve not found' });
			}

			// Cash sleeves should not be modified through this API
			if (existing.isCash) {
				throw new TRPCError({
					code: 'BAD_REQUEST',
					message: 'Cash sleeves are deprecated - cash is managed at portfolio level'
				});
			}

			const { id, ...updates } = input;
			const fieldsToUpdate = Object.fromEntries(
				Object.entries(updates).filter(([, value]) => value !== undefined)
			);

			if (Object.keys(fieldsToUpdate).length > 0) {
				await ctx.db.update(sleeves).set(fieldsToUpdate).where(eq(sleeves.id, id));
			}

			return { success: true };
		}),

	/**
	 * Delete a sleeve, its sub-sleeves, and reassign assets to parent
	 * - Assets from deleted sleeve are moved to parent sleeve (or unassigned if no parent)
	 * - Sub-sleeves are recursively deleted
	 */
	delete: publicProcedure
		.input(z.object({ id: z.string() }))
		.mutation(async ({ ctx, input }) => {
			const [existing] = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.id, input.id))
				.limit(1);

			if (!existing) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Sleeve not found' });
			}

			// Cash sleeves should not be deleted through this API
			if (existing.isCash) {
				throw new TRPCError({
					code: 'BAD_REQUEST',
					message: 'Cash sleeves are deprecated - they will be cleaned up automatically'
				});
			}

			// Collect all sleeve IDs to delete (this sleeve + all descendants)
			const sleevesToDelete: string[] = [];
			const collectDescendants = async (sleeveId: string) => {
				sleevesToDelete.push(sleeveId);
				const children = await ctx.db
					.select()
					.from(sleeves)
					.where(eq(sleeves.parentSleeveId, sleeveId));
				for (const child of children) {
					await collectDescendants(child.id);
				}
			};
			await collectDescendants(input.id);

			// Get all assets from all sleeves being deleted
			const assetsToReassign = await ctx.db
				.select()
				.from(sleeveAssets)
				.where(inArray(sleeveAssets.sleeveId, sleevesToDelete));

			// If parent exists, move assets to parent; otherwise they become unassigned
			if (existing.parentSleeveId && assetsToReassign.length > 0) {
				// Move assets to parent sleeve
				for (const asset of assetsToReassign) {
					await ctx.db
						.insert(sleeveAssets)
						.values({
							sleeveId: existing.parentSleeveId,
							assetIsin: asset.assetIsin
						})
						.onConflictDoNothing(); // In case asset is already in parent
				}
			}
			// If no parent, assets just get deleted (become unassigned) - that's handled by cascade

			// Delete all sleeves (cascade will delete sleeveAssets)
			for (const sleeveId of sleevesToDelete) {
				await ctx.db.delete(sleeves).where(eq(sleeves.id, sleeveId));
			}

			return {
				success: true,
				deletedCount: sleevesToDelete.length,
				assetsReassigned: assetsToReassign.length
			};
		}),

	/**
	 * Validate sibling budgets sum to 100%
	 */
	validateBudgets: publicProcedure
		.input(
			z.object({
				portfolioId: z.string(),
				parentSleeveId: z.string().nullable()
			})
		)
		.query(async ({ ctx, input }) => {
			return validateSiblingBudgets(ctx.db, input.portfolioId, input.parentSleeveId);
		}),

	/**
	 * Bulk update budgets for siblings
	 * - Root level sleeves must sum to 100%
	 * - Sub-sleeves must sum to their parent's budget
	 */
	updateBudgets: publicProcedure
		.input(
			z.object({
				budgets: z.array(
					z.object({
						sleeveId: z.string(),
						budgetPercent: z.number().min(0).max(100)
					})
				)
			})
		)
		.mutation(async ({ ctx, input }) => {
			if (input.budgets.length === 0) {
				return { success: true };
			}

			// Get the first sleeve to determine the parent
			const [firstSleeve] = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.id, input.budgets[0].sleeveId))
				.limit(1);

			if (!firstSleeve) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Sleeve not found' });
			}

			// Determine the required total based on parent
			let requiredTotal = 100;
			let parentName = 'portfolio';

			if (firstSleeve.parentSleeveId) {
				const [parent] = await ctx.db
					.select()
					.from(sleeves)
					.where(eq(sleeves.id, firstSleeve.parentSleeveId))
					.limit(1);

				if (parent) {
					requiredTotal = parent.budgetPercent;
					parentName = parent.name;
				}
			}

			// Validate total matches required
			const total = input.budgets.reduce((sum, b) => sum + b.budgetPercent, 0);
			if (Math.abs(total - requiredTotal) > 0.01) {
				throw new TRPCError({
					code: 'BAD_REQUEST',
					message: `Budgets must sum to ${requiredTotal.toFixed(1)}% (${parentName}'s budget). Current total: ${total.toFixed(2)}%`
				});
			}

			// Update each sleeve
			for (const budget of input.budgets) {
				await ctx.db
					.update(sleeves)
					.set({ budgetPercent: budget.budgetPercent })
					.where(eq(sleeves.id, budget.sleeveId));
			}

			return { success: true };
		}),

	/**
	 * Assign an asset to a sleeve
	 */
	assignAsset: publicProcedure
		.input(
			z.object({
				sleeveId: z.string(),
				assetIsin: z.string()
			})
		)
		.mutation(async ({ ctx, input }) => {
			// Verify sleeve exists
			const [sleeve] = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.id, input.sleeveId))
				.limit(1);

			if (!sleeve) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Sleeve not found' });
			}

			// Cannot assign to cash sleeves (they're deprecated but may still exist)
			if (sleeve.isCash) {
				throw new TRPCError({
					code: 'BAD_REQUEST',
					message: 'Cannot assign assets to cash sleeve - cash is managed separately'
				});
			}

			// Verify asset exists
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.assetIsin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			// Remove from any existing sleeve in this portfolio
			const portfolioSleeves = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.portfolioId, sleeve.portfolioId));

			const sleeveIds = portfolioSleeves.map((s) => s.id);

			for (const sleeveId of sleeveIds) {
				await ctx.db
					.delete(sleeveAssets)
					.where(and(eq(sleeveAssets.sleeveId, sleeveId), eq(sleeveAssets.assetIsin, input.assetIsin)));
			}

			// Assign to new sleeve
			await ctx.db.insert(sleeveAssets).values({
				sleeveId: input.sleeveId,
				assetIsin: input.assetIsin
			});

			return { success: true };
		}),

	/**
	 * Remove an asset from a sleeve (make it unassigned)
	 */
	unassignAsset: publicProcedure
		.input(
			z.object({
				sleeveId: z.string(),
				assetIsin: z.string()
			})
		)
		.mutation(async ({ ctx, input }) => {
			await ctx.db
				.delete(sleeveAssets)
				.where(and(eq(sleeveAssets.sleeveId, input.sleeveId), eq(sleeveAssets.assetIsin, input.assetIsin)));

			return { success: true };
		}),

	/**
	 * Get all assets with their sleeve assignments for a portfolio
	 */
	getAssetAssignments: publicProcedure
		.input(z.object({ portfolioId: z.string() }))
		.query(async ({ ctx, input }) => {
			// Get all holdings with assets
			const allHoldings = await ctx.db
				.select({
					holding: holdings,
					asset: assets
				})
				.from(holdings)
				.innerJoin(assets, eq(holdings.assetIsin, assets.isin));

			// Get all sleeves for this portfolio
			const portfolioSleeves = await ctx.db
				.select()
				.from(sleeves)
				.where(eq(sleeves.portfolioId, input.portfolioId));

			// Get all assignments for this portfolio's sleeves
			const sleeveIds = portfolioSleeves.map((s) => s.id);
			const assignments = await ctx.db.select().from(sleeveAssets);
			const portfolioAssignments = assignments.filter((a) => sleeveIds.includes(a.sleeveId));

			// Build result with sleeve assignment info
			return allHoldings.map((h) => {
				const assignment = portfolioAssignments.find((a) => a.assetIsin === h.asset.isin);
				const sleeve = assignment ? portfolioSleeves.find((s) => s.id === assignment.sleeveId) : null;

				return {
					asset: h.asset,
					holding: h.holding,
					sleeveId: sleeve?.id ?? null,
					sleeveName: sleeve?.name ?? null
				};
			});
		})
});
