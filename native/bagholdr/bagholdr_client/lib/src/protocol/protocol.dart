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
import 'allocation_status.dart' as _i2;
import 'archived_asset_response.dart' as _i3;
import 'asset.dart' as _i4;
import 'asset_detail_response.dart' as _i5;
import 'asset_period_return.dart' as _i6;
import 'asset_type.dart' as _i7;
import 'asset_valuation.dart' as _i8;
import 'assign_sleeve_result.dart' as _i9;
import 'band.dart' as _i10;
import 'band_config.dart' as _i11;
import 'chart_data_point.dart' as _i12;
import 'chart_data_result.dart' as _i13;
import 'chart_range.dart' as _i14;
import 'clear_price_history_result.dart' as _i15;
import 'concentration_violation.dart' as _i16;
import 'daily_price.dart' as _i17;
import 'dividend_event.dart' as _i18;
import 'fx_cache.dart' as _i19;
import 'global_cash.dart' as _i20;
import 'historical_returns_result.dart' as _i21;
import 'holding.dart' as _i22;
import 'holding_response.dart' as _i23;
import 'holdings_list_response.dart' as _i24;
import 'import_result.dart' as _i25;
import 'intraday_price.dart' as _i26;
import 'issue.dart' as _i27;
import 'issue_severity.dart' as _i28;
import 'issue_type.dart' as _i29;
import 'issues_response.dart' as _i30;
import 'missing_symbol_asset.dart' as _i31;
import 'order.dart' as _i32;
import 'order_summary.dart' as _i33;
import 'period_return.dart' as _i34;
import 'portfolio.dart' as _i35;
import 'portfolio_rule.dart' as _i36;
import 'portfolio_valuation.dart' as _i37;
import 'price_cache.dart' as _i38;
import 'price_update.dart' as _i39;
import 'refresh_price_result.dart' as _i40;
import 'return_period.dart' as _i41;
import 'sleeve.dart' as _i42;
import 'sleeve_allocation.dart' as _i43;
import 'sleeve_asset.dart' as _i44;
import 'sleeve_node.dart' as _i45;
import 'sleeve_option.dart' as _i46;
import 'sleeve_tree_response.dart' as _i47;
import 'stale_price_asset.dart' as _i48;
import 'sync_status.dart' as _i49;
import 'ticker_metadata.dart' as _i50;
import 'update_asset_type_result.dart' as _i51;
import 'update_yahoo_symbol_result.dart' as _i52;
import 'yahoo_symbol.dart' as _i53;
import 'package:bagholdr_client/src/protocol/sleeve_option.dart' as _i54;
import 'package:bagholdr_client/src/protocol/archived_asset_response.dart'
    as _i55;
import 'package:bagholdr_client/src/protocol/portfolio.dart' as _i56;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i57;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i58;
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

    if (t == _i2.AllocationStatus) {
      return _i2.AllocationStatus.fromJson(data) as T;
    }
    if (t == _i3.ArchivedAssetResponse) {
      return _i3.ArchivedAssetResponse.fromJson(data) as T;
    }
    if (t == _i4.Asset) {
      return _i4.Asset.fromJson(data) as T;
    }
    if (t == _i5.AssetDetailResponse) {
      return _i5.AssetDetailResponse.fromJson(data) as T;
    }
    if (t == _i6.AssetPeriodReturn) {
      return _i6.AssetPeriodReturn.fromJson(data) as T;
    }
    if (t == _i7.AssetType) {
      return _i7.AssetType.fromJson(data) as T;
    }
    if (t == _i8.AssetValuation) {
      return _i8.AssetValuation.fromJson(data) as T;
    }
    if (t == _i9.AssignSleeveResult) {
      return _i9.AssignSleeveResult.fromJson(data) as T;
    }
    if (t == _i10.Band) {
      return _i10.Band.fromJson(data) as T;
    }
    if (t == _i11.BandConfig) {
      return _i11.BandConfig.fromJson(data) as T;
    }
    if (t == _i12.ChartDataPoint) {
      return _i12.ChartDataPoint.fromJson(data) as T;
    }
    if (t == _i13.ChartDataResult) {
      return _i13.ChartDataResult.fromJson(data) as T;
    }
    if (t == _i14.ChartRange) {
      return _i14.ChartRange.fromJson(data) as T;
    }
    if (t == _i15.ClearPriceHistoryResult) {
      return _i15.ClearPriceHistoryResult.fromJson(data) as T;
    }
    if (t == _i16.ConcentrationViolation) {
      return _i16.ConcentrationViolation.fromJson(data) as T;
    }
    if (t == _i17.DailyPrice) {
      return _i17.DailyPrice.fromJson(data) as T;
    }
    if (t == _i18.DividendEvent) {
      return _i18.DividendEvent.fromJson(data) as T;
    }
    if (t == _i19.FxCache) {
      return _i19.FxCache.fromJson(data) as T;
    }
    if (t == _i20.GlobalCash) {
      return _i20.GlobalCash.fromJson(data) as T;
    }
    if (t == _i21.HistoricalReturnsResult) {
      return _i21.HistoricalReturnsResult.fromJson(data) as T;
    }
    if (t == _i22.Holding) {
      return _i22.Holding.fromJson(data) as T;
    }
    if (t == _i23.HoldingResponse) {
      return _i23.HoldingResponse.fromJson(data) as T;
    }
    if (t == _i24.HoldingsListResponse) {
      return _i24.HoldingsListResponse.fromJson(data) as T;
    }
    if (t == _i25.ImportResult) {
      return _i25.ImportResult.fromJson(data) as T;
    }
    if (t == _i26.IntradayPrice) {
      return _i26.IntradayPrice.fromJson(data) as T;
    }
    if (t == _i27.Issue) {
      return _i27.Issue.fromJson(data) as T;
    }
    if (t == _i28.IssueSeverity) {
      return _i28.IssueSeverity.fromJson(data) as T;
    }
    if (t == _i29.IssueType) {
      return _i29.IssueType.fromJson(data) as T;
    }
    if (t == _i30.IssuesResponse) {
      return _i30.IssuesResponse.fromJson(data) as T;
    }
    if (t == _i31.MissingSymbolAsset) {
      return _i31.MissingSymbolAsset.fromJson(data) as T;
    }
    if (t == _i32.Order) {
      return _i32.Order.fromJson(data) as T;
    }
    if (t == _i33.OrderSummary) {
      return _i33.OrderSummary.fromJson(data) as T;
    }
    if (t == _i34.PeriodReturn) {
      return _i34.PeriodReturn.fromJson(data) as T;
    }
    if (t == _i35.Portfolio) {
      return _i35.Portfolio.fromJson(data) as T;
    }
    if (t == _i36.PortfolioRule) {
      return _i36.PortfolioRule.fromJson(data) as T;
    }
    if (t == _i37.PortfolioValuation) {
      return _i37.PortfolioValuation.fromJson(data) as T;
    }
    if (t == _i38.PriceCache) {
      return _i38.PriceCache.fromJson(data) as T;
    }
    if (t == _i39.PriceUpdate) {
      return _i39.PriceUpdate.fromJson(data) as T;
    }
    if (t == _i40.RefreshPriceResult) {
      return _i40.RefreshPriceResult.fromJson(data) as T;
    }
    if (t == _i41.ReturnPeriod) {
      return _i41.ReturnPeriod.fromJson(data) as T;
    }
    if (t == _i42.Sleeve) {
      return _i42.Sleeve.fromJson(data) as T;
    }
    if (t == _i43.SleeveAllocation) {
      return _i43.SleeveAllocation.fromJson(data) as T;
    }
    if (t == _i44.SleeveAsset) {
      return _i44.SleeveAsset.fromJson(data) as T;
    }
    if (t == _i45.SleeveNode) {
      return _i45.SleeveNode.fromJson(data) as T;
    }
    if (t == _i46.SleeveOption) {
      return _i46.SleeveOption.fromJson(data) as T;
    }
    if (t == _i47.SleeveTreeResponse) {
      return _i47.SleeveTreeResponse.fromJson(data) as T;
    }
    if (t == _i48.StalePriceAsset) {
      return _i48.StalePriceAsset.fromJson(data) as T;
    }
    if (t == _i49.SyncStatus) {
      return _i49.SyncStatus.fromJson(data) as T;
    }
    if (t == _i50.TickerMetadata) {
      return _i50.TickerMetadata.fromJson(data) as T;
    }
    if (t == _i51.UpdateAssetTypeResult) {
      return _i51.UpdateAssetTypeResult.fromJson(data) as T;
    }
    if (t == _i52.UpdateYahooSymbolResult) {
      return _i52.UpdateYahooSymbolResult.fromJson(data) as T;
    }
    if (t == _i53.YahooSymbol) {
      return _i53.YahooSymbol.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AllocationStatus?>()) {
      return (data != null ? _i2.AllocationStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ArchivedAssetResponse?>()) {
      return (data != null ? _i3.ArchivedAssetResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.Asset?>()) {
      return (data != null ? _i4.Asset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AssetDetailResponse?>()) {
      return (data != null ? _i5.AssetDetailResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.AssetPeriodReturn?>()) {
      return (data != null ? _i6.AssetPeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AssetType?>()) {
      return (data != null ? _i7.AssetType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AssetValuation?>()) {
      return (data != null ? _i8.AssetValuation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AssignSleeveResult?>()) {
      return (data != null ? _i9.AssignSleeveResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Band?>()) {
      return (data != null ? _i10.Band.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.BandConfig?>()) {
      return (data != null ? _i11.BandConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.ChartDataPoint?>()) {
      return (data != null ? _i12.ChartDataPoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ChartDataResult?>()) {
      return (data != null ? _i13.ChartDataResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.ChartRange?>()) {
      return (data != null ? _i14.ChartRange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ClearPriceHistoryResult?>()) {
      return (data != null ? _i15.ClearPriceHistoryResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.ConcentrationViolation?>()) {
      return (data != null ? _i16.ConcentrationViolation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.DailyPrice?>()) {
      return (data != null ? _i17.DailyPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.DividendEvent?>()) {
      return (data != null ? _i18.DividendEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.FxCache?>()) {
      return (data != null ? _i19.FxCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.GlobalCash?>()) {
      return (data != null ? _i20.GlobalCash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.HistoricalReturnsResult?>()) {
      return (data != null ? _i21.HistoricalReturnsResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.Holding?>()) {
      return (data != null ? _i22.Holding.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.HoldingResponse?>()) {
      return (data != null ? _i23.HoldingResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.HoldingsListResponse?>()) {
      return (data != null ? _i24.HoldingsListResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.ImportResult?>()) {
      return (data != null ? _i25.ImportResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.IntradayPrice?>()) {
      return (data != null ? _i26.IntradayPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.Issue?>()) {
      return (data != null ? _i27.Issue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.IssueSeverity?>()) {
      return (data != null ? _i28.IssueSeverity.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.IssueType?>()) {
      return (data != null ? _i29.IssueType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.IssuesResponse?>()) {
      return (data != null ? _i30.IssuesResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.MissingSymbolAsset?>()) {
      return (data != null ? _i31.MissingSymbolAsset.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i32.Order?>()) {
      return (data != null ? _i32.Order.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.OrderSummary?>()) {
      return (data != null ? _i33.OrderSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.PeriodReturn?>()) {
      return (data != null ? _i34.PeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.Portfolio?>()) {
      return (data != null ? _i35.Portfolio.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.PortfolioRule?>()) {
      return (data != null ? _i36.PortfolioRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.PortfolioValuation?>()) {
      return (data != null ? _i37.PortfolioValuation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i38.PriceCache?>()) {
      return (data != null ? _i38.PriceCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.PriceUpdate?>()) {
      return (data != null ? _i39.PriceUpdate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.RefreshPriceResult?>()) {
      return (data != null ? _i40.RefreshPriceResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i41.ReturnPeriod?>()) {
      return (data != null ? _i41.ReturnPeriod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.Sleeve?>()) {
      return (data != null ? _i42.Sleeve.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.SleeveAllocation?>()) {
      return (data != null ? _i43.SleeveAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.SleeveAsset?>()) {
      return (data != null ? _i44.SleeveAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.SleeveNode?>()) {
      return (data != null ? _i45.SleeveNode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.SleeveOption?>()) {
      return (data != null ? _i46.SleeveOption.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.SleeveTreeResponse?>()) {
      return (data != null ? _i47.SleeveTreeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i48.StalePriceAsset?>()) {
      return (data != null ? _i48.StalePriceAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.SyncStatus?>()) {
      return (data != null ? _i49.SyncStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i50.TickerMetadata?>()) {
      return (data != null ? _i50.TickerMetadata.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i51.UpdateAssetTypeResult?>()) {
      return (data != null ? _i51.UpdateAssetTypeResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i52.UpdateYahooSymbolResult?>()) {
      return (data != null ? _i52.UpdateYahooSymbolResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i53.YahooSymbol?>()) {
      return (data != null ? _i53.YahooSymbol.fromJson(data) : null) as T;
    }
    if (t == List<_i33.OrderSummary>) {
      return (data as List)
              .map((e) => deserialize<_i33.OrderSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i12.ChartDataPoint>) {
      return (data as List)
              .map((e) => deserialize<_i12.ChartDataPoint>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i34.PeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i34.PeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, Map<String, _i6.AssetPeriodReturn>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<Map<String, _i6.AssetPeriodReturn>>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, _i6.AssetPeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i6.AssetPeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == List<_i23.HoldingResponse>) {
      return (data as List)
              .map((e) => deserialize<_i23.HoldingResponse>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i27.Issue>) {
      return (data as List).map((e) => deserialize<_i27.Issue>(e)).toList()
          as T;
    }
    if (t == List<_i43.SleeveAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i43.SleeveAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i8.AssetValuation>) {
      return (data as List)
              .map((e) => deserialize<_i8.AssetValuation>(e))
              .toList()
          as T;
    }
    if (t == List<_i31.MissingSymbolAsset>) {
      return (data as List)
              .map((e) => deserialize<_i31.MissingSymbolAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i48.StalePriceAsset>) {
      return (data as List)
              .map((e) => deserialize<_i48.StalePriceAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.ConcentrationViolation>) {
      return (data as List)
              .map((e) => deserialize<_i16.ConcentrationViolation>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.SleeveNode>) {
      return (data as List).map((e) => deserialize<_i45.SleeveNode>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i45.SleeveNode>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i45.SleeveNode>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i54.SleeveOption>) {
      return (data as List)
              .map((e) => deserialize<_i54.SleeveOption>(e))
              .toList()
          as T;
    }
    if (t == List<_i55.ArchivedAssetResponse>) {
      return (data as List)
              .map((e) => deserialize<_i55.ArchivedAssetResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i56.Portfolio>) {
      return (data as List).map((e) => deserialize<_i56.Portfolio>(e)).toList()
          as T;
    }
    try {
      return _i57.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i58.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AllocationStatus => 'AllocationStatus',
      _i3.ArchivedAssetResponse => 'ArchivedAssetResponse',
      _i4.Asset => 'Asset',
      _i5.AssetDetailResponse => 'AssetDetailResponse',
      _i6.AssetPeriodReturn => 'AssetPeriodReturn',
      _i7.AssetType => 'AssetType',
      _i8.AssetValuation => 'AssetValuation',
      _i9.AssignSleeveResult => 'AssignSleeveResult',
      _i10.Band => 'Band',
      _i11.BandConfig => 'BandConfig',
      _i12.ChartDataPoint => 'ChartDataPoint',
      _i13.ChartDataResult => 'ChartDataResult',
      _i14.ChartRange => 'ChartRange',
      _i15.ClearPriceHistoryResult => 'ClearPriceHistoryResult',
      _i16.ConcentrationViolation => 'ConcentrationViolation',
      _i17.DailyPrice => 'DailyPrice',
      _i18.DividendEvent => 'DividendEvent',
      _i19.FxCache => 'FxCache',
      _i20.GlobalCash => 'GlobalCash',
      _i21.HistoricalReturnsResult => 'HistoricalReturnsResult',
      _i22.Holding => 'Holding',
      _i23.HoldingResponse => 'HoldingResponse',
      _i24.HoldingsListResponse => 'HoldingsListResponse',
      _i25.ImportResult => 'ImportResult',
      _i26.IntradayPrice => 'IntradayPrice',
      _i27.Issue => 'Issue',
      _i28.IssueSeverity => 'IssueSeverity',
      _i29.IssueType => 'IssueType',
      _i30.IssuesResponse => 'IssuesResponse',
      _i31.MissingSymbolAsset => 'MissingSymbolAsset',
      _i32.Order => 'Order',
      _i33.OrderSummary => 'OrderSummary',
      _i34.PeriodReturn => 'PeriodReturn',
      _i35.Portfolio => 'Portfolio',
      _i36.PortfolioRule => 'PortfolioRule',
      _i37.PortfolioValuation => 'PortfolioValuation',
      _i38.PriceCache => 'PriceCache',
      _i39.PriceUpdate => 'PriceUpdate',
      _i40.RefreshPriceResult => 'RefreshPriceResult',
      _i41.ReturnPeriod => 'ReturnPeriod',
      _i42.Sleeve => 'Sleeve',
      _i43.SleeveAllocation => 'SleeveAllocation',
      _i44.SleeveAsset => 'SleeveAsset',
      _i45.SleeveNode => 'SleeveNode',
      _i46.SleeveOption => 'SleeveOption',
      _i47.SleeveTreeResponse => 'SleeveTreeResponse',
      _i48.StalePriceAsset => 'StalePriceAsset',
      _i49.SyncStatus => 'SyncStatus',
      _i50.TickerMetadata => 'TickerMetadata',
      _i51.UpdateAssetTypeResult => 'UpdateAssetTypeResult',
      _i52.UpdateYahooSymbolResult => 'UpdateYahooSymbolResult',
      _i53.YahooSymbol => 'YahooSymbol',
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
      case _i2.AllocationStatus():
        return 'AllocationStatus';
      case _i3.ArchivedAssetResponse():
        return 'ArchivedAssetResponse';
      case _i4.Asset():
        return 'Asset';
      case _i5.AssetDetailResponse():
        return 'AssetDetailResponse';
      case _i6.AssetPeriodReturn():
        return 'AssetPeriodReturn';
      case _i7.AssetType():
        return 'AssetType';
      case _i8.AssetValuation():
        return 'AssetValuation';
      case _i9.AssignSleeveResult():
        return 'AssignSleeveResult';
      case _i10.Band():
        return 'Band';
      case _i11.BandConfig():
        return 'BandConfig';
      case _i12.ChartDataPoint():
        return 'ChartDataPoint';
      case _i13.ChartDataResult():
        return 'ChartDataResult';
      case _i14.ChartRange():
        return 'ChartRange';
      case _i15.ClearPriceHistoryResult():
        return 'ClearPriceHistoryResult';
      case _i16.ConcentrationViolation():
        return 'ConcentrationViolation';
      case _i17.DailyPrice():
        return 'DailyPrice';
      case _i18.DividendEvent():
        return 'DividendEvent';
      case _i19.FxCache():
        return 'FxCache';
      case _i20.GlobalCash():
        return 'GlobalCash';
      case _i21.HistoricalReturnsResult():
        return 'HistoricalReturnsResult';
      case _i22.Holding():
        return 'Holding';
      case _i23.HoldingResponse():
        return 'HoldingResponse';
      case _i24.HoldingsListResponse():
        return 'HoldingsListResponse';
      case _i25.ImportResult():
        return 'ImportResult';
      case _i26.IntradayPrice():
        return 'IntradayPrice';
      case _i27.Issue():
        return 'Issue';
      case _i28.IssueSeverity():
        return 'IssueSeverity';
      case _i29.IssueType():
        return 'IssueType';
      case _i30.IssuesResponse():
        return 'IssuesResponse';
      case _i31.MissingSymbolAsset():
        return 'MissingSymbolAsset';
      case _i32.Order():
        return 'Order';
      case _i33.OrderSummary():
        return 'OrderSummary';
      case _i34.PeriodReturn():
        return 'PeriodReturn';
      case _i35.Portfolio():
        return 'Portfolio';
      case _i36.PortfolioRule():
        return 'PortfolioRule';
      case _i37.PortfolioValuation():
        return 'PortfolioValuation';
      case _i38.PriceCache():
        return 'PriceCache';
      case _i39.PriceUpdate():
        return 'PriceUpdate';
      case _i40.RefreshPriceResult():
        return 'RefreshPriceResult';
      case _i41.ReturnPeriod():
        return 'ReturnPeriod';
      case _i42.Sleeve():
        return 'Sleeve';
      case _i43.SleeveAllocation():
        return 'SleeveAllocation';
      case _i44.SleeveAsset():
        return 'SleeveAsset';
      case _i45.SleeveNode():
        return 'SleeveNode';
      case _i46.SleeveOption():
        return 'SleeveOption';
      case _i47.SleeveTreeResponse():
        return 'SleeveTreeResponse';
      case _i48.StalePriceAsset():
        return 'StalePriceAsset';
      case _i49.SyncStatus():
        return 'SyncStatus';
      case _i50.TickerMetadata():
        return 'TickerMetadata';
      case _i51.UpdateAssetTypeResult():
        return 'UpdateAssetTypeResult';
      case _i52.UpdateYahooSymbolResult():
        return 'UpdateYahooSymbolResult';
      case _i53.YahooSymbol():
        return 'YahooSymbol';
    }
    className = _i57.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i58.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'AllocationStatus') {
      return deserialize<_i2.AllocationStatus>(data['data']);
    }
    if (dataClassName == 'ArchivedAssetResponse') {
      return deserialize<_i3.ArchivedAssetResponse>(data['data']);
    }
    if (dataClassName == 'Asset') {
      return deserialize<_i4.Asset>(data['data']);
    }
    if (dataClassName == 'AssetDetailResponse') {
      return deserialize<_i5.AssetDetailResponse>(data['data']);
    }
    if (dataClassName == 'AssetPeriodReturn') {
      return deserialize<_i6.AssetPeriodReturn>(data['data']);
    }
    if (dataClassName == 'AssetType') {
      return deserialize<_i7.AssetType>(data['data']);
    }
    if (dataClassName == 'AssetValuation') {
      return deserialize<_i8.AssetValuation>(data['data']);
    }
    if (dataClassName == 'AssignSleeveResult') {
      return deserialize<_i9.AssignSleeveResult>(data['data']);
    }
    if (dataClassName == 'Band') {
      return deserialize<_i10.Band>(data['data']);
    }
    if (dataClassName == 'BandConfig') {
      return deserialize<_i11.BandConfig>(data['data']);
    }
    if (dataClassName == 'ChartDataPoint') {
      return deserialize<_i12.ChartDataPoint>(data['data']);
    }
    if (dataClassName == 'ChartDataResult') {
      return deserialize<_i13.ChartDataResult>(data['data']);
    }
    if (dataClassName == 'ChartRange') {
      return deserialize<_i14.ChartRange>(data['data']);
    }
    if (dataClassName == 'ClearPriceHistoryResult') {
      return deserialize<_i15.ClearPriceHistoryResult>(data['data']);
    }
    if (dataClassName == 'ConcentrationViolation') {
      return deserialize<_i16.ConcentrationViolation>(data['data']);
    }
    if (dataClassName == 'DailyPrice') {
      return deserialize<_i17.DailyPrice>(data['data']);
    }
    if (dataClassName == 'DividendEvent') {
      return deserialize<_i18.DividendEvent>(data['data']);
    }
    if (dataClassName == 'FxCache') {
      return deserialize<_i19.FxCache>(data['data']);
    }
    if (dataClassName == 'GlobalCash') {
      return deserialize<_i20.GlobalCash>(data['data']);
    }
    if (dataClassName == 'HistoricalReturnsResult') {
      return deserialize<_i21.HistoricalReturnsResult>(data['data']);
    }
    if (dataClassName == 'Holding') {
      return deserialize<_i22.Holding>(data['data']);
    }
    if (dataClassName == 'HoldingResponse') {
      return deserialize<_i23.HoldingResponse>(data['data']);
    }
    if (dataClassName == 'HoldingsListResponse') {
      return deserialize<_i24.HoldingsListResponse>(data['data']);
    }
    if (dataClassName == 'ImportResult') {
      return deserialize<_i25.ImportResult>(data['data']);
    }
    if (dataClassName == 'IntradayPrice') {
      return deserialize<_i26.IntradayPrice>(data['data']);
    }
    if (dataClassName == 'Issue') {
      return deserialize<_i27.Issue>(data['data']);
    }
    if (dataClassName == 'IssueSeverity') {
      return deserialize<_i28.IssueSeverity>(data['data']);
    }
    if (dataClassName == 'IssueType') {
      return deserialize<_i29.IssueType>(data['data']);
    }
    if (dataClassName == 'IssuesResponse') {
      return deserialize<_i30.IssuesResponse>(data['data']);
    }
    if (dataClassName == 'MissingSymbolAsset') {
      return deserialize<_i31.MissingSymbolAsset>(data['data']);
    }
    if (dataClassName == 'Order') {
      return deserialize<_i32.Order>(data['data']);
    }
    if (dataClassName == 'OrderSummary') {
      return deserialize<_i33.OrderSummary>(data['data']);
    }
    if (dataClassName == 'PeriodReturn') {
      return deserialize<_i34.PeriodReturn>(data['data']);
    }
    if (dataClassName == 'Portfolio') {
      return deserialize<_i35.Portfolio>(data['data']);
    }
    if (dataClassName == 'PortfolioRule') {
      return deserialize<_i36.PortfolioRule>(data['data']);
    }
    if (dataClassName == 'PortfolioValuation') {
      return deserialize<_i37.PortfolioValuation>(data['data']);
    }
    if (dataClassName == 'PriceCache') {
      return deserialize<_i38.PriceCache>(data['data']);
    }
    if (dataClassName == 'PriceUpdate') {
      return deserialize<_i39.PriceUpdate>(data['data']);
    }
    if (dataClassName == 'RefreshPriceResult') {
      return deserialize<_i40.RefreshPriceResult>(data['data']);
    }
    if (dataClassName == 'ReturnPeriod') {
      return deserialize<_i41.ReturnPeriod>(data['data']);
    }
    if (dataClassName == 'Sleeve') {
      return deserialize<_i42.Sleeve>(data['data']);
    }
    if (dataClassName == 'SleeveAllocation') {
      return deserialize<_i43.SleeveAllocation>(data['data']);
    }
    if (dataClassName == 'SleeveAsset') {
      return deserialize<_i44.SleeveAsset>(data['data']);
    }
    if (dataClassName == 'SleeveNode') {
      return deserialize<_i45.SleeveNode>(data['data']);
    }
    if (dataClassName == 'SleeveOption') {
      return deserialize<_i46.SleeveOption>(data['data']);
    }
    if (dataClassName == 'SleeveTreeResponse') {
      return deserialize<_i47.SleeveTreeResponse>(data['data']);
    }
    if (dataClassName == 'StalePriceAsset') {
      return deserialize<_i48.StalePriceAsset>(data['data']);
    }
    if (dataClassName == 'SyncStatus') {
      return deserialize<_i49.SyncStatus>(data['data']);
    }
    if (dataClassName == 'TickerMetadata') {
      return deserialize<_i50.TickerMetadata>(data['data']);
    }
    if (dataClassName == 'UpdateAssetTypeResult') {
      return deserialize<_i51.UpdateAssetTypeResult>(data['data']);
    }
    if (dataClassName == 'UpdateYahooSymbolResult') {
      return deserialize<_i52.UpdateYahooSymbolResult>(data['data']);
    }
    if (dataClassName == 'YahooSymbol') {
      return deserialize<_i53.YahooSymbol>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i57.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i58.Protocol().deserializeByClassName(data);
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
      return _i57.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i58.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
