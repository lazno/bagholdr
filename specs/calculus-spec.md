# Financial Calculations Specification

This document defines all financial calculations used in Bagholdr. All monetary values are in EUR unless otherwise noted.

---

## Core Concepts

### Cost Basis (Average Cost Method)

The total amount paid to acquire current holdings, calculated using the **Average Cost Method**.

#### Why Average Cost Method?

Several methods exist for tracking cost basis:
- **FIFO (First In, First Out)**: Sells reduce the oldest lots first
- **LIFO (Last In, First Out)**: Sells reduce the newest lots first
- **Specific Identification**: Manually choose which lots to sell
- **Average Cost**: All shares are treated as having the same cost

Bagholdr uses **Average Cost** because:
1. It's simple and doesn't require tracking individual lots
2. It's commonly used for mutual funds and ETFs
3. It provides a consistent, predictable cost basis

#### Calculation Algorithm

Orders are processed **chronologically** for each asset:

```
For each order (sorted by date):
  If BUY (quantity > 0):
    totalCost += order.amount
    totalQty += order.quantity
    avgCost = totalCost / totalQty

  If SELL (quantity < 0):
    soldQty = abs(order.quantity)
    costReduction = avgCost × soldQty
    totalCost -= costReduction
    totalQty -= soldQty
    (avgCost stays the same after sells)

  If COMMISSION (quantity = 0):
    totalCost += order.amount
    (adds to cost basis without changing quantity)
```

#### Commission Handling

Commissions are included in the cost basis. In broker CSV exports (e.g., Directa), commissions appear as separate line items with:
- Same `orderReference` as the related trade
- `quantity = 0`
- `amount` = the commission fee

This increases the average cost per share, correctly reflecting the true cost of acquiring the position.

#### Example

| Order | Action | Qty | Price | Amount | Total Qty | Total Cost | Avg Cost |
|-------|--------|-----|-------|--------|-----------|------------|----------|
| 1 | Buy | 100 | $10 | $1,000 | 100 | $1,000 | $10.00 |
| 1b | Commission | 0 | - | $5 | 100 | $1,005 | $10.05 |
| 2 | Buy | 50 | $14 | $700 | 150 | $1,705 | $11.37 |
| 2b | Commission | 0 | - | $5 | 150 | $1,710 | $11.40 |
| 3 | Sell | 75 | $15 | - | 75 | $855 | $11.40 |
| 4 | Buy | 25 | $12 | $300 | 100 | $1,155 | $11.55 |
| 4b | Commission | 0 | - | $5 | 100 | $1,160 | $11.60 |

**Key insights**:
- Selling does NOT change the average cost per share - it only reduces total cost proportionally
- Commissions increase the average cost per share (they add cost without adding shares)

#### Cost Basis Formula

```
Remaining Cost Basis = Total Buy Cost - (Shares Sold × Avg Cost at Time of Sale)
```

For a single holding:
```
Average Cost per Share = Total Cost Basis / Current Quantity
```

#### Multi-Currency Handling

Cost basis is tracked in both EUR and native currency:
- **Cost Basis EUR**: Uses the EUR amount from orders (FX rate at time of purchase)
- **Cost Basis Native**: Uses the native currency amount from orders

This allows accurate P/L calculation regardless of currency fluctuations.

### Current Value

The current market value of holdings.

```
Current Value = Sum of (current price × quantity) for all holdings
```

#### Price Source: Last Trade vs Bid

Bagholdr uses the **last trade price** (regularMarketPrice from Yahoo Finance) for valuation. This is also known as "mark-to-market" pricing.

Some brokers use the **bid price** instead, which represents the "liquidation value" - what you'd actually receive if you sold immediately.

**Impact:**
- During market hours, the spread between bid and last is typically small (0.1-1%)
- For less liquid assets, the difference can be larger
- This may cause P/L values to differ slightly from broker-reported values

**Example (UPS stock):**
- Last trade: $108.06
- Bid: $106.11
- Difference: ~1.8%

For a 30-share position, this creates a ~$58 USD (~€50 EUR) difference in reported present value.

**Future enhancement:** Add option to use bid price for valuation to match broker methodology.

### Invested Value

Same as Current Value. This is the market value of what's invested (excludes cash).

```
Invested Value = Current Value
```

### Total Value

The sum of invested value and cash.

```
Total Value = Invested Value + Cash
```

---

## Return Calculations

### Absolute Return

The difference between current value and comparison value.

```
Absolute Return = Current Value - Comparison Value
```

### Percentage Return

The return expressed as a percentage of the comparison value.

```
Percentage Return = ((Current Value - Comparison Value) / Comparison Value) × 100
```

### Return Periods

| Period | Comparison Value |
|--------|-----------------|
| Today | Portfolio value at previous trading day's close |
| 1W | Portfolio value 7 calendar days ago |
| 1M | Portfolio value 30 calendar days ago |
| YTD | Portfolio value on December 31 of previous year |
| 1Y | Portfolio value 365 calendar days ago |
| All | Portfolio value at first order date (inception) |

#### Historical Portfolio Value

To calculate portfolio value at a historical date:

```
Historical Value(date) = Sum of (
  quantity_held_on_date × closing_price_on_date
) for each asset
```

**Note**: This requires knowing how many shares were held on each date, which comes from the order history.

#### Handling Missing Prices

If price data is missing for a specific date:
1. Use the most recent available price before that date
2. If no prior price exists, use the earliest available price

### Money-Weighted Return (MWR) / XIRR

**Bagholdr uses MWR (Money-Weighted Return) as the primary return calculation method.** MWR gives users their actual rate of return on the money they invested, accounting for when deposits and withdrawals were made.

#### Why MWR?

The naive return calculation:
```
Naive Return = (Current Value - Historical Value) / Historical Value
```

This is misleading when cash flows occur. For example:
- Portfolio value 30 days ago: €86,000
- User deposits €19,000 and buys shares
- Portfolio value today: €111,000
- Naive calculation: +29% (wrong - includes new deposits as "gains")

MWR finds the constant annual rate of return that, given the timing of cash flows, would produce the actual ending value.

#### MWR vs TWR

| Metric | MWR (Money-Weighted) | TWR (Time-Weighted) |
|--------|---------------------|---------------------|
| Measures | Your actual return on invested money | Pure investment performance |
| Best for | Personal portfolio evaluation | Comparing fund managers |
| Cash flow impact | Captures timing benefits/costs | Neutralizes timing |
| Use case | "How well did MY money do?" | "How well did THE FUND do?" |

Bagholdr uses **MWR** because most users want to know their actual return, including the impact of when they invested.

#### MWR Formula (XIRR)

MWR is calculated using XIRR (Extended Internal Rate of Return), which solves for the rate `r` in:

```
0 = Σ (CFᵢ × (1 + r)^(years from date i to end))
```

Where:
- CF₀ = -Starting Portfolio Value (initial "investment")
- CFᵢ = -Cash Flow Amount (buys are negative, sells are positive)
- CFₙ = +Ending Portfolio Value (final "withdrawal")

The XIRR algorithm uses Newton-Raphson iteration to find the rate.

#### Display Format

Returns are shown in two forms:

1. **Compounded Return**: Total % gain/loss over the period
   - Formula: `(1 + annualized)^years - 1`
   - Example: +33.4%

2. **Annualized Return (p.a.)**: Annual rate of return
   - Direct output from XIRR
   - Example: +8.5% p.a.

UI display: `+33.4% (+8.5% p.a.)`

The annualized form is particularly useful for comparing returns across different time periods.

#### Absolute Return

Absolute return represents the actual profit/loss:

```
Absolute Return = Current Value - Start Value - Net Cash Flows
                = Profit (excluding deposits/withdrawals)
```

This formula correctly attributes only investment gains/losses, not new money added.

#### Example Calculation

Period: All (2 years, starting Jan 1, 2023)

Cash flows:
| Date | Event | Amount |
|------|-------|--------|
| Jan 1, 2023 | Start | €60,000 portfolio value |
| Jul 15, 2023 | Buy | €20,000 deposit |
| Mar 1, 2024 | Buy | €15,000 deposit |
| Jan 1, 2025 | End | €111,000 portfolio value |

XIRR transactions:
- (-60,000, Jan 1, 2023)
- (-20,000, Jul 15, 2023)
- (-15,000, Mar 1, 2024)
- (+111,000, Jan 1, 2025)

**Result**: XIRR finds rate r = 8.5% p.a.

**Calculations**:
- Annualized Return: **+8.5% p.a.**
- Compounded Return (2 years): (1.085)² - 1 = **+17.7%**
- Absolute Return: €111,000 - €60,000 - €35,000 = **+€16,000**

#### Cash Flow Detection

Cash flows are detected from the orders table:
- **Buy orders** (quantity > 0): Positive cash flow (money entering portfolio)
- **Sell orders** (quantity < 0): Negative cash flow (money leaving portfolio)
- **Commissions** (quantity = 0): Not a cash flow (internal expense)

#### Edge Cases

- **No cash flows in period**: MWR equals simple annualized return
- **Very short periods (< 1 day)**: Uses simple return without annualization
- **XIRR fails to converge**: Falls back to simple annualized return
- **Zero starting value**: Returns 0% (can't calculate return with no capital)

#### Short Holdings

For individual assets, if an asset was purchased after the selected period start date:
- Returns are calculated from the asset's inception (first purchase date)
- A visual indicator shows the actual holding period (e.g., "6mo")
- Both compounded and annualized returns reflect the shorter actual period

### Time-Weighted Return (TWR) - Reserved for Benchmarks

TWR is kept available for future benchmark comparison features. It measures pure investment performance by neutralizing the timing of cash flows.

#### TWR Formula

TWR breaks the period into sub-periods at each cash flow and geometrically links the returns:

```
TWR = [(1 + R₁) × (1 + R₂) × ... × (1 + Rₙ)] - 1

Where Rᵢ = (Ending Value - Beginning Value) / Beginning Value
```

TWR is useful for comparing portfolio performance against benchmarks (like S&P 500) because it removes the impact of when you personally added or removed money.

---

## Allocation Calculations

### Weight (Portfolio Weight)

The percentage of the portfolio that an asset represents.

```
Weight = (Asset Value / Total Invested Value) × 100
```

### Sleeve Allocation

The percentage of the portfolio in a sleeve.

```
Sleeve Actual % = (Sum of Asset Values in Sleeve / Total Invested Value) × 100
```

For parent sleeves with children:
```
Parent Actual % = Own Assets Value + Sum of Children Actual Values
                  ─────────────────────────────────────────────────
                           Total Invested Value
```

### Deviation

The difference between actual and target allocation.

```
Deviation = Actual % - Target %
```

Expressed in percentage points (pp):
- "+2pp" means 2 percentage points over target
- "-3pp" means 3 percentage points under target

---

## Band Calculations

Bands define the acceptable range around a target allocation.

### Band Width

```
Half Width = clamp(
  Target % × Relative Tolerance / 100,
  Absolute Floor,
  Absolute Cap
)

Lower Band = Target % - Half Width
Upper Band = Target % + Half Width
```

Default parameters:
- Relative Tolerance: 20%
- Absolute Floor: 2pp
- Absolute Cap: 10pp

### Band Status

| Status | Condition |
|--------|-----------|
| In-band (ok) | Lower Band ≤ Actual % ≤ Upper Band |
| Warning | Within 20% of band edge |
| Out-of-band | Actual % < Lower Band OR Actual % > Upper Band |

---

## Per-Asset Calculations

### Unrealized P/L

```
Unrealized P/L = Current Value - Cost Basis
               = (Current Price × Quantity) - (Average Cost × Quantity)
               = (Current Price - Average Cost) × Quantity
```

### Asset Return %

```
Asset Return % = ((Current Price - Average Cost) / Average Cost) × 100
```

For period-specific returns:
```
Asset Period Return % = ((Current Price - Price at Period Start) / Price at Period Start) × 100
```

---

## Chart Data Calculations

### Daily Portfolio Value Series

For each date in the range:

```
Portfolio Value(date) = Sum of (
  shares_held(date) × closing_price(date)
) for each asset
```

Where `shares_held(date)` is derived from order history.

### Cost Basis Series

For each date in the range:

```
Cost Basis(date) = Cumulative cost basis up to that date
```

This increases with buys and decreases proportionally with sells.

---

## Concentration Rules

### Single Asset Concentration

```
Concentration % = (Asset Value / Total Invested Value) × 100
```

Rule violation occurs when:
```
Concentration % > Max Allowed %
```

Can be filtered by asset type (e.g., only stocks, not ETFs).

---

## Health Issue Detection

### Stale Prices

An asset has stale prices if:
```
Current Time - Last Price Fetch Time > Threshold (default: 24 hours)
```

### Unassigned Assets

A holding is unassigned if it exists in `holdings` but has no entry in `sleeve_assets` for the current portfolio.

### Missing Yahoo Symbol

An asset is missing a symbol if:
```
asset.yahooSymbol IS NULL
```

### Allocation Drift

A sleeve has allocation drift if its band status is not "in-band".

---

## Currency Handling

All calculations are performed in EUR. For assets in other currencies:

```
Value in EUR = Value in Native Currency × FX Rate (Native to EUR)
```

FX rates are cached and refreshed periodically.

---

## Precision and Rounding

- Monetary values: Round to 2 decimal places for display
- Percentages: Round to 1 decimal place for display
- Internal calculations: Use full precision, only round for display

---

## Edge Cases

### Zero Holdings

If no holdings exist:
- Invested Value = 0
- Return % = 0 (not undefined)
- Weight calculations are N/A

### New Positions

For assets purchased today with no historical price:
- Today's return = 0
- Use purchase price as baseline

### Sold-Out Positions

Positions that were fully sold should:
- Not appear in current holdings
- Still contribute to historical portfolio value calculations

### Dividends

Dividends are tracked in `dividend_events` but NOT currently included in return calculations. Future enhancement.
