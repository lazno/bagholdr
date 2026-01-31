# NAPP-050: Account-Portfolio Data Model - Implementation Plan

## Summary

Introduce an **Account** entity so orders and holdings are scoped to specific accounts (broker or virtual), and a **PortfolioAccount** junction table to let portfolios aggregate data from multiple accounts.

## Key Design Decisions

1. **Holdings per (asset + account)**: Same asset can have separate holdings in different accounts with independent cost bases
2. **SleeveAsset unchanged**: Sleeves organize assets at portfolio level; aggregation happens at query time
3. **Import requires accountId**: Caller specifies which account to import into
4. **Migration**: Create "Main Account", migrate all existing data to it

---

## Implementation Steps

### Phase 1: Model Layer

**1.1 Create new models**

`native/bagholdr/bagholdr_server/lib/src/models/account.spy.yaml`:
```yaml
class: Account
table: accounts
fields:
  id: UuidValue?, defaultPersist=random_v7
  name: String
  accountType: String  # 'real' or 'virtual'
  createdAt: DateTime
  updatedAt: DateTime
indexes:
  account_name_idx:
    fields: name
```

`native/bagholdr/bagholdr_server/lib/src/models/portfolio_account.spy.yaml`:
```yaml
class: PortfolioAccount
table: portfolio_accounts
fields:
  id: UuidValue?, defaultPersist=random_v7
  portfolioId: UuidValue, relation(parent=portfolios)
  accountId: UuidValue, relation(parent=accounts)
indexes:
  portfolio_account_unique_idx:
    fields: portfolioId, accountId
    unique: true
  portfolio_account_portfolio_idx:
    fields: portfolioId
  portfolio_account_account_idx:
    fields: accountId
```

**1.2 Modify existing models**

`order.spy.yaml` - Add after line 8:
```yaml
  accountId: UuidValue, relation(parent=accounts)
```
Add to indexes:
```yaml
  order_account_idx:
    fields: accountId
```

`holding.spy.yaml` - Add after line 8:
```yaml
  accountId: UuidValue, relation(parent=accounts)
```
Change index to:
```yaml
  holding_account_asset_idx:
    fields: accountId, assetId
    unique: true
```

**1.3 Generate and migrate**
```bash
cd native/bagholdr/bagholdr_server
"$HOME/.pub-cache/bin/serverpod" generate
"$HOME/.pub-cache/bin/serverpod" create-migration
```

Edit the generated migration to add data migration SQL at the top (create Main Account, update existing rows).

### Phase 2: Account CRUD Endpoint

Create `native/bagholdr/bagholdr_server/lib/src/endpoints/account_endpoint.dart`:
- `getAccounts()` - List all accounts
- `createAccount(name, accountType)` - Create account
- `updateAccount(accountId, name)` - Update account
- `getPortfolioAccounts(portfolioId)` - List accounts for portfolio
- `addAccountToPortfolio(portfolioId, accountId)` - Link account
- `removeAccountFromPortfolio(portfolioId, accountId)` - Unlink account

### Phase 3: Update Import

Modify `import_endpoint.dart`:
- Add `required UuidValue accountId` parameter to `importDirectaCsv`
- Pass `accountId` when creating Order records
- Filter orders by accountId when deriving holdings

Modify `derive_holdings.dart`:
- No changes needed to logic - it already works per-ISIN
- Import endpoint will call it with account-filtered orders

### Phase 4: Update Query Endpoints

Create helper `native/bagholdr/bagholdr_server/lib/src/utils/portfolio_accounts.dart`:
```dart
Future<Set<UuidValue>> getPortfolioAccountIds(Session session, UuidValue portfolioId) async {
  final links = await PortfolioAccount.db.find(
    session,
    where: (t) => t.portfolioId.equals(portfolioId),
  );
  return links.map((l) => l.accountId).toSet();
}
```

Update these endpoints to filter by portfolio's accounts:
- `holdings_endpoint.dart` - `getHoldings`, `getAssetDetail`
- `valuation_endpoint.dart` - `getPortfolioValuation`, `getChartData`
- `sleeves_endpoint.dart` - `getSleeveTree`

Pattern for each:
```dart
final accountIds = await getPortfolioAccountIds(session, portfolioId);
final holdings = await Holding.db.find(
  session,
  where: (t) => t.quantity > 0.0 & t.accountId.inSet(accountIds),
);
```

### Phase 5: Aggregation Logic

When same asset exists in multiple accounts, aggregate:
- Group holdings by assetId
- Sum quantities and cost bases across accounts
- Use aggregated values for weight, returns calculations

---

## Files to Modify

| File | Changes |
|------|---------|
| `models/account.spy.yaml` | **NEW** |
| `models/portfolio_account.spy.yaml` | **NEW** |
| `models/order.spy.yaml` | Add `accountId` field |
| `models/holding.spy.yaml` | Add `accountId`, change unique index |
| `endpoints/account_endpoint.dart` | **NEW** - CRUD for accounts |
| `endpoints/import_endpoint.dart` | Add `accountId` param |
| `endpoints/holdings_endpoint.dart` | Filter by portfolio accounts |
| `endpoints/valuation_endpoint.dart` | Filter by portfolio accounts |
| `endpoints/sleeves_endpoint.dart` | Filter by portfolio accounts |
| `utils/portfolio_accounts.dart` | **NEW** - helper function |

---

## Verification

1. **Unit tests**: Add tests for account CRUD, per-account holdings derivation
2. **Integration test**:
   - Start server: `cd native/bagholdr/bagholdr_server && dart bin/main.dart --apply-migrations`
   - Create account via endpoint
   - Import CSV with accountId
   - Verify holdings have accountId set
   - Verify dashboard shows correct data
3. **Migration verification**:
   - All existing orders have accountId = Main Account
   - All existing holdings have accountId = Main Account
   - All existing portfolios linked to Main Account
   - Dashboard still works (no data loss)

---

## Acceptance Criteria

- [ ] Accounts can be created/listed/updated
- [ ] Orders belong to an account
- [ ] Portfolios reference one or more accounts
- [ ] Existing data migrates cleanly
- [ ] Dashboard shows holdings from portfolio's accounts only
