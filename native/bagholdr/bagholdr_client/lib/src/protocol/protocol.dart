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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'account.dart' as _i2;
import 'allocation_status.dart' as _i3;
import 'archived_asset_response.dart' as _i4;
import 'asset.dart' as _i5;
import 'asset_detail_response.dart' as _i6;
import 'asset_period_return.dart' as _i7;
import 'asset_type.dart' as _i8;
import 'asset_valuation.dart' as _i9;
import 'assign_sleeve_result.dart' as _i10;
import 'band.dart' as _i11;
import 'band_config.dart' as _i12;
import 'chart_data_point.dart' as _i13;
import 'chart_data_result.dart' as _i14;
import 'chart_range.dart' as _i15;
import 'clear_price_history_result.dart' as _i16;
import 'concentration_violation.dart' as _i17;
import 'daily_price.dart' as _i18;
import 'dividend_event.dart' as _i19;
import 'fx_cache.dart' as _i20;
import 'global_cash.dart' as _i21;
import 'historical_returns_result.dart' as _i22;
import 'holding.dart' as _i23;
import 'holding_response.dart' as _i24;
import 'holdings_list_response.dart' as _i25;
import 'import_result.dart' as _i26;
import 'intraday_price.dart' as _i27;
import 'issue.dart' as _i28;
import 'issue_severity.dart' as _i29;
import 'issue_type.dart' as _i30;
import 'issues_response.dart' as _i31;
import 'missing_symbol_asset.dart' as _i32;
import 'order.dart' as _i33;
import 'order_summary.dart' as _i34;
import 'period_return.dart' as _i35;
import 'portfolio.dart' as _i36;
import 'portfolio_account.dart' as _i37;
import 'portfolio_rule.dart' as _i38;
import 'portfolio_valuation.dart' as _i39;
import 'price_cache.dart' as _i40;
import 'price_update.dart' as _i41;
import 'refresh_price_result.dart' as _i42;
import 'return_period.dart' as _i43;
import 'sleeve.dart' as _i44;
import 'sleeve_allocation.dart' as _i45;
import 'sleeve_asset.dart' as _i46;
import 'sleeve_node.dart' as _i47;
import 'sleeve_option.dart' as _i48;
import 'sleeve_tree_response.dart' as _i49;
import 'stale_price_asset.dart' as _i50;
import 'sync_status.dart' as _i51;
import 'ticker_metadata.dart' as _i52;
import 'update_asset_type_result.dart' as _i53;
import 'update_yahoo_symbol_result.dart' as _i54;
import 'yahoo_symbol.dart' as _i55;
import 'package:bagholdr_client/src/protocol/account.dart' as _i56;
import 'package:bagholdr_client/src/protocol/sleeve_option.dart' as _i57;
import 'package:bagholdr_client/src/protocol/archived_asset_response.dart'
    as _i58;
import 'package:bagholdr_client/src/protocol/portfolio.dart' as _i59;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i60;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i61;
export 'account.dart';
export 'allocation_status.dart';
export 'archived_asset_response.dart';
export 'asset.dart';
export 'asset_detail_response.dart';
export 'asset_period_return.dart';
export 'asset_type.dart';
export 'asset_valuation.dart';
export 'assign_sleeve_result.dart';
export 'band.dart';
export 'band_config.dart';
export 'chart_data_point.dart';
export 'chart_data_result.dart';
export 'chart_range.dart';
export 'clear_price_history_result.dart';
export 'concentration_violation.dart';
export 'daily_price.dart';
export 'dividend_event.dart';
export 'fx_cache.dart';
export 'global_cash.dart';
export 'historical_returns_result.dart';
export 'holding.dart';
export 'holding_response.dart';
export 'holdings_list_response.dart';
export 'import_result.dart';
export 'intraday_price.dart';
export 'issue.dart';
export 'issue_severity.dart';
export 'issue_type.dart';
export 'issues_response.dart';
export 'missing_symbol_asset.dart';
export 'order.dart';
export 'order_summary.dart';
export 'period_return.dart';
export 'portfolio.dart';
export 'portfolio_account.dart';
export 'portfolio_rule.dart';
export 'portfolio_valuation.dart';
export 'price_cache.dart';
export 'price_update.dart';
export 'refresh_price_result.dart';
export 'return_period.dart';
export 'sleeve.dart';
export 'sleeve_allocation.dart';
export 'sleeve_asset.dart';
export 'sleeve_node.dart';
export 'sleeve_option.dart';
export 'sleeve_tree_response.dart';
export 'stale_price_asset.dart';
export 'sync_status.dart';
export 'ticker_metadata.dart';
export 'update_asset_type_result.dart';
export 'update_yahoo_symbol_result.dart';
export 'yahoo_symbol.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Account) {
      return _i2.Account.fromJson(data) as T;
    }
    if (t == _i3.AllocationStatus) {
      return _i3.AllocationStatus.fromJson(data) as T;
    }
    if (t == _i4.ArchivedAssetResponse) {
      return _i4.ArchivedAssetResponse.fromJson(data) as T;
    }
    if (t == _i5.Asset) {
      return _i5.Asset.fromJson(data) as T;
    }
    if (t == _i6.AssetDetailResponse) {
      return _i6.AssetDetailResponse.fromJson(data) as T;
    }
    if (t == _i7.AssetPeriodReturn) {
      return _i7.AssetPeriodReturn.fromJson(data) as T;
    }
    if (t == _i8.AssetType) {
      return _i8.AssetType.fromJson(data) as T;
    }
    if (t == _i9.AssetValuation) {
      return _i9.AssetValuation.fromJson(data) as T;
    }
    if (t == _i10.AssignSleeveResult) {
      return _i10.AssignSleeveResult.fromJson(data) as T;
    }
    if (t == _i11.Band) {
      return _i11.Band.fromJson(data) as T;
    }
    if (t == _i12.BandConfig) {
      return _i12.BandConfig.fromJson(data) as T;
    }
    if (t == _i13.ChartDataPoint) {
      return _i13.ChartDataPoint.fromJson(data) as T;
    }
    if (t == _i14.ChartDataResult) {
      return _i14.ChartDataResult.fromJson(data) as T;
    }
    if (t == _i15.ChartRange) {
      return _i15.ChartRange.fromJson(data) as T;
    }
    if (t == _i16.ClearPriceHistoryResult) {
      return _i16.ClearPriceHistoryResult.fromJson(data) as T;
    }
    if (t == _i17.ConcentrationViolation) {
      return _i17.ConcentrationViolation.fromJson(data) as T;
    }
    if (t == _i18.DailyPrice) {
      return _i18.DailyPrice.fromJson(data) as T;
    }
    if (t == _i19.DividendEvent) {
      return _i19.DividendEvent.fromJson(data) as T;
    }
    if (t == _i20.FxCache) {
      return _i20.FxCache.fromJson(data) as T;
    }
    if (t == _i21.GlobalCash) {
      return _i21.GlobalCash.fromJson(data) as T;
    }
    if (t == _i22.HistoricalReturnsResult) {
      return _i22.HistoricalReturnsResult.fromJson(data) as T;
    }
    if (t == _i23.Holding) {
      return _i23.Holding.fromJson(data) as T;
    }
    if (t == _i24.HoldingResponse) {
      return _i24.HoldingResponse.fromJson(data) as T;
    }
    if (t == _i25.HoldingsListResponse) {
      return _i25.HoldingsListResponse.fromJson(data) as T;
    }
    if (t == _i26.ImportResult) {
      return _i26.ImportResult.fromJson(data) as T;
    }
    if (t == _i27.IntradayPrice) {
      return _i27.IntradayPrice.fromJson(data) as T;
    }
    if (t == _i28.Issue) {
      return _i28.Issue.fromJson(data) as T;
    }
    if (t == _i29.IssueSeverity) {
      return _i29.IssueSeverity.fromJson(data) as T;
    }
    if (t == _i30.IssueType) {
      return _i30.IssueType.fromJson(data) as T;
    }
    if (t == _i31.IssuesResponse) {
      return _i31.IssuesResponse.fromJson(data) as T;
    }
    if (t == _i32.MissingSymbolAsset) {
      return _i32.MissingSymbolAsset.fromJson(data) as T;
    }
    if (t == _i33.Order) {
      return _i33.Order.fromJson(data) as T;
    }
    if (t == _i34.OrderSummary) {
      return _i34.OrderSummary.fromJson(data) as T;
    }
    if (t == _i35.PeriodReturn) {
      return _i35.PeriodReturn.fromJson(data) as T;
    }
    if (t == _i36.Portfolio) {
      return _i36.Portfolio.fromJson(data) as T;
    }
    if (t == _i37.PortfolioAccount) {
      return _i37.PortfolioAccount.fromJson(data) as T;
    }
    if (t == _i38.PortfolioRule) {
      return _i38.PortfolioRule.fromJson(data) as T;
    }
    if (t == _i39.PortfolioValuation) {
      return _i39.PortfolioValuation.fromJson(data) as T;
    }
    if (t == _i40.PriceCache) {
      return _i40.PriceCache.fromJson(data) as T;
    }
    if (t == _i41.PriceUpdate) {
      return _i41.PriceUpdate.fromJson(data) as T;
    }
    if (t == _i42.RefreshPriceResult) {
      return _i42.RefreshPriceResult.fromJson(data) as T;
    }
    if (t == _i43.ReturnPeriod) {
      return _i43.ReturnPeriod.fromJson(data) as T;
    }
    if (t == _i44.Sleeve) {
      return _i44.Sleeve.fromJson(data) as T;
    }
    if (t == _i45.SleeveAllocation) {
      return _i45.SleeveAllocation.fromJson(data) as T;
    }
    if (t == _i46.SleeveAsset) {
      return _i46.SleeveAsset.fromJson(data) as T;
    }
    if (t == _i47.SleeveNode) {
      return _i47.SleeveNode.fromJson(data) as T;
    }
    if (t == _i48.SleeveOption) {
      return _i48.SleeveOption.fromJson(data) as T;
    }
    if (t == _i49.SleeveTreeResponse) {
      return _i49.SleeveTreeResponse.fromJson(data) as T;
    }
    if (t == _i50.StalePriceAsset) {
      return _i50.StalePriceAsset.fromJson(data) as T;
    }
    if (t == _i51.SyncStatus) {
      return _i51.SyncStatus.fromJson(data) as T;
    }
    if (t == _i52.TickerMetadata) {
      return _i52.TickerMetadata.fromJson(data) as T;
    }
    if (t == _i53.UpdateAssetTypeResult) {
      return _i53.UpdateAssetTypeResult.fromJson(data) as T;
    }
    if (t == _i54.UpdateYahooSymbolResult) {
      return _i54.UpdateYahooSymbolResult.fromJson(data) as T;
    }
    if (t == _i55.YahooSymbol) {
      return _i55.YahooSymbol.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Account?>()) {
      return (data != null ? _i2.Account.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AllocationStatus?>()) {
      return (data != null ? _i3.AllocationStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ArchivedAssetResponse?>()) {
      return (data != null ? _i4.ArchivedAssetResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.Asset?>()) {
      return (data != null ? _i5.Asset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AssetDetailResponse?>()) {
      return (data != null ? _i6.AssetDetailResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.AssetPeriodReturn?>()) {
      return (data != null ? _i7.AssetPeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AssetType?>()) {
      return (data != null ? _i8.AssetType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AssetValuation?>()) {
      return (data != null ? _i9.AssetValuation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.AssignSleeveResult?>()) {
      return (data != null ? _i10.AssignSleeveResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.Band?>()) {
      return (data != null ? _i11.Band.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.BandConfig?>()) {
      return (data != null ? _i12.BandConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ChartDataPoint?>()) {
      return (data != null ? _i13.ChartDataPoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.ChartDataResult?>()) {
      return (data != null ? _i14.ChartDataResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ChartRange?>()) {
      return (data != null ? _i15.ChartRange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.ClearPriceHistoryResult?>()) {
      return (data != null ? _i16.ClearPriceHistoryResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.ConcentrationViolation?>()) {
      return (data != null ? _i17.ConcentrationViolation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.DailyPrice?>()) {
      return (data != null ? _i18.DailyPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.DividendEvent?>()) {
      return (data != null ? _i19.DividendEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.FxCache?>()) {
      return (data != null ? _i20.FxCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.GlobalCash?>()) {
      return (data != null ? _i21.GlobalCash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.HistoricalReturnsResult?>()) {
      return (data != null ? _i22.HistoricalReturnsResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.Holding?>()) {
      return (data != null ? _i23.Holding.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.HoldingResponse?>()) {
      return (data != null ? _i24.HoldingResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.HoldingsListResponse?>()) {
      return (data != null ? _i25.HoldingsListResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.ImportResult?>()) {
      return (data != null ? _i26.ImportResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.IntradayPrice?>()) {
      return (data != null ? _i27.IntradayPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.Issue?>()) {
      return (data != null ? _i28.Issue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.IssueSeverity?>()) {
      return (data != null ? _i29.IssueSeverity.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.IssueType?>()) {
      return (data != null ? _i30.IssueType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.IssuesResponse?>()) {
      return (data != null ? _i31.IssuesResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.MissingSymbolAsset?>()) {
      return (data != null ? _i32.MissingSymbolAsset.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.Order?>()) {
      return (data != null ? _i33.Order.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.OrderSummary?>()) {
      return (data != null ? _i34.OrderSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.PeriodReturn?>()) {
      return (data != null ? _i35.PeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.Portfolio?>()) {
      return (data != null ? _i36.Portfolio.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.PortfolioAccount?>()) {
      return (data != null ? _i37.PortfolioAccount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.PortfolioRule?>()) {
      return (data != null ? _i38.PortfolioRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.PortfolioValuation?>()) {
      return (data != null ? _i39.PortfolioValuation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.PriceCache?>()) {
      return (data != null ? _i40.PriceCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.PriceUpdate?>()) {
      return (data != null ? _i41.PriceUpdate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.RefreshPriceResult?>()) {
      return (data != null ? _i42.RefreshPriceResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i43.ReturnPeriod?>()) {
      return (data != null ? _i43.ReturnPeriod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.Sleeve?>()) {
      return (data != null ? _i44.Sleeve.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.SleeveAllocation?>()) {
      return (data != null ? _i45.SleeveAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.SleeveAsset?>()) {
      return (data != null ? _i46.SleeveAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.SleeveNode?>()) {
      return (data != null ? _i47.SleeveNode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.SleeveOption?>()) {
      return (data != null ? _i48.SleeveOption.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.SleeveTreeResponse?>()) {
      return (data != null ? _i49.SleeveTreeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i50.StalePriceAsset?>()) {
      return (data != null ? _i50.StalePriceAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i51.SyncStatus?>()) {
      return (data != null ? _i51.SyncStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i52.TickerMetadata?>()) {
      return (data != null ? _i52.TickerMetadata.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i53.UpdateAssetTypeResult?>()) {
      return (data != null ? _i53.UpdateAssetTypeResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i54.UpdateYahooSymbolResult?>()) {
      return (data != null ? _i54.UpdateYahooSymbolResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i55.YahooSymbol?>()) {
      return (data != null ? _i55.YahooSymbol.fromJson(data) : null) as T;
    }
    if (t == List<_i34.OrderSummary>) {
      return (data as List)
              .map((e) => deserialize<_i34.OrderSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.ChartDataPoint>) {
      return (data as List)
              .map((e) => deserialize<_i13.ChartDataPoint>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i35.PeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i35.PeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, Map<String, _i7.AssetPeriodReturn>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<Map<String, _i7.AssetPeriodReturn>>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, _i7.AssetPeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i7.AssetPeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == List<_i24.HoldingResponse>) {
      return (data as List)
              .map((e) => deserialize<_i24.HoldingResponse>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i28.Issue>) {
      return (data as List).map((e) => deserialize<_i28.Issue>(e)).toList()
          as T;
    }
    if (t == List<_i45.SleeveAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i45.SleeveAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i9.AssetValuation>) {
      return (data as List)
              .map((e) => deserialize<_i9.AssetValuation>(e))
              .toList()
          as T;
    }
    if (t == List<_i32.MissingSymbolAsset>) {
      return (data as List)
              .map((e) => deserialize<_i32.MissingSymbolAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i50.StalePriceAsset>) {
      return (data as List)
              .map((e) => deserialize<_i50.StalePriceAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i17.ConcentrationViolation>) {
      return (data as List)
              .map((e) => deserialize<_i17.ConcentrationViolation>(e))
              .toList()
          as T;
    }
    if (t == List<_i47.SleeveNode>) {
      return (data as List).map((e) => deserialize<_i47.SleeveNode>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i47.SleeveNode>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i47.SleeveNode>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i56.Account>) {
      return (data as List).map((e) => deserialize<_i56.Account>(e)).toList()
          as T;
    }
    if (t == List<_i57.SleeveOption>) {
      return (data as List)
              .map((e) => deserialize<_i57.SleeveOption>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.ArchivedAssetResponse>) {
      return (data as List)
              .map((e) => deserialize<_i58.ArchivedAssetResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i59.Portfolio>) {
      return (data as List).map((e) => deserialize<_i59.Portfolio>(e)).toList()
          as T;
    }
    try {
      return _i60.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i61.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Account => 'Account',
      _i3.AllocationStatus => 'AllocationStatus',
      _i4.ArchivedAssetResponse => 'ArchivedAssetResponse',
      _i5.Asset => 'Asset',
      _i6.AssetDetailResponse => 'AssetDetailResponse',
      _i7.AssetPeriodReturn => 'AssetPeriodReturn',
      _i8.AssetType => 'AssetType',
      _i9.AssetValuation => 'AssetValuation',
      _i10.AssignSleeveResult => 'AssignSleeveResult',
      _i11.Band => 'Band',
      _i12.BandConfig => 'BandConfig',
      _i13.ChartDataPoint => 'ChartDataPoint',
      _i14.ChartDataResult => 'ChartDataResult',
      _i15.ChartRange => 'ChartRange',
      _i16.ClearPriceHistoryResult => 'ClearPriceHistoryResult',
      _i17.ConcentrationViolation => 'ConcentrationViolation',
      _i18.DailyPrice => 'DailyPrice',
      _i19.DividendEvent => 'DividendEvent',
      _i20.FxCache => 'FxCache',
      _i21.GlobalCash => 'GlobalCash',
      _i22.HistoricalReturnsResult => 'HistoricalReturnsResult',
      _i23.Holding => 'Holding',
      _i24.HoldingResponse => 'HoldingResponse',
      _i25.HoldingsListResponse => 'HoldingsListResponse',
      _i26.ImportResult => 'ImportResult',
      _i27.IntradayPrice => 'IntradayPrice',
      _i28.Issue => 'Issue',
      _i29.IssueSeverity => 'IssueSeverity',
      _i30.IssueType => 'IssueType',
      _i31.IssuesResponse => 'IssuesResponse',
      _i32.MissingSymbolAsset => 'MissingSymbolAsset',
      _i33.Order => 'Order',
      _i34.OrderSummary => 'OrderSummary',
      _i35.PeriodReturn => 'PeriodReturn',
      _i36.Portfolio => 'Portfolio',
      _i37.PortfolioAccount => 'PortfolioAccount',
      _i38.PortfolioRule => 'PortfolioRule',
      _i39.PortfolioValuation => 'PortfolioValuation',
      _i40.PriceCache => 'PriceCache',
      _i41.PriceUpdate => 'PriceUpdate',
      _i42.RefreshPriceResult => 'RefreshPriceResult',
      _i43.ReturnPeriod => 'ReturnPeriod',
      _i44.Sleeve => 'Sleeve',
      _i45.SleeveAllocation => 'SleeveAllocation',
      _i46.SleeveAsset => 'SleeveAsset',
      _i47.SleeveNode => 'SleeveNode',
      _i48.SleeveOption => 'SleeveOption',
      _i49.SleeveTreeResponse => 'SleeveTreeResponse',
      _i50.StalePriceAsset => 'StalePriceAsset',
      _i51.SyncStatus => 'SyncStatus',
      _i52.TickerMetadata => 'TickerMetadata',
      _i53.UpdateAssetTypeResult => 'UpdateAssetTypeResult',
      _i54.UpdateYahooSymbolResult => 'UpdateYahooSymbolResult',
      _i55.YahooSymbol => 'YahooSymbol',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('bagholdr.', '');
    }

    switch (data) {
      case _i2.Account():
        return 'Account';
      case _i3.AllocationStatus():
        return 'AllocationStatus';
      case _i4.ArchivedAssetResponse():
        return 'ArchivedAssetResponse';
      case _i5.Asset():
        return 'Asset';
      case _i6.AssetDetailResponse():
        return 'AssetDetailResponse';
      case _i7.AssetPeriodReturn():
        return 'AssetPeriodReturn';
      case _i8.AssetType():
        return 'AssetType';
      case _i9.AssetValuation():
        return 'AssetValuation';
      case _i10.AssignSleeveResult():
        return 'AssignSleeveResult';
      case _i11.Band():
        return 'Band';
      case _i12.BandConfig():
        return 'BandConfig';
      case _i13.ChartDataPoint():
        return 'ChartDataPoint';
      case _i14.ChartDataResult():
        return 'ChartDataResult';
      case _i15.ChartRange():
        return 'ChartRange';
      case _i16.ClearPriceHistoryResult():
        return 'ClearPriceHistoryResult';
      case _i17.ConcentrationViolation():
        return 'ConcentrationViolation';
      case _i18.DailyPrice():
        return 'DailyPrice';
      case _i19.DividendEvent():
        return 'DividendEvent';
      case _i20.FxCache():
        return 'FxCache';
      case _i21.GlobalCash():
        return 'GlobalCash';
      case _i22.HistoricalReturnsResult():
        return 'HistoricalReturnsResult';
      case _i23.Holding():
        return 'Holding';
      case _i24.HoldingResponse():
        return 'HoldingResponse';
      case _i25.HoldingsListResponse():
        return 'HoldingsListResponse';
      case _i26.ImportResult():
        return 'ImportResult';
      case _i27.IntradayPrice():
        return 'IntradayPrice';
      case _i28.Issue():
        return 'Issue';
      case _i29.IssueSeverity():
        return 'IssueSeverity';
      case _i30.IssueType():
        return 'IssueType';
      case _i31.IssuesResponse():
        return 'IssuesResponse';
      case _i32.MissingSymbolAsset():
        return 'MissingSymbolAsset';
      case _i33.Order():
        return 'Order';
      case _i34.OrderSummary():
        return 'OrderSummary';
      case _i35.PeriodReturn():
        return 'PeriodReturn';
      case _i36.Portfolio():
        return 'Portfolio';
      case _i37.PortfolioAccount():
        return 'PortfolioAccount';
      case _i38.PortfolioRule():
        return 'PortfolioRule';
      case _i39.PortfolioValuation():
        return 'PortfolioValuation';
      case _i40.PriceCache():
        return 'PriceCache';
      case _i41.PriceUpdate():
        return 'PriceUpdate';
      case _i42.RefreshPriceResult():
        return 'RefreshPriceResult';
      case _i43.ReturnPeriod():
        return 'ReturnPeriod';
      case _i44.Sleeve():
        return 'Sleeve';
      case _i45.SleeveAllocation():
        return 'SleeveAllocation';
      case _i46.SleeveAsset():
        return 'SleeveAsset';
      case _i47.SleeveNode():
        return 'SleeveNode';
      case _i48.SleeveOption():
        return 'SleeveOption';
      case _i49.SleeveTreeResponse():
        return 'SleeveTreeResponse';
      case _i50.StalePriceAsset():
        return 'StalePriceAsset';
      case _i51.SyncStatus():
        return 'SyncStatus';
      case _i52.TickerMetadata():
        return 'TickerMetadata';
      case _i53.UpdateAssetTypeResult():
        return 'UpdateAssetTypeResult';
      case _i54.UpdateYahooSymbolResult():
        return 'UpdateYahooSymbolResult';
      case _i55.YahooSymbol():
        return 'YahooSymbol';
    }
    className = _i60.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i61.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Account') {
      return deserialize<_i2.Account>(data['data']);
    }
    if (dataClassName == 'AllocationStatus') {
      return deserialize<_i3.AllocationStatus>(data['data']);
    }
    if (dataClassName == 'ArchivedAssetResponse') {
      return deserialize<_i4.ArchivedAssetResponse>(data['data']);
    }
    if (dataClassName == 'Asset') {
      return deserialize<_i5.Asset>(data['data']);
    }
    if (dataClassName == 'AssetDetailResponse') {
      return deserialize<_i6.AssetDetailResponse>(data['data']);
    }
    if (dataClassName == 'AssetPeriodReturn') {
      return deserialize<_i7.AssetPeriodReturn>(data['data']);
    }
    if (dataClassName == 'AssetType') {
      return deserialize<_i8.AssetType>(data['data']);
    }
    if (dataClassName == 'AssetValuation') {
      return deserialize<_i9.AssetValuation>(data['data']);
    }
    if (dataClassName == 'AssignSleeveResult') {
      return deserialize<_i10.AssignSleeveResult>(data['data']);
    }
    if (dataClassName == 'Band') {
      return deserialize<_i11.Band>(data['data']);
    }
    if (dataClassName == 'BandConfig') {
      return deserialize<_i12.BandConfig>(data['data']);
    }
    if (dataClassName == 'ChartDataPoint') {
      return deserialize<_i13.ChartDataPoint>(data['data']);
    }
    if (dataClassName == 'ChartDataResult') {
      return deserialize<_i14.ChartDataResult>(data['data']);
    }
    if (dataClassName == 'ChartRange') {
      return deserialize<_i15.ChartRange>(data['data']);
    }
    if (dataClassName == 'ClearPriceHistoryResult') {
      return deserialize<_i16.ClearPriceHistoryResult>(data['data']);
    }
    if (dataClassName == 'ConcentrationViolation') {
      return deserialize<_i17.ConcentrationViolation>(data['data']);
    }
    if (dataClassName == 'DailyPrice') {
      return deserialize<_i18.DailyPrice>(data['data']);
    }
    if (dataClassName == 'DividendEvent') {
      return deserialize<_i19.DividendEvent>(data['data']);
    }
    if (dataClassName == 'FxCache') {
      return deserialize<_i20.FxCache>(data['data']);
    }
    if (dataClassName == 'GlobalCash') {
      return deserialize<_i21.GlobalCash>(data['data']);
    }
    if (dataClassName == 'HistoricalReturnsResult') {
      return deserialize<_i22.HistoricalReturnsResult>(data['data']);
    }
    if (dataClassName == 'Holding') {
      return deserialize<_i23.Holding>(data['data']);
    }
    if (dataClassName == 'HoldingResponse') {
      return deserialize<_i24.HoldingResponse>(data['data']);
    }
    if (dataClassName == 'HoldingsListResponse') {
      return deserialize<_i25.HoldingsListResponse>(data['data']);
    }
    if (dataClassName == 'ImportResult') {
      return deserialize<_i26.ImportResult>(data['data']);
    }
    if (dataClassName == 'IntradayPrice') {
      return deserialize<_i27.IntradayPrice>(data['data']);
    }
    if (dataClassName == 'Issue') {
      return deserialize<_i28.Issue>(data['data']);
    }
    if (dataClassName == 'IssueSeverity') {
      return deserialize<_i29.IssueSeverity>(data['data']);
    }
    if (dataClassName == 'IssueType') {
      return deserialize<_i30.IssueType>(data['data']);
    }
    if (dataClassName == 'IssuesResponse') {
      return deserialize<_i31.IssuesResponse>(data['data']);
    }
    if (dataClassName == 'MissingSymbolAsset') {
      return deserialize<_i32.MissingSymbolAsset>(data['data']);
    }
    if (dataClassName == 'Order') {
      return deserialize<_i33.Order>(data['data']);
    }
    if (dataClassName == 'OrderSummary') {
      return deserialize<_i34.OrderSummary>(data['data']);
    }
    if (dataClassName == 'PeriodReturn') {
      return deserialize<_i35.PeriodReturn>(data['data']);
    }
    if (dataClassName == 'Portfolio') {
      return deserialize<_i36.Portfolio>(data['data']);
    }
    if (dataClassName == 'PortfolioAccount') {
      return deserialize<_i37.PortfolioAccount>(data['data']);
    }
    if (dataClassName == 'PortfolioRule') {
      return deserialize<_i38.PortfolioRule>(data['data']);
    }
    if (dataClassName == 'PortfolioValuation') {
      return deserialize<_i39.PortfolioValuation>(data['data']);
    }
    if (dataClassName == 'PriceCache') {
      return deserialize<_i40.PriceCache>(data['data']);
    }
    if (dataClassName == 'PriceUpdate') {
      return deserialize<_i41.PriceUpdate>(data['data']);
    }
    if (dataClassName == 'RefreshPriceResult') {
      return deserialize<_i42.RefreshPriceResult>(data['data']);
    }
    if (dataClassName == 'ReturnPeriod') {
      return deserialize<_i43.ReturnPeriod>(data['data']);
    }
    if (dataClassName == 'Sleeve') {
      return deserialize<_i44.Sleeve>(data['data']);
    }
    if (dataClassName == 'SleeveAllocation') {
      return deserialize<_i45.SleeveAllocation>(data['data']);
    }
    if (dataClassName == 'SleeveAsset') {
      return deserialize<_i46.SleeveAsset>(data['data']);
    }
    if (dataClassName == 'SleeveNode') {
      return deserialize<_i47.SleeveNode>(data['data']);
    }
    if (dataClassName == 'SleeveOption') {
      return deserialize<_i48.SleeveOption>(data['data']);
    }
    if (dataClassName == 'SleeveTreeResponse') {
      return deserialize<_i49.SleeveTreeResponse>(data['data']);
    }
    if (dataClassName == 'StalePriceAsset') {
      return deserialize<_i50.StalePriceAsset>(data['data']);
    }
    if (dataClassName == 'SyncStatus') {
      return deserialize<_i51.SyncStatus>(data['data']);
    }
    if (dataClassName == 'TickerMetadata') {
      return deserialize<_i52.TickerMetadata>(data['data']);
    }
    if (dataClassName == 'UpdateAssetTypeResult') {
      return deserialize<_i53.UpdateAssetTypeResult>(data['data']);
    }
    if (dataClassName == 'UpdateYahooSymbolResult') {
      return deserialize<_i54.UpdateYahooSymbolResult>(data['data']);
    }
    if (dataClassName == 'YahooSymbol') {
      return deserialize<_i55.YahooSymbol>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i60.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i61.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i60.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i61.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
