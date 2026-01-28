/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:bagholdr_client/src/protocol/holdings_list_response.dart'
    as _i5;
import 'package:bagholdr_client/src/protocol/return_period.dart' as _i6;
import 'package:bagholdr_client/src/protocol/asset_detail_response.dart' as _i7;
import 'package:bagholdr_client/src/protocol/update_yahoo_symbol_result.dart'
    as _i8;
import 'package:bagholdr_client/src/protocol/clear_price_history_result.dart'
    as _i9;
import 'package:bagholdr_client/src/protocol/sleeve_option.dart' as _i10;
import 'package:bagholdr_client/src/protocol/assign_sleeve_result.dart' as _i11;
import 'package:bagholdr_client/src/protocol/update_asset_type_result.dart'
    as _i12;
import 'package:bagholdr_client/src/protocol/archived_asset_response.dart'
    as _i13;
import 'package:bagholdr_client/src/protocol/refresh_price_result.dart' as _i14;
import 'package:bagholdr_client/src/protocol/import_result.dart' as _i15;
import 'package:bagholdr_client/src/protocol/issues_response.dart' as _i16;
import 'package:bagholdr_client/src/protocol/portfolio.dart' as _i17;
import 'package:bagholdr_client/src/protocol/price_update.dart' as _i18;
import 'package:bagholdr_client/src/protocol/sync_status.dart' as _i19;
import 'package:bagholdr_client/src/protocol/sleeve_tree_response.dart' as _i20;
import 'package:bagholdr_client/src/protocol/portfolio_valuation.dart' as _i21;
import 'package:bagholdr_client/src/protocol/chart_data_result.dart' as _i22;
import 'package:bagholdr_client/src/protocol/chart_range.dart' as _i23;
import 'package:bagholdr_client/src/protocol/historical_returns_result.dart'
    as _i24;
import 'protocol.dart' as _i25;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// Endpoint for holdings/assets list data.
///
/// Returns holdings data for the Assets section of the dashboard.
/// Supports filtering by sleeve (hierarchical), search, and pagination.
/// Calculates MWR and TWR returns for each holding for the selected period.
/// {@category Endpoint}
class EndpointHoldings extends _i2.EndpointRef {
  EndpointHoldings(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'holdings';

  /// Get paginated holdings list with return calculations
  ///
  /// [portfolioId] - Portfolio to fetch holdings for
  /// [period] - Time period for return calculations
  /// [sleeveId] - Optional filter by sleeve (includes children)
  /// [search] - Optional search filter (symbol or name)
  /// [offset] - Pagination offset (default 0)
  /// [limit] - Page size (default 8)
  _i3.Future<_i5.HoldingsListResponse> getHoldings({
    required _i2.UuidValue portfolioId,
    required _i6.ReturnPeriod period,
    _i2.UuidValue? sleeveId,
    String? search,
    required int offset,
    required int limit,
  }) => caller.callServerEndpoint<_i5.HoldingsListResponse>(
    'holdings',
    'getHoldings',
    {
      'portfolioId': portfolioId,
      'period': period,
      'sleeveId': sleeveId,
      'search': search,
      'offset': offset,
      'limit': limit,
    },
  );

  /// Get detailed information for a single asset
  ///
  /// [assetId] - UUID of the asset to fetch
  /// [portfolioId] - Portfolio context (for sleeve assignment and weight)
  /// [period] - Time period for return calculations
  _i3.Future<_i7.AssetDetailResponse> getAssetDetail({
    required _i2.UuidValue assetId,
    required _i2.UuidValue portfolioId,
    required _i6.ReturnPeriod period,
  }) => caller.callServerEndpoint<_i7.AssetDetailResponse>(
    'holdings',
    'getAssetDetail',
    {
      'assetId': assetId,
      'portfolioId': portfolioId,
      'period': period,
    },
  );

  /// Update the Yahoo symbol for an asset
  ///
  /// When the symbol changes, clears all cached price data for the old symbol
  /// to prevent stale data from affecting calculations.
  ///
  /// [assetId] - UUID of the asset to update
  /// [newSymbol] - New Yahoo symbol (null to clear)
  _i3.Future<_i8.UpdateYahooSymbolResult> updateYahooSymbol({
    required _i2.UuidValue assetId,
    String? newSymbol,
  }) => caller.callServerEndpoint<_i8.UpdateYahooSymbolResult>(
    'holdings',
    'updateYahooSymbol',
    {
      'assetId': assetId,
      'newSymbol': newSymbol,
    },
  );

  /// Clear all price history for an asset
  ///
  /// Removes all cached price data: DailyPrice, IntradayPrice, DividendEvent,
  /// TickerMetadata, and PriceCache. Useful when data is corrupted or wrong
  /// symbol was used.
  ///
  /// [assetId] - UUID of the asset to clear price history for
  _i3.Future<_i9.ClearPriceHistoryResult> clearPriceHistory({
    required _i2.UuidValue assetId,
  }) => caller.callServerEndpoint<_i9.ClearPriceHistoryResult>(
    'holdings',
    'clearPriceHistory',
    {'assetId': assetId},
  );

  /// Get available sleeves for assignment picker
  ///
  /// Returns a flat list of sleeves for the portfolio, with hierarchy
  /// indicated by depth field. Excludes cash sleeves.
  ///
  /// [portfolioId] - Portfolio to fetch sleeves for
  _i3.Future<List<_i10.SleeveOption>> getSleevesForPicker({
    required _i2.UuidValue portfolioId,
  }) => caller.callServerEndpoint<List<_i10.SleeveOption>>(
    'holdings',
    'getSleevesForPicker',
    {'portfolioId': portfolioId},
  );

  /// Assign or unassign an asset to/from a sleeve
  ///
  /// [assetId] - UUID of the asset to assign
  /// [sleeveId] - UUID of the sleeve to assign to (null to unassign)
  _i3.Future<_i11.AssignSleeveResult> assignAssetToSleeve({
    required _i2.UuidValue assetId,
    _i2.UuidValue? sleeveId,
  }) => caller.callServerEndpoint<_i11.AssignSleeveResult>(
    'holdings',
    'assignAssetToSleeve',
    {
      'assetId': assetId,
      'sleeveId': sleeveId,
    },
  );

  /// Update the asset type for an asset
  ///
  /// [assetId] - UUID of the asset to update
  /// [newType] - New asset type (stock, etf, bond, fund, commodity, other)
  _i3.Future<_i12.UpdateAssetTypeResult> updateAssetType({
    required _i2.UuidValue assetId,
    required String newType,
  }) => caller.callServerEndpoint<_i12.UpdateAssetTypeResult>(
    'holdings',
    'updateAssetType',
    {
      'assetId': assetId,
      'newType': newType,
    },
  );

  /// Archive or unarchive an asset
  ///
  /// Archived assets are hidden from the dashboard and excluded from all
  /// calculations (valuations, returns, charts, etc).
  ///
  /// When archiving:
  /// - Sets archived=true on the asset
  /// - Removes the asset from all sleeves (deletes SleeveAsset records)
  ///
  /// When unarchiving:
  /// - Sets archived=false on the asset
  /// - User must manually reassign to sleeves if needed
  ///
  /// [assetId] - UUID of the asset to archive/unarchive
  /// [archived] - True to archive, false to unarchive
  _i3.Future<bool> archiveAsset({
    required _i2.UuidValue assetId,
    required bool archived,
  }) => caller.callServerEndpoint<bool>(
    'holdings',
    'archiveAsset',
    {
      'assetId': assetId,
      'archived': archived,
    },
  );

  /// Get all archived assets for a portfolio
  ///
  /// Returns a list of archived assets with basic info for the Manage Assets screen.
  /// Note: Assets are global, but we filter by those that have holdings in the portfolio.
  ///
  /// [portfolioId] - Portfolio to filter by (assets with holdings in this portfolio)
  _i3.Future<List<_i13.ArchivedAssetResponse>> getArchivedAssets({
    required _i2.UuidValue portfolioId,
  }) => caller.callServerEndpoint<List<_i13.ArchivedAssetResponse>>(
    'holdings',
    'getArchivedAssets',
    {'portfolioId': portfolioId},
  );

  /// Refresh prices for a single asset
  ///
  /// Fetches fresh price data from Yahoo Finance, bypassing cache.
  /// [assetId] - UUID of the asset to refresh
  _i3.Future<_i14.RefreshPriceResult> refreshAssetPrices({
    required _i2.UuidValue assetId,
  }) => caller.callServerEndpoint<_i14.RefreshPriceResult>(
    'holdings',
    'refreshAssetPrices',
    {'assetId': assetId},
  );
}

/// Endpoint for importing orders from broker CSV files.
///
/// Parses CSV content, creates assets and orders, and derives holdings.
/// {@category Endpoint}
class EndpointImport extends _i2.EndpointRef {
  EndpointImport(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'import';

  /// Import orders from Directa CSV content.
  ///
  /// [csvContent] - The raw CSV content from Directa export
  ///
  /// Returns an [ImportResult] with counts and any errors encountered.
  _i3.Future<_i15.ImportResult> importDirectaCsv({
    required String csvContent,
  }) => caller.callServerEndpoint<_i15.ImportResult>(
    'import',
    'importDirectaCsv',
    {'csvContent': csvContent},
  );
}

/// Endpoint for detecting portfolio issues/health indicators.
///
/// Detects allocation drift, stale prices, and sync status issues.
/// {@category Endpoint}
class EndpointIssues extends _i2.EndpointRef {
  EndpointIssues(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'issues';

  /// Get portfolio issues
  ///
  /// [portfolioId] - Portfolio to check issues for
  _i3.Future<_i16.IssuesResponse> getIssues({
    required _i2.UuidValue portfolioId,
  }) => caller.callServerEndpoint<_i16.IssuesResponse>(
    'issues',
    'getIssues',
    {'portfolioId': portfolioId},
  );
}

/// Endpoint for portfolio operations.
/// {@category Endpoint}
class EndpointPortfolio extends _i2.EndpointRef {
  EndpointPortfolio(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'portfolio';

  /// Returns all portfolios.
  _i3.Future<List<_i17.Portfolio>> getPortfolios() =>
      caller.callServerEndpoint<List<_i17.Portfolio>>(
        'portfolio',
        'getPortfolios',
        {},
      );
}

/// Endpoint for real-time price streaming and sync control.
/// {@category Endpoint}
class EndpointPriceStream extends _i2.EndpointRef {
  EndpointPriceStream(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'priceStream';

  /// Stream of real-time price updates.
  /// Client subscribes to receive price updates as they happen.
  /// The stream stays open until the client disconnects.
  _i3.Stream<_i18.PriceUpdate> streamPriceUpdates() =>
      caller.callStreamingServerEndpoint<
        _i3.Stream<_i18.PriceUpdate>,
        _i18.PriceUpdate
      >(
        'priceStream',
        'streamPriceUpdates',
        {},
        {},
      );

  /// Get the current sync status.
  _i3.Future<_i19.SyncStatus> getSyncStatus() =>
      caller.callServerEndpoint<_i19.SyncStatus>(
        'priceStream',
        'getSyncStatus',
        {},
      );

  /// Trigger a manual price sync. Returns immediately, sync runs in background.
  _i3.Future<_i19.SyncStatus> triggerSync() =>
      caller.callServerEndpoint<_i19.SyncStatus>(
        'priceStream',
        'triggerSync',
        {},
      );
}

/// Endpoint for sleeve hierarchy and allocation data.
///
/// Returns sleeve tree with allocation percentages, drift status,
/// and MWR/TWR returns for each sleeve for the Strategy section.
/// {@category Endpoint}
class EndpointSleeves extends _i2.EndpointRef {
  EndpointSleeves(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sleeves';

  /// Get sleeve hierarchy with allocation and return data
  ///
  /// [portfolioId] - Portfolio to fetch sleeves for
  /// [period] - Time period for return calculations
  _i3.Future<_i20.SleeveTreeResponse> getSleeveTree({
    required _i2.UuidValue portfolioId,
    required _i6.ReturnPeriod period,
  }) => caller.callServerEndpoint<_i20.SleeveTreeResponse>(
    'sleeves',
    'getSleeveTree',
    {
      'portfolioId': portfolioId,
      'period': period,
    },
  );
}

/// Endpoint for portfolio valuation and allocation calculations.
///
/// Calculates portfolio valuation and allocation percentages.
/// Uses cached prices if available, falls back to cost basis.
/// Supports n-ary tree structure for sleeves - parent sleeves include
/// the value of all their descendants.
///
/// Key concepts:
/// - Cash is NOT a sleeve - it's shown separately
/// - "Invested Only" view: percentages relative to assigned holdings only
/// - "Total Portfolio" view: percentages relative to holdings + cash
/// - Band evaluation only applies to Invested view
/// {@category Endpoint}
class EndpointValuation extends _i2.EndpointRef {
  EndpointValuation(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'valuation';

  /// Get full portfolio valuation with allocation breakdown
  _i3.Future<_i21.PortfolioValuation> getPortfolioValuation(
    _i2.UuidValue portfolioId,
  ) => caller.callServerEndpoint<_i21.PortfolioValuation>(
    'valuation',
    'getPortfolioValuation',
    {'portfolioId': portfolioId},
  );

  /// Get historical chart data for portfolio value visualization.
  /// Returns daily data points with portfolio value and cost basis over time.
  _i3.Future<_i22.ChartDataResult> getChartData(
    _i2.UuidValue portfolioId,
    _i23.ChartRange range,
  ) => caller.callServerEndpoint<_i22.ChartDataResult>(
    'valuation',
    'getChartData',
    {
      'portfolioId': portfolioId,
      'range': range,
    },
  );

  /// Get historical returns for different time periods.
  /// Calculates portfolio value at historical dates and compares to current value.
  _i3.Future<_i24.HistoricalReturnsResult> getHistoricalReturns(
    _i2.UuidValue portfolioId,
  ) => caller.callServerEndpoint<_i24.HistoricalReturnsResult>(
    'valuation',
    'getHistoricalReturns',
    {'portfolioId': portfolioId},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i25.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    holdings = EndpointHoldings(this);
    import = EndpointImport(this);
    issues = EndpointIssues(this);
    portfolio = EndpointPortfolio(this);
    priceStream = EndpointPriceStream(this);
    sleeves = EndpointSleeves(this);
    valuation = EndpointValuation(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointHoldings holdings;

  late final EndpointImport import;

  late final EndpointIssues issues;

  late final EndpointPortfolio portfolio;

  late final EndpointPriceStream priceStream;

  late final EndpointSleeves sleeves;

  late final EndpointValuation valuation;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'holdings': holdings,
    'import': import,
    'issues': issues,
    'portfolio': portfolio,
    'priceStream': priceStream,
    'sleeves': sleeves,
    'valuation': valuation,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
