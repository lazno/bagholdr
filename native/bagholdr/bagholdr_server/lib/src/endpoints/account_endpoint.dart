import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing accounts (data sources for orders/holdings).
///
/// Accounts represent broker accounts or virtual accounts for paper trading.
/// Orders and holdings belong to accounts. Portfolios aggregate one or more accounts.
class AccountEndpoint extends Endpoint {
  /// Get all accounts.
  ///
  /// Returns a list of all accounts ordered by name.
  Future<List<Account>> getAccounts(Session session) async {
    return await Account.db.find(
      session,
      orderBy: (t) => t.name,
    );
  }

  /// Create a new account.
  ///
  /// [name] - Display name for the account (e.g., "Directa", "Paper Trading")
  /// [accountType] - Type of account: 'real' (broker) or 'virtual' (paper trading)
  ///
  /// Returns the created account.
  Future<Account> createAccount(
    Session session, {
    required String name,
    required String accountType,
  }) async {
    // Validate account type
    if (accountType != 'real' && accountType != 'virtual') {
      throw Exception('Invalid account type: $accountType. Must be "real" or "virtual".');
    }

    final now = DateTime.now();
    final account = Account(
      name: name,
      accountType: accountType,
      createdAt: now,
      updatedAt: now,
    );

    return await Account.db.insertRow(session, account);
  }

  /// Update an existing account.
  ///
  /// [accountId] - UUID of the account to update
  /// [name] - New display name
  ///
  /// Returns the updated account.
  Future<Account> updateAccount(
    Session session, {
    required UuidValue accountId,
    required String name,
  }) async {
    final account = await Account.db.findById(session, accountId);
    if (account == null) {
      throw Exception('Account not found: $accountId');
    }

    account.name = name;
    account.updatedAt = DateTime.now();

    return await Account.db.updateRow(session, account);
  }

  /// Get accounts linked to a portfolio.
  ///
  /// [portfolioId] - UUID of the portfolio
  ///
  /// Returns a list of accounts that are linked to the portfolio.
  Future<List<Account>> getPortfolioAccounts(
    Session session, {
    required UuidValue portfolioId,
  }) async {
    // Get portfolio-account links
    final links = await PortfolioAccount.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId),
    );

    if (links.isEmpty) {
      return [];
    }

    // Get accounts by IDs
    final accountIds = links.map((l) => l.accountId).toSet();
    final accounts = await Account.db.find(
      session,
      where: (t) => t.id.inSet(accountIds),
      orderBy: (t) => t.name,
    );

    return accounts;
  }

  /// Link an account to a portfolio.
  ///
  /// [portfolioId] - UUID of the portfolio
  /// [accountId] - UUID of the account to link
  ///
  /// Returns true if the link was created, false if it already exists.
  Future<bool> addAccountToPortfolio(
    Session session, {
    required UuidValue portfolioId,
    required UuidValue accountId,
  }) async {
    // Verify portfolio exists
    final portfolio = await Portfolio.db.findById(session, portfolioId);
    if (portfolio == null) {
      throw Exception('Portfolio not found: $portfolioId');
    }

    // Verify account exists
    final account = await Account.db.findById(session, accountId);
    if (account == null) {
      throw Exception('Account not found: $accountId');
    }

    // Check if link already exists
    final existingLink = await PortfolioAccount.db.findFirstRow(
      session,
      where: (t) =>
          t.portfolioId.equals(portfolioId) & t.accountId.equals(accountId),
    );

    if (existingLink != null) {
      return false; // Already linked
    }

    // Create link
    final link = PortfolioAccount(
      portfolioId: portfolioId,
      accountId: accountId,
    );
    await PortfolioAccount.db.insertRow(session, link);

    return true;
  }

  /// Unlink an account from a portfolio.
  ///
  /// [portfolioId] - UUID of the portfolio
  /// [accountId] - UUID of the account to unlink
  ///
  /// Returns true if the link was removed, false if it didn't exist.
  Future<bool> removeAccountFromPortfolio(
    Session session, {
    required UuidValue portfolioId,
    required UuidValue accountId,
  }) async {
    final deleted = await PortfolioAccount.db.deleteWhere(
      session,
      where: (t) =>
          t.portfolioId.equals(portfolioId) & t.accountId.equals(accountId),
    );

    return deleted.isNotEmpty;
  }
}
