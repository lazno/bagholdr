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
import 'asset.dart' as _i3;
import 'asset_detail_response.dart' as _i4;
import 'asset_period_return.dart' as _i5;
import 'asset_type.dart' as _i6;
import 'asset_valuation.dart' as _i7;
import 'band.dart' as _i8;
import 'band_config.dart' as _i9;
import 'chart_data_point.dart' as _i10;
import 'chart_data_result.dart' as _i11;
import 'chart_range.dart' as _i12;
import 'concentration_violation.dart' as _i13;
import 'daily_price.dart' as _i14;
import 'dividend_event.dart' as _i15;
import 'fx_cache.dart' as _i16;
import 'global_cash.dart' as _i17;
import 'historical_returns_result.dart' as _i18;
import 'holding.dart' as _i19;
import 'holding_response.dart' as _i20;
import 'holdings_list_response.dart' as _i21;
import 'import_result.dart' as _i22;
import 'intraday_price.dart' as _i23;
import 'issue.dart' as _i24;
import 'issue_severity.dart' as _i25;
import 'issue_type.dart' as _i26;
import 'issues_response.dart' as _i27;
import 'missing_symbol_asset.dart' as _i28;
import 'order.dart' as _i29;
import 'order_summary.dart' as _i30;
import 'period_return.dart' as _i31;
import 'portfolio.dart' as _i32;
import 'portfolio_rule.dart' as _i33;
import 'portfolio_valuation.dart' as _i34;
import 'price_cache.dart' as _i35;
import 'price_update.dart' as _i36;
import 'return_period.dart' as _i37;
import 'sleeve.dart' as _i38;
import 'sleeve_allocation.dart' as _i39;
import 'sleeve_asset.dart' as _i40;
import 'sleeve_node.dart' as _i41;
import 'sleeve_tree_response.dart' as _i42;
import 'stale_price_asset.dart' as _i43;
import 'sync_status.dart' as _i44;
import 'ticker_metadata.dart' as _i45;
import 'yahoo_symbol.dart' as _i46;
import 'package:bagholdr_client/src/protocol/portfolio.dart' as _i47;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i48;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i49;
export 'allocation_status.dart';
export 'asset.dart';
export 'asset_detail_response.dart';
export 'asset_period_return.dart';
export 'asset_type.dart';
export 'asset_valuation.dart';
export 'band.dart';
export 'band_config.dart';
export 'chart_data_point.dart';
export 'chart_data_result.dart';
export 'chart_range.dart';
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
export 'return_period.dart';
export 'sleeve.dart';
export 'sleeve_allocation.dart';
export 'sleeve_asset.dart';
export 'sleeve_node.dart';
export 'sleeve_tree_response.dart';
export 'stale_price_asset.dart';
export 'sync_status.dart';
export 'ticker_metadata.dart';
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
    if (t == _i3.Asset) {
      return _i3.Asset.fromJson(data) as T;
    }
    if (t == _i4.AssetDetailResponse) {
      return _i4.AssetDetailResponse.fromJson(data) as T;
    }
    if (t == _i5.AssetPeriodReturn) {
      return _i5.AssetPeriodReturn.fromJson(data) as T;
    }
    if (t == _i6.AssetType) {
      return _i6.AssetType.fromJson(data) as T;
    }
    if (t == _i7.AssetValuation) {
      return _i7.AssetValuation.fromJson(data) as T;
    }
    if (t == _i8.Band) {
      return _i8.Band.fromJson(data) as T;
    }
    if (t == _i9.BandConfig) {
      return _i9.BandConfig.fromJson(data) as T;
    }
    if (t == _i10.ChartDataPoint) {
      return _i10.ChartDataPoint.fromJson(data) as T;
    }
    if (t == _i11.ChartDataResult) {
      return _i11.ChartDataResult.fromJson(data) as T;
    }
    if (t == _i12.ChartRange) {
      return _i12.ChartRange.fromJson(data) as T;
    }
    if (t == _i13.ConcentrationViolation) {
      return _i13.ConcentrationViolation.fromJson(data) as T;
    }
    if (t == _i14.DailyPrice) {
      return _i14.DailyPrice.fromJson(data) as T;
    }
    if (t == _i15.DividendEvent) {
      return _i15.DividendEvent.fromJson(data) as T;
    }
    if (t == _i16.FxCache) {
      return _i16.FxCache.fromJson(data) as T;
    }
    if (t == _i17.GlobalCash) {
      return _i17.GlobalCash.fromJson(data) as T;
    }
    if (t == _i18.HistoricalReturnsResult) {
      return _i18.HistoricalReturnsResult.fromJson(data) as T;
    }
    if (t == _i19.Holding) {
      return _i19.Holding.fromJson(data) as T;
    }
    if (t == _i20.HoldingResponse) {
      return _i20.HoldingResponse.fromJson(data) as T;
    }
    if (t == _i21.HoldingsListResponse) {
      return _i21.HoldingsListResponse.fromJson(data) as T;
    }
    if (t == _i22.ImportResult) {
      return _i22.ImportResult.fromJson(data) as T;
    }
    if (t == _i23.IntradayPrice) {
      return _i23.IntradayPrice.fromJson(data) as T;
    }
    if (t == _i24.Issue) {
      return _i24.Issue.fromJson(data) as T;
    }
    if (t == _i25.IssueSeverity) {
      return _i25.IssueSeverity.fromJson(data) as T;
    }
    if (t == _i26.IssueType) {
      return _i26.IssueType.fromJson(data) as T;
    }
    if (t == _i27.IssuesResponse) {
      return _i27.IssuesResponse.fromJson(data) as T;
    }
    if (t == _i28.MissingSymbolAsset) {
      return _i28.MissingSymbolAsset.fromJson(data) as T;
    }
    if (t == _i29.Order) {
      return _i29.Order.fromJson(data) as T;
    }
    if (t == _i30.OrderSummary) {
      return _i30.OrderSummary.fromJson(data) as T;
    }
    if (t == _i31.PeriodReturn) {
      return _i31.PeriodReturn.fromJson(data) as T;
    }
    if (t == _i32.Portfolio) {
      return _i32.Portfolio.fromJson(data) as T;
    }
    if (t == _i33.PortfolioRule) {
      return _i33.PortfolioRule.fromJson(data) as T;
    }
    if (t == _i34.PortfolioValuation) {
      return _i34.PortfolioValuation.fromJson(data) as T;
    }
    if (t == _i35.PriceCache) {
      return _i35.PriceCache.fromJson(data) as T;
    }
    if (t == _i36.PriceUpdate) {
      return _i36.PriceUpdate.fromJson(data) as T;
    }
    if (t == _i37.ReturnPeriod) {
      return _i37.ReturnPeriod.fromJson(data) as T;
    }
    if (t == _i38.Sleeve) {
      return _i38.Sleeve.fromJson(data) as T;
    }
    if (t == _i39.SleeveAllocation) {
      return _i39.SleeveAllocation.fromJson(data) as T;
    }
    if (t == _i40.SleeveAsset) {
      return _i40.SleeveAsset.fromJson(data) as T;
    }
    if (t == _i41.SleeveNode) {
      return _i41.SleeveNode.fromJson(data) as T;
    }
    if (t == _i42.SleeveTreeResponse) {
      return _i42.SleeveTreeResponse.fromJson(data) as T;
    }
    if (t == _i43.StalePriceAsset) {
      return _i43.StalePriceAsset.fromJson(data) as T;
    }
    if (t == _i44.SyncStatus) {
      return _i44.SyncStatus.fromJson(data) as T;
    }
    if (t == _i45.TickerMetadata) {
      return _i45.TickerMetadata.fromJson(data) as T;
    }
    if (t == _i46.YahooSymbol) {
      return _i46.YahooSymbol.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AllocationStatus?>()) {
      return (data != null ? _i2.AllocationStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Asset?>()) {
      return (data != null ? _i3.Asset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AssetDetailResponse?>()) {
      return (data != null ? _i4.AssetDetailResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.AssetPeriodReturn?>()) {
      return (data != null ? _i5.AssetPeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AssetType?>()) {
      return (data != null ? _i6.AssetType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AssetValuation?>()) {
      return (data != null ? _i7.AssetValuation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Band?>()) {
      return (data != null ? _i8.Band.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.BandConfig?>()) {
      return (data != null ? _i9.BandConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ChartDataPoint?>()) {
      return (data != null ? _i10.ChartDataPoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ChartDataResult?>()) {
      return (data != null ? _i11.ChartDataResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.ChartRange?>()) {
      return (data != null ? _i12.ChartRange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ConcentrationViolation?>()) {
      return (data != null ? _i13.ConcentrationViolation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.DailyPrice?>()) {
      return (data != null ? _i14.DailyPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.DividendEvent?>()) {
      return (data != null ? _i15.DividendEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.FxCache?>()) {
      return (data != null ? _i16.FxCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.GlobalCash?>()) {
      return (data != null ? _i17.GlobalCash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.HistoricalReturnsResult?>()) {
      return (data != null ? _i18.HistoricalReturnsResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.Holding?>()) {
      return (data != null ? _i19.Holding.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.HoldingResponse?>()) {
      return (data != null ? _i20.HoldingResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.HoldingsListResponse?>()) {
      return (data != null ? _i21.HoldingsListResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.ImportResult?>()) {
      return (data != null ? _i22.ImportResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.IntradayPrice?>()) {
      return (data != null ? _i23.IntradayPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.Issue?>()) {
      return (data != null ? _i24.Issue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.IssueSeverity?>()) {
      return (data != null ? _i25.IssueSeverity.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.IssueType?>()) {
      return (data != null ? _i26.IssueType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.IssuesResponse?>()) {
      return (data != null ? _i27.IssuesResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.MissingSymbolAsset?>()) {
      return (data != null ? _i28.MissingSymbolAsset.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.Order?>()) {
      return (data != null ? _i29.Order.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.OrderSummary?>()) {
      return (data != null ? _i30.OrderSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.PeriodReturn?>()) {
      return (data != null ? _i31.PeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.Portfolio?>()) {
      return (data != null ? _i32.Portfolio.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.PortfolioRule?>()) {
      return (data != null ? _i33.PortfolioRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.PortfolioValuation?>()) {
      return (data != null ? _i34.PortfolioValuation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.PriceCache?>()) {
      return (data != null ? _i35.PriceCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.PriceUpdate?>()) {
      return (data != null ? _i36.PriceUpdate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.ReturnPeriod?>()) {
      return (data != null ? _i37.ReturnPeriod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.Sleeve?>()) {
      return (data != null ? _i38.Sleeve.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.SleeveAllocation?>()) {
      return (data != null ? _i39.SleeveAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.SleeveAsset?>()) {
      return (data != null ? _i40.SleeveAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.SleeveNode?>()) {
      return (data != null ? _i41.SleeveNode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.SleeveTreeResponse?>()) {
      return (data != null ? _i42.SleeveTreeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i43.StalePriceAsset?>()) {
      return (data != null ? _i43.StalePriceAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.SyncStatus?>()) {
      return (data != null ? _i44.SyncStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.TickerMetadata?>()) {
      return (data != null ? _i45.TickerMetadata.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.YahooSymbol?>()) {
      return (data != null ? _i46.YahooSymbol.fromJson(data) : null) as T;
    }
    if (t == List<_i30.OrderSummary>) {
      return (data as List)
              .map((e) => deserialize<_i30.OrderSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i10.ChartDataPoint>) {
      return (data as List)
              .map((e) => deserialize<_i10.ChartDataPoint>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i31.PeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i31.PeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, Map<String, _i5.AssetPeriodReturn>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<Map<String, _i5.AssetPeriodReturn>>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, _i5.AssetPeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i5.AssetPeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == List<_i20.HoldingResponse>) {
      return (data as List)
              .map((e) => deserialize<_i20.HoldingResponse>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i24.Issue>) {
      return (data as List).map((e) => deserialize<_i24.Issue>(e)).toList()
          as T;
    }
    if (t == List<_i39.SleeveAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i39.SleeveAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i7.AssetValuation>) {
      return (data as List)
              .map((e) => deserialize<_i7.AssetValuation>(e))
              .toList()
          as T;
    }
    if (t == List<_i28.MissingSymbolAsset>) {
      return (data as List)
              .map((e) => deserialize<_i28.MissingSymbolAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i43.StalePriceAsset>) {
      return (data as List)
              .map((e) => deserialize<_i43.StalePriceAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.ConcentrationViolation>) {
      return (data as List)
              .map((e) => deserialize<_i13.ConcentrationViolation>(e))
              .toList()
          as T;
    }
    if (t == List<_i41.SleeveNode>) {
      return (data as List).map((e) => deserialize<_i41.SleeveNode>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i41.SleeveNode>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i41.SleeveNode>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i47.Portfolio>) {
      return (data as List).map((e) => deserialize<_i47.Portfolio>(e)).toList()
          as T;
    }
    try {
      return _i48.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i49.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AllocationStatus => 'AllocationStatus',
      _i3.Asset => 'Asset',
      _i4.AssetDetailResponse => 'AssetDetailResponse',
      _i5.AssetPeriodReturn => 'AssetPeriodReturn',
      _i6.AssetType => 'AssetType',
      _i7.AssetValuation => 'AssetValuation',
      _i8.Band => 'Band',
      _i9.BandConfig => 'BandConfig',
      _i10.ChartDataPoint => 'ChartDataPoint',
      _i11.ChartDataResult => 'ChartDataResult',
      _i12.ChartRange => 'ChartRange',
      _i13.ConcentrationViolation => 'ConcentrationViolation',
      _i14.DailyPrice => 'DailyPrice',
      _i15.DividendEvent => 'DividendEvent',
      _i16.FxCache => 'FxCache',
      _i17.GlobalCash => 'GlobalCash',
      _i18.HistoricalReturnsResult => 'HistoricalReturnsResult',
      _i19.Holding => 'Holding',
      _i20.HoldingResponse => 'HoldingResponse',
      _i21.HoldingsListResponse => 'HoldingsListResponse',
      _i22.ImportResult => 'ImportResult',
      _i23.IntradayPrice => 'IntradayPrice',
      _i24.Issue => 'Issue',
      _i25.IssueSeverity => 'IssueSeverity',
      _i26.IssueType => 'IssueType',
      _i27.IssuesResponse => 'IssuesResponse',
      _i28.MissingSymbolAsset => 'MissingSymbolAsset',
      _i29.Order => 'Order',
      _i30.OrderSummary => 'OrderSummary',
      _i31.PeriodReturn => 'PeriodReturn',
      _i32.Portfolio => 'Portfolio',
      _i33.PortfolioRule => 'PortfolioRule',
      _i34.PortfolioValuation => 'PortfolioValuation',
      _i35.PriceCache => 'PriceCache',
      _i36.PriceUpdate => 'PriceUpdate',
      _i37.ReturnPeriod => 'ReturnPeriod',
      _i38.Sleeve => 'Sleeve',
      _i39.SleeveAllocation => 'SleeveAllocation',
      _i40.SleeveAsset => 'SleeveAsset',
      _i41.SleeveNode => 'SleeveNode',
      _i42.SleeveTreeResponse => 'SleeveTreeResponse',
      _i43.StalePriceAsset => 'StalePriceAsset',
      _i44.SyncStatus => 'SyncStatus',
      _i45.TickerMetadata => 'TickerMetadata',
      _i46.YahooSymbol => 'YahooSymbol',
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
      case _i3.Asset():
        return 'Asset';
      case _i4.AssetDetailResponse():
        return 'AssetDetailResponse';
      case _i5.AssetPeriodReturn():
        return 'AssetPeriodReturn';
      case _i6.AssetType():
        return 'AssetType';
      case _i7.AssetValuation():
        return 'AssetValuation';
      case _i8.Band():
        return 'Band';
      case _i9.BandConfig():
        return 'BandConfig';
      case _i10.ChartDataPoint():
        return 'ChartDataPoint';
      case _i11.ChartDataResult():
        return 'ChartDataResult';
      case _i12.ChartRange():
        return 'ChartRange';
      case _i13.ConcentrationViolation():
        return 'ConcentrationViolation';
      case _i14.DailyPrice():
        return 'DailyPrice';
      case _i15.DividendEvent():
        return 'DividendEvent';
      case _i16.FxCache():
        return 'FxCache';
      case _i17.GlobalCash():
        return 'GlobalCash';
      case _i18.HistoricalReturnsResult():
        return 'HistoricalReturnsResult';
      case _i19.Holding():
        return 'Holding';
      case _i20.HoldingResponse():
        return 'HoldingResponse';
      case _i21.HoldingsListResponse():
        return 'HoldingsListResponse';
      case _i22.ImportResult():
        return 'ImportResult';
      case _i23.IntradayPrice():
        return 'IntradayPrice';
      case _i24.Issue():
        return 'Issue';
      case _i25.IssueSeverity():
        return 'IssueSeverity';
      case _i26.IssueType():
        return 'IssueType';
      case _i27.IssuesResponse():
        return 'IssuesResponse';
      case _i28.MissingSymbolAsset():
        return 'MissingSymbolAsset';
      case _i29.Order():
        return 'Order';
      case _i30.OrderSummary():
        return 'OrderSummary';
      case _i31.PeriodReturn():
        return 'PeriodReturn';
      case _i32.Portfolio():
        return 'Portfolio';
      case _i33.PortfolioRule():
        return 'PortfolioRule';
      case _i34.PortfolioValuation():
        return 'PortfolioValuation';
      case _i35.PriceCache():
        return 'PriceCache';
      case _i36.PriceUpdate():
        return 'PriceUpdate';
      case _i37.ReturnPeriod():
        return 'ReturnPeriod';
      case _i38.Sleeve():
        return 'Sleeve';
      case _i39.SleeveAllocation():
        return 'SleeveAllocation';
      case _i40.SleeveAsset():
        return 'SleeveAsset';
      case _i41.SleeveNode():
        return 'SleeveNode';
      case _i42.SleeveTreeResponse():
        return 'SleeveTreeResponse';
      case _i43.StalePriceAsset():
        return 'StalePriceAsset';
      case _i44.SyncStatus():
        return 'SyncStatus';
      case _i45.TickerMetadata():
        return 'TickerMetadata';
      case _i46.YahooSymbol():
        return 'YahooSymbol';
    }
    className = _i48.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i49.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Asset') {
      return deserialize<_i3.Asset>(data['data']);
    }
    if (dataClassName == 'AssetDetailResponse') {
      return deserialize<_i4.AssetDetailResponse>(data['data']);
    }
    if (dataClassName == 'AssetPeriodReturn') {
      return deserialize<_i5.AssetPeriodReturn>(data['data']);
    }
    if (dataClassName == 'AssetType') {
      return deserialize<_i6.AssetType>(data['data']);
    }
    if (dataClassName == 'AssetValuation') {
      return deserialize<_i7.AssetValuation>(data['data']);
    }
    if (dataClassName == 'Band') {
      return deserialize<_i8.Band>(data['data']);
    }
    if (dataClassName == 'BandConfig') {
      return deserialize<_i9.BandConfig>(data['data']);
    }
    if (dataClassName == 'ChartDataPoint') {
      return deserialize<_i10.ChartDataPoint>(data['data']);
    }
    if (dataClassName == 'ChartDataResult') {
      return deserialize<_i11.ChartDataResult>(data['data']);
    }
    if (dataClassName == 'ChartRange') {
      return deserialize<_i12.ChartRange>(data['data']);
    }
    if (dataClassName == 'ConcentrationViolation') {
      return deserialize<_i13.ConcentrationViolation>(data['data']);
    }
    if (dataClassName == 'DailyPrice') {
      return deserialize<_i14.DailyPrice>(data['data']);
    }
    if (dataClassName == 'DividendEvent') {
      return deserialize<_i15.DividendEvent>(data['data']);
    }
    if (dataClassName == 'FxCache') {
      return deserialize<_i16.FxCache>(data['data']);
    }
    if (dataClassName == 'GlobalCash') {
      return deserialize<_i17.GlobalCash>(data['data']);
    }
    if (dataClassName == 'HistoricalReturnsResult') {
      return deserialize<_i18.HistoricalReturnsResult>(data['data']);
    }
    if (dataClassName == 'Holding') {
      return deserialize<_i19.Holding>(data['data']);
    }
    if (dataClassName == 'HoldingResponse') {
      return deserialize<_i20.HoldingResponse>(data['data']);
    }
    if (dataClassName == 'HoldingsListResponse') {
      return deserialize<_i21.HoldingsListResponse>(data['data']);
    }
    if (dataClassName == 'ImportResult') {
      return deserialize<_i22.ImportResult>(data['data']);
    }
    if (dataClassName == 'IntradayPrice') {
      return deserialize<_i23.IntradayPrice>(data['data']);
    }
    if (dataClassName == 'Issue') {
      return deserialize<_i24.Issue>(data['data']);
    }
    if (dataClassName == 'IssueSeverity') {
      return deserialize<_i25.IssueSeverity>(data['data']);
    }
    if (dataClassName == 'IssueType') {
      return deserialize<_i26.IssueType>(data['data']);
    }
    if (dataClassName == 'IssuesResponse') {
      return deserialize<_i27.IssuesResponse>(data['data']);
    }
    if (dataClassName == 'MissingSymbolAsset') {
      return deserialize<_i28.MissingSymbolAsset>(data['data']);
    }
    if (dataClassName == 'Order') {
      return deserialize<_i29.Order>(data['data']);
    }
    if (dataClassName == 'OrderSummary') {
      return deserialize<_i30.OrderSummary>(data['data']);
    }
    if (dataClassName == 'PeriodReturn') {
      return deserialize<_i31.PeriodReturn>(data['data']);
    }
    if (dataClassName == 'Portfolio') {
      return deserialize<_i32.Portfolio>(data['data']);
    }
    if (dataClassName == 'PortfolioRule') {
      return deserialize<_i33.PortfolioRule>(data['data']);
    }
    if (dataClassName == 'PortfolioValuation') {
      return deserialize<_i34.PortfolioValuation>(data['data']);
    }
    if (dataClassName == 'PriceCache') {
      return deserialize<_i35.PriceCache>(data['data']);
    }
    if (dataClassName == 'PriceUpdate') {
      return deserialize<_i36.PriceUpdate>(data['data']);
    }
    if (dataClassName == 'ReturnPeriod') {
      return deserialize<_i37.ReturnPeriod>(data['data']);
    }
    if (dataClassName == 'Sleeve') {
      return deserialize<_i38.Sleeve>(data['data']);
    }
    if (dataClassName == 'SleeveAllocation') {
      return deserialize<_i39.SleeveAllocation>(data['data']);
    }
    if (dataClassName == 'SleeveAsset') {
      return deserialize<_i40.SleeveAsset>(data['data']);
    }
    if (dataClassName == 'SleeveNode') {
      return deserialize<_i41.SleeveNode>(data['data']);
    }
    if (dataClassName == 'SleeveTreeResponse') {
      return deserialize<_i42.SleeveTreeResponse>(data['data']);
    }
    if (dataClassName == 'StalePriceAsset') {
      return deserialize<_i43.StalePriceAsset>(data['data']);
    }
    if (dataClassName == 'SyncStatus') {
      return deserialize<_i44.SyncStatus>(data['data']);
    }
    if (dataClassName == 'TickerMetadata') {
      return deserialize<_i45.TickerMetadata>(data['data']);
    }
    if (dataClassName == 'YahooSymbol') {
      return deserialize<_i46.YahooSymbol>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i48.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i49.Protocol().deserializeByClassName(data);
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
      return _i48.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i49.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
