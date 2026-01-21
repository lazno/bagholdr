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
import 'asset_period_return.dart' as _i4;
import 'asset_type.dart' as _i5;
import 'asset_valuation.dart' as _i6;
import 'band.dart' as _i7;
import 'band_config.dart' as _i8;
import 'chart_data_point.dart' as _i9;
import 'chart_data_result.dart' as _i10;
import 'chart_range.dart' as _i11;
import 'concentration_violation.dart' as _i12;
import 'daily_price.dart' as _i13;
import 'dividend_event.dart' as _i14;
import 'fx_cache.dart' as _i15;
import 'global_cash.dart' as _i16;
import 'historical_returns_result.dart' as _i17;
import 'holding.dart' as _i18;
import 'holding_response.dart' as _i19;
import 'holdings_list_response.dart' as _i20;
import 'intraday_price.dart' as _i21;
import 'missing_symbol_asset.dart' as _i22;
import 'order.dart' as _i23;
import 'period_return.dart' as _i24;
import 'portfolio.dart' as _i25;
import 'portfolio_rule.dart' as _i26;
import 'portfolio_valuation.dart' as _i27;
import 'price_cache.dart' as _i28;
import 'return_period.dart' as _i29;
import 'sleeve.dart' as _i30;
import 'sleeve_allocation.dart' as _i31;
import 'sleeve_asset.dart' as _i32;
import 'sleeve_node.dart' as _i33;
import 'sleeve_tree_response.dart' as _i34;
import 'stale_price_asset.dart' as _i35;
import 'ticker_metadata.dart' as _i36;
import 'yahoo_symbol.dart' as _i37;
import 'package:bagholdr_client/src/protocol/portfolio.dart' as _i38;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i39;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i40;
export 'allocation_status.dart';
export 'asset.dart';
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
export 'intraday_price.dart';
export 'missing_symbol_asset.dart';
export 'order.dart';
export 'period_return.dart';
export 'portfolio.dart';
export 'portfolio_rule.dart';
export 'portfolio_valuation.dart';
export 'price_cache.dart';
export 'return_period.dart';
export 'sleeve.dart';
export 'sleeve_allocation.dart';
export 'sleeve_asset.dart';
export 'sleeve_node.dart';
export 'sleeve_tree_response.dart';
export 'stale_price_asset.dart';
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
    if (t == _i4.AssetPeriodReturn) {
      return _i4.AssetPeriodReturn.fromJson(data) as T;
    }
    if (t == _i5.AssetType) {
      return _i5.AssetType.fromJson(data) as T;
    }
    if (t == _i6.AssetValuation) {
      return _i6.AssetValuation.fromJson(data) as T;
    }
    if (t == _i7.Band) {
      return _i7.Band.fromJson(data) as T;
    }
    if (t == _i8.BandConfig) {
      return _i8.BandConfig.fromJson(data) as T;
    }
    if (t == _i9.ChartDataPoint) {
      return _i9.ChartDataPoint.fromJson(data) as T;
    }
    if (t == _i10.ChartDataResult) {
      return _i10.ChartDataResult.fromJson(data) as T;
    }
    if (t == _i11.ChartRange) {
      return _i11.ChartRange.fromJson(data) as T;
    }
    if (t == _i12.ConcentrationViolation) {
      return _i12.ConcentrationViolation.fromJson(data) as T;
    }
    if (t == _i13.DailyPrice) {
      return _i13.DailyPrice.fromJson(data) as T;
    }
    if (t == _i14.DividendEvent) {
      return _i14.DividendEvent.fromJson(data) as T;
    }
    if (t == _i15.FxCache) {
      return _i15.FxCache.fromJson(data) as T;
    }
    if (t == _i16.GlobalCash) {
      return _i16.GlobalCash.fromJson(data) as T;
    }
    if (t == _i17.HistoricalReturnsResult) {
      return _i17.HistoricalReturnsResult.fromJson(data) as T;
    }
    if (t == _i18.Holding) {
      return _i18.Holding.fromJson(data) as T;
    }
    if (t == _i19.HoldingResponse) {
      return _i19.HoldingResponse.fromJson(data) as T;
    }
    if (t == _i20.HoldingsListResponse) {
      return _i20.HoldingsListResponse.fromJson(data) as T;
    }
    if (t == _i21.IntradayPrice) {
      return _i21.IntradayPrice.fromJson(data) as T;
    }
    if (t == _i22.MissingSymbolAsset) {
      return _i22.MissingSymbolAsset.fromJson(data) as T;
    }
    if (t == _i23.Order) {
      return _i23.Order.fromJson(data) as T;
    }
    if (t == _i24.PeriodReturn) {
      return _i24.PeriodReturn.fromJson(data) as T;
    }
    if (t == _i25.Portfolio) {
      return _i25.Portfolio.fromJson(data) as T;
    }
    if (t == _i26.PortfolioRule) {
      return _i26.PortfolioRule.fromJson(data) as T;
    }
    if (t == _i27.PortfolioValuation) {
      return _i27.PortfolioValuation.fromJson(data) as T;
    }
    if (t == _i28.PriceCache) {
      return _i28.PriceCache.fromJson(data) as T;
    }
    if (t == _i29.ReturnPeriod) {
      return _i29.ReturnPeriod.fromJson(data) as T;
    }
    if (t == _i30.Sleeve) {
      return _i30.Sleeve.fromJson(data) as T;
    }
    if (t == _i31.SleeveAllocation) {
      return _i31.SleeveAllocation.fromJson(data) as T;
    }
    if (t == _i32.SleeveAsset) {
      return _i32.SleeveAsset.fromJson(data) as T;
    }
    if (t == _i33.SleeveNode) {
      return _i33.SleeveNode.fromJson(data) as T;
    }
    if (t == _i34.SleeveTreeResponse) {
      return _i34.SleeveTreeResponse.fromJson(data) as T;
    }
    if (t == _i35.StalePriceAsset) {
      return _i35.StalePriceAsset.fromJson(data) as T;
    }
    if (t == _i36.TickerMetadata) {
      return _i36.TickerMetadata.fromJson(data) as T;
    }
    if (t == _i37.YahooSymbol) {
      return _i37.YahooSymbol.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AllocationStatus?>()) {
      return (data != null ? _i2.AllocationStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Asset?>()) {
      return (data != null ? _i3.Asset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AssetPeriodReturn?>()) {
      return (data != null ? _i4.AssetPeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AssetType?>()) {
      return (data != null ? _i5.AssetType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AssetValuation?>()) {
      return (data != null ? _i6.AssetValuation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Band?>()) {
      return (data != null ? _i7.Band.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.BandConfig?>()) {
      return (data != null ? _i8.BandConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ChartDataPoint?>()) {
      return (data != null ? _i9.ChartDataPoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ChartDataResult?>()) {
      return (data != null ? _i10.ChartDataResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ChartRange?>()) {
      return (data != null ? _i11.ChartRange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.ConcentrationViolation?>()) {
      return (data != null ? _i12.ConcentrationViolation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DailyPrice?>()) {
      return (data != null ? _i13.DailyPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.DividendEvent?>()) {
      return (data != null ? _i14.DividendEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.FxCache?>()) {
      return (data != null ? _i15.FxCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.GlobalCash?>()) {
      return (data != null ? _i16.GlobalCash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.HistoricalReturnsResult?>()) {
      return (data != null ? _i17.HistoricalReturnsResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.Holding?>()) {
      return (data != null ? _i18.Holding.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.HoldingResponse?>()) {
      return (data != null ? _i19.HoldingResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.HoldingsListResponse?>()) {
      return (data != null ? _i20.HoldingsListResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.IntradayPrice?>()) {
      return (data != null ? _i21.IntradayPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.MissingSymbolAsset?>()) {
      return (data != null ? _i22.MissingSymbolAsset.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.Order?>()) {
      return (data != null ? _i23.Order.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.PeriodReturn?>()) {
      return (data != null ? _i24.PeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.Portfolio?>()) {
      return (data != null ? _i25.Portfolio.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.PortfolioRule?>()) {
      return (data != null ? _i26.PortfolioRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.PortfolioValuation?>()) {
      return (data != null ? _i27.PortfolioValuation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.PriceCache?>()) {
      return (data != null ? _i28.PriceCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.ReturnPeriod?>()) {
      return (data != null ? _i29.ReturnPeriod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.Sleeve?>()) {
      return (data != null ? _i30.Sleeve.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.SleeveAllocation?>()) {
      return (data != null ? _i31.SleeveAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.SleeveAsset?>()) {
      return (data != null ? _i32.SleeveAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.SleeveNode?>()) {
      return (data != null ? _i33.SleeveNode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.SleeveTreeResponse?>()) {
      return (data != null ? _i34.SleeveTreeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.StalePriceAsset?>()) {
      return (data != null ? _i35.StalePriceAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.TickerMetadata?>()) {
      return (data != null ? _i36.TickerMetadata.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.YahooSymbol?>()) {
      return (data != null ? _i37.YahooSymbol.fromJson(data) : null) as T;
    }
    if (t == List<_i9.ChartDataPoint>) {
      return (data as List)
              .map((e) => deserialize<_i9.ChartDataPoint>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i24.PeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i24.PeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, Map<String, _i4.AssetPeriodReturn>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<Map<String, _i4.AssetPeriodReturn>>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, _i4.AssetPeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i4.AssetPeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == List<_i19.HoldingResponse>) {
      return (data as List)
              .map((e) => deserialize<_i19.HoldingResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i31.SleeveAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i31.SleeveAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i6.AssetValuation>) {
      return (data as List)
              .map((e) => deserialize<_i6.AssetValuation>(e))
              .toList()
          as T;
    }
    if (t == List<_i22.MissingSymbolAsset>) {
      return (data as List)
              .map((e) => deserialize<_i22.MissingSymbolAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i35.StalePriceAsset>) {
      return (data as List)
              .map((e) => deserialize<_i35.StalePriceAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i12.ConcentrationViolation>) {
      return (data as List)
              .map((e) => deserialize<_i12.ConcentrationViolation>(e))
              .toList()
          as T;
    }
    if (t == List<_i33.SleeveNode>) {
      return (data as List).map((e) => deserialize<_i33.SleeveNode>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i33.SleeveNode>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i33.SleeveNode>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i38.Portfolio>) {
      return (data as List).map((e) => deserialize<_i38.Portfolio>(e)).toList()
          as T;
    }
    try {
      return _i39.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i40.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AllocationStatus => 'AllocationStatus',
      _i3.Asset => 'Asset',
      _i4.AssetPeriodReturn => 'AssetPeriodReturn',
      _i5.AssetType => 'AssetType',
      _i6.AssetValuation => 'AssetValuation',
      _i7.Band => 'Band',
      _i8.BandConfig => 'BandConfig',
      _i9.ChartDataPoint => 'ChartDataPoint',
      _i10.ChartDataResult => 'ChartDataResult',
      _i11.ChartRange => 'ChartRange',
      _i12.ConcentrationViolation => 'ConcentrationViolation',
      _i13.DailyPrice => 'DailyPrice',
      _i14.DividendEvent => 'DividendEvent',
      _i15.FxCache => 'FxCache',
      _i16.GlobalCash => 'GlobalCash',
      _i17.HistoricalReturnsResult => 'HistoricalReturnsResult',
      _i18.Holding => 'Holding',
      _i19.HoldingResponse => 'HoldingResponse',
      _i20.HoldingsListResponse => 'HoldingsListResponse',
      _i21.IntradayPrice => 'IntradayPrice',
      _i22.MissingSymbolAsset => 'MissingSymbolAsset',
      _i23.Order => 'Order',
      _i24.PeriodReturn => 'PeriodReturn',
      _i25.Portfolio => 'Portfolio',
      _i26.PortfolioRule => 'PortfolioRule',
      _i27.PortfolioValuation => 'PortfolioValuation',
      _i28.PriceCache => 'PriceCache',
      _i29.ReturnPeriod => 'ReturnPeriod',
      _i30.Sleeve => 'Sleeve',
      _i31.SleeveAllocation => 'SleeveAllocation',
      _i32.SleeveAsset => 'SleeveAsset',
      _i33.SleeveNode => 'SleeveNode',
      _i34.SleeveTreeResponse => 'SleeveTreeResponse',
      _i35.StalePriceAsset => 'StalePriceAsset',
      _i36.TickerMetadata => 'TickerMetadata',
      _i37.YahooSymbol => 'YahooSymbol',
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
      case _i4.AssetPeriodReturn():
        return 'AssetPeriodReturn';
      case _i5.AssetType():
        return 'AssetType';
      case _i6.AssetValuation():
        return 'AssetValuation';
      case _i7.Band():
        return 'Band';
      case _i8.BandConfig():
        return 'BandConfig';
      case _i9.ChartDataPoint():
        return 'ChartDataPoint';
      case _i10.ChartDataResult():
        return 'ChartDataResult';
      case _i11.ChartRange():
        return 'ChartRange';
      case _i12.ConcentrationViolation():
        return 'ConcentrationViolation';
      case _i13.DailyPrice():
        return 'DailyPrice';
      case _i14.DividendEvent():
        return 'DividendEvent';
      case _i15.FxCache():
        return 'FxCache';
      case _i16.GlobalCash():
        return 'GlobalCash';
      case _i17.HistoricalReturnsResult():
        return 'HistoricalReturnsResult';
      case _i18.Holding():
        return 'Holding';
      case _i19.HoldingResponse():
        return 'HoldingResponse';
      case _i20.HoldingsListResponse():
        return 'HoldingsListResponse';
      case _i21.IntradayPrice():
        return 'IntradayPrice';
      case _i22.MissingSymbolAsset():
        return 'MissingSymbolAsset';
      case _i23.Order():
        return 'Order';
      case _i24.PeriodReturn():
        return 'PeriodReturn';
      case _i25.Portfolio():
        return 'Portfolio';
      case _i26.PortfolioRule():
        return 'PortfolioRule';
      case _i27.PortfolioValuation():
        return 'PortfolioValuation';
      case _i28.PriceCache():
        return 'PriceCache';
      case _i29.ReturnPeriod():
        return 'ReturnPeriod';
      case _i30.Sleeve():
        return 'Sleeve';
      case _i31.SleeveAllocation():
        return 'SleeveAllocation';
      case _i32.SleeveAsset():
        return 'SleeveAsset';
      case _i33.SleeveNode():
        return 'SleeveNode';
      case _i34.SleeveTreeResponse():
        return 'SleeveTreeResponse';
      case _i35.StalePriceAsset():
        return 'StalePriceAsset';
      case _i36.TickerMetadata():
        return 'TickerMetadata';
      case _i37.YahooSymbol():
        return 'YahooSymbol';
    }
    className = _i39.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i40.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'AssetPeriodReturn') {
      return deserialize<_i4.AssetPeriodReturn>(data['data']);
    }
    if (dataClassName == 'AssetType') {
      return deserialize<_i5.AssetType>(data['data']);
    }
    if (dataClassName == 'AssetValuation') {
      return deserialize<_i6.AssetValuation>(data['data']);
    }
    if (dataClassName == 'Band') {
      return deserialize<_i7.Band>(data['data']);
    }
    if (dataClassName == 'BandConfig') {
      return deserialize<_i8.BandConfig>(data['data']);
    }
    if (dataClassName == 'ChartDataPoint') {
      return deserialize<_i9.ChartDataPoint>(data['data']);
    }
    if (dataClassName == 'ChartDataResult') {
      return deserialize<_i10.ChartDataResult>(data['data']);
    }
    if (dataClassName == 'ChartRange') {
      return deserialize<_i11.ChartRange>(data['data']);
    }
    if (dataClassName == 'ConcentrationViolation') {
      return deserialize<_i12.ConcentrationViolation>(data['data']);
    }
    if (dataClassName == 'DailyPrice') {
      return deserialize<_i13.DailyPrice>(data['data']);
    }
    if (dataClassName == 'DividendEvent') {
      return deserialize<_i14.DividendEvent>(data['data']);
    }
    if (dataClassName == 'FxCache') {
      return deserialize<_i15.FxCache>(data['data']);
    }
    if (dataClassName == 'GlobalCash') {
      return deserialize<_i16.GlobalCash>(data['data']);
    }
    if (dataClassName == 'HistoricalReturnsResult') {
      return deserialize<_i17.HistoricalReturnsResult>(data['data']);
    }
    if (dataClassName == 'Holding') {
      return deserialize<_i18.Holding>(data['data']);
    }
    if (dataClassName == 'HoldingResponse') {
      return deserialize<_i19.HoldingResponse>(data['data']);
    }
    if (dataClassName == 'HoldingsListResponse') {
      return deserialize<_i20.HoldingsListResponse>(data['data']);
    }
    if (dataClassName == 'IntradayPrice') {
      return deserialize<_i21.IntradayPrice>(data['data']);
    }
    if (dataClassName == 'MissingSymbolAsset') {
      return deserialize<_i22.MissingSymbolAsset>(data['data']);
    }
    if (dataClassName == 'Order') {
      return deserialize<_i23.Order>(data['data']);
    }
    if (dataClassName == 'PeriodReturn') {
      return deserialize<_i24.PeriodReturn>(data['data']);
    }
    if (dataClassName == 'Portfolio') {
      return deserialize<_i25.Portfolio>(data['data']);
    }
    if (dataClassName == 'PortfolioRule') {
      return deserialize<_i26.PortfolioRule>(data['data']);
    }
    if (dataClassName == 'PortfolioValuation') {
      return deserialize<_i27.PortfolioValuation>(data['data']);
    }
    if (dataClassName == 'PriceCache') {
      return deserialize<_i28.PriceCache>(data['data']);
    }
    if (dataClassName == 'ReturnPeriod') {
      return deserialize<_i29.ReturnPeriod>(data['data']);
    }
    if (dataClassName == 'Sleeve') {
      return deserialize<_i30.Sleeve>(data['data']);
    }
    if (dataClassName == 'SleeveAllocation') {
      return deserialize<_i31.SleeveAllocation>(data['data']);
    }
    if (dataClassName == 'SleeveAsset') {
      return deserialize<_i32.SleeveAsset>(data['data']);
    }
    if (dataClassName == 'SleeveNode') {
      return deserialize<_i33.SleeveNode>(data['data']);
    }
    if (dataClassName == 'SleeveTreeResponse') {
      return deserialize<_i34.SleeveTreeResponse>(data['data']);
    }
    if (dataClassName == 'StalePriceAsset') {
      return deserialize<_i35.StalePriceAsset>(data['data']);
    }
    if (dataClassName == 'TickerMetadata') {
      return deserialize<_i36.TickerMetadata>(data['data']);
    }
    if (dataClassName == 'YahooSymbol') {
      return deserialize<_i37.YahooSymbol>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i39.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i40.Protocol().deserializeByClassName(data);
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
      return _i39.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i40.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
