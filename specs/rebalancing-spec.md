# Rebalancing Spec

Central feature for generating and reviewing portfolio rebalancing plans that respect both sleeve allocation targets and exposure rules.

## Core Concept

Rebalancing is **multi-objective optimization** with honest constraints. The system considers:

1. **Sleeve allocation** - Getting sleeves to their target percentages
2. **Exposure rules** - Staying within sector/country/market cap limits
3. **Feasibility** - What's actually achievable with current holdings

## Key Principles

### Tradeoffs are visible

Every transaction affects multiple dimensions. The UI must show:
- What improves
- What worsens
- Net impact

Users make informed decisions, not blind ones.

### Honest about limitations

The rebalancer cannot magically fix everything. It must communicate:
- What's achievable by shuffling current holdings
- What requires selling (reducing positions)
- What requires buying new asset classes
- What's simply impossible given current portfolio composition

### Not a stock picker

The system suggests **categories** not tickers:
- "You need non-US equity exposure" ✓
- "Buy VXUS" ✗

## Rebalancing Modes

### Shuffle Mode
Redistribute between existing holdings without adding/removing capital.
- Input: Current holdings
- Output: Transfer suggestions (sell X, buy Y)
- Use case: "I have cash in sleeve A, should it go to sleeve B?"

### Trim Mode
Sell positions to fix violations or free up capital.
- Input: Current holdings + target to fix
- Output: Sell suggestions
- Use case: "I'm over-concentrated in Tech"

### Expand Mode
Identify portfolio gaps that can't be fixed with current holdings.
- Input: Current holdings + exposure rules
- Output: Gap analysis + category suggestions
- Use case: "What am I missing for proper diversification?"

## Rebalancing Assessment

Before generating a plan, show what's possible:

```
Portfolio Rebalancing Potential
───────────────────────────────
                    Current  Target  Best Achievable*  Gap
Tech                  38%     ≤25%      31%            6pp
US                    72%     ≤60%      45%            —
Mega Cap              58%     ≤50%      42%            —
Satellite sleeve      24%     =30%      30%            —

* By redistributing current holdings only

⚠ Tech target unreachable without adding non-Tech assets
  Your portfolio lacks: Healthcare, Consumer, Utilities exposure
```

This sets realistic expectations before any plan is generated.

## Plan Generation

### Input
- Sleeve allocation targets
- Exposure rules (with priorities/weights)
- Constraints: tax considerations, minimum lot sizes, locked positions

### Output
A reviewable transaction list:

```
Recommended Plan (3 transactions)
─────────────────────────────────

1. Sell €8,000 QQQ (Satellite)

            Before    After    Target    Status
   Tech       38%  →   32%      ≤25%     ✓ improves
   US         72%  →   66%      ≤60%     ✓ improves
   Satellite  24%  →   18%      =30%     ✗ worsens

2. Buy €6,000 VXUS (Core)

            Before    After    Target    Status
   Tech       32%  →   30%      ≤25%     ✓ improves
   US         66%  →   58%      ≤60%     ✓ fixed!
   Core       70%  →   75%      =70%     ~ slightly over

3. Buy €2,000 VXUS (Satellite)

            Before    After    Target    Status
   Satellite  18%  →   20%      =30%     ✓ improves

Final state: Tech 29% (4pp over), US 56% (✓), Sleeves close to target
```

### Alternative Plans

When significant tradeoffs exist, offer options:

```
Option A: Prioritize Exposure
  Fix Tech and US violations
  Satellite drops to 12% (under target)

Option B: Prioritize Sleeves
  Get sleeves to target
  Tech remains at 35%

Option C: Balanced
  Partial improvement on all dimensions
  No single metric fully optimized
```

## Portfolio Gap Analysis

When current holdings can't achieve targets:

```
Exposure Gaps
─────────────

Your portfolio cannot reach these targets with current holdings:

Tech ≤25%
  Current: 38% | Best achievable: 31% | Gap: 6pp

  Why: All your equity holdings have Tech exposure (18-50%)

  To fix, you would need:
  • Non-Tech equity worth ~€15,000, OR
  • Sell €18,000 of current Tech holdings

  Missing categories: Healthcare, Financials, Consumer, Utilities

───────────────

Diversification suggestions:
• Broad non-Tech sector ETF
• International developed markets (lower Tech weight than US)
• Sector-specific ETFs in underweight areas
```

## UI Flow

### Entry Points
- "Fix" button on exposure violations
- "Rebalance" button on sleeve allocation view
- Dedicated Rebalancing page in main navigation

### Rebalancing Page Structure

1. **Assessment panel** - What's achievable, what's not
2. **Plan generator** - Configure constraints, generate plan
3. **Plan review** - See transactions with full impact analysis
4. **Gap analysis** - What's missing from portfolio

### Integration with Other Pages

- **Exposure page**: Shows violations, links to rebalancing with context
- **Sleeves page**: Shows allocation vs target, links to rebalancing
- **Holdings page**: Can mark positions as "locked" (exclude from rebalancing)

## Technical Considerations

### Algorithm
- Multi-objective optimization
- Constraints: sleeve membership, exposure contribution per asset
- Minimize transaction count while maximizing improvement

### Data Requirements
- Asset → Sleeve mapping
- Asset → Exposure breakdown (via look-through for ETFs)
- Sleeve targets
- Exposure rules with limits

### Edge Cases
- Empty sleeves
- Assets with unknown breakdown (treat as concentrated risk)
- Locked/restricted positions
- Fractional shares considerations

## Out of Scope (v1)

- Tax-loss harvesting optimization
- Wash sale rule checking
- Broker integration / auto-execution
- Specific ticker recommendations
- Historical rebalancing tracking
