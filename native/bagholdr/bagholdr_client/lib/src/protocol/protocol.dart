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
import 'asset.dart' as _i2;
import 'asset_type.dart' as _i3;
import 'daily_price.dart' as _i4;
import 'dividend_event.dart' as _i5;
import 'fx_cache.dart' as _i6;
import 'global_cash.dart' as _i7;
import 'holding.dart' as _i8;
import 'intraday_price.dart' as _i9;
import 'order.dart' as _i10;
import 'portfolio.dart' as _i11;
import 'portfolio_rule.dart' as _i12;
import 'price_cache.dart' as _i13;
import 'sleeve.dart' as _i14;
import 'sleeve_asset.dart' as _i15;
import 'ticker_metadata.dart' as _i16;
import 'yahoo_symbol.dart' as _i17;
import 'package:bagholdr_client/src/protocol/portfolio.dart' as _i18;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i19;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i20;
export 'asset.dart';
export 'asset_type.dart';
export 'daily_price.dart';
export 'dividend_event.dart';
export 'fx_cache.dart';
export 'global_cash.dart';
export 'holding.dart';
export 'intraday_price.dart';
export 'order.dart';
export 'portfolio.dart';
export 'portfolio_rule.dart';
export 'price_cache.dart';
export 'sleeve.dart';
export 'sleeve_asset.dart';
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

    if (t == _i2.Asset) {
      return _i2.Asset.fromJson(data) as T;
    }
    if (t == _i3.AssetType) {
      return _i3.AssetType.fromJson(data) as T;
    }
    if (t == _i4.DailyPrice) {
      return _i4.DailyPrice.fromJson(data) as T;
    }
    if (t == _i5.DividendEvent) {
      return _i5.DividendEvent.fromJson(data) as T;
    }
    if (t == _i6.FxCache) {
      return _i6.FxCache.fromJson(data) as T;
    }
    if (t == _i7.GlobalCash) {
      return _i7.GlobalCash.fromJson(data) as T;
    }
    if (t == _i8.Holding) {
      return _i8.Holding.fromJson(data) as T;
    }
    if (t == _i9.IntradayPrice) {
      return _i9.IntradayPrice.fromJson(data) as T;
    }
    if (t == _i10.Order) {
      return _i10.Order.fromJson(data) as T;
    }
    if (t == _i11.Portfolio) {
      return _i11.Portfolio.fromJson(data) as T;
    }
    if (t == _i12.PortfolioRule) {
      return _i12.PortfolioRule.fromJson(data) as T;
    }
    if (t == _i13.PriceCache) {
      return _i13.PriceCache.fromJson(data) as T;
    }
    if (t == _i14.Sleeve) {
      return _i14.Sleeve.fromJson(data) as T;
    }
    if (t == _i15.SleeveAsset) {
      return _i15.SleeveAsset.fromJson(data) as T;
    }
    if (t == _i16.TickerMetadata) {
      return _i16.TickerMetadata.fromJson(data) as T;
    }
    if (t == _i17.YahooSymbol) {
      return _i17.YahooSymbol.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Asset?>()) {
      return (data != null ? _i2.Asset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AssetType?>()) {
      return (data != null ? _i3.AssetType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DailyPrice?>()) {
      return (data != null ? _i4.DailyPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DividendEvent?>()) {
      return (data != null ? _i5.DividendEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.FxCache?>()) {
      return (data != null ? _i6.FxCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.GlobalCash?>()) {
      return (data != null ? _i7.GlobalCash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Holding?>()) {
      return (data != null ? _i8.Holding.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.IntradayPrice?>()) {
      return (data != null ? _i9.IntradayPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Order?>()) {
      return (data != null ? _i10.Order.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Portfolio?>()) {
      return (data != null ? _i11.Portfolio.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.PortfolioRule?>()) {
      return (data != null ? _i12.PortfolioRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.PriceCache?>()) {
      return (data != null ? _i13.PriceCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Sleeve?>()) {
      return (data != null ? _i14.Sleeve.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.SleeveAsset?>()) {
      return (data != null ? _i15.SleeveAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.TickerMetadata?>()) {
      return (data != null ? _i16.TickerMetadata.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.YahooSymbol?>()) {
      return (data != null ? _i17.YahooSymbol.fromJson(data) : null) as T;
    }
    if (t == List<_i18.Portfolio>) {
      return (data as List).map((e) => deserialize<_i18.Portfolio>(e)).toList()
          as T;
    }
    try {
      return _i19.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i20.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Asset => 'Asset',
      _i3.AssetType => 'AssetType',
      _i4.DailyPrice => 'DailyPrice',
      _i5.DividendEvent => 'DividendEvent',
      _i6.FxCache => 'FxCache',
      _i7.GlobalCash => 'GlobalCash',
      _i8.Holding => 'Holding',
      _i9.IntradayPrice => 'IntradayPrice',
      _i10.Order => 'Order',
      _i11.Portfolio => 'Portfolio',
      _i12.PortfolioRule => 'PortfolioRule',
      _i13.PriceCache => 'PriceCache',
      _i14.Sleeve => 'Sleeve',
      _i15.SleeveAsset => 'SleeveAsset',
      _i16.TickerMetadata => 'TickerMetadata',
      _i17.YahooSymbol => 'YahooSymbol',
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
      case _i2.Asset():
        return 'Asset';
      case _i3.AssetType():
        return 'AssetType';
      case _i4.DailyPrice():
        return 'DailyPrice';
      case _i5.DividendEvent():
        return 'DividendEvent';
      case _i6.FxCache():
        return 'FxCache';
      case _i7.GlobalCash():
        return 'GlobalCash';
      case _i8.Holding():
        return 'Holding';
      case _i9.IntradayPrice():
        return 'IntradayPrice';
      case _i10.Order():
        return 'Order';
      case _i11.Portfolio():
        return 'Portfolio';
      case _i12.PortfolioRule():
        return 'PortfolioRule';
      case _i13.PriceCache():
        return 'PriceCache';
      case _i14.Sleeve():
        return 'Sleeve';
      case _i15.SleeveAsset():
        return 'SleeveAsset';
      case _i16.TickerMetadata():
        return 'TickerMetadata';
      case _i17.YahooSymbol():
        return 'YahooSymbol';
    }
    className = _i19.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i20.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Asset') {
      return deserialize<_i2.Asset>(data['data']);
    }
    if (dataClassName == 'AssetType') {
      return deserialize<_i3.AssetType>(data['data']);
    }
    if (dataClassName == 'DailyPrice') {
      return deserialize<_i4.DailyPrice>(data['data']);
    }
    if (dataClassName == 'DividendEvent') {
      return deserialize<_i5.DividendEvent>(data['data']);
    }
    if (dataClassName == 'FxCache') {
      return deserialize<_i6.FxCache>(data['data']);
    }
    if (dataClassName == 'GlobalCash') {
      return deserialize<_i7.GlobalCash>(data['data']);
    }
    if (dataClassName == 'Holding') {
      return deserialize<_i8.Holding>(data['data']);
    }
    if (dataClassName == 'IntradayPrice') {
      return deserialize<_i9.IntradayPrice>(data['data']);
    }
    if (dataClassName == 'Order') {
      return deserialize<_i10.Order>(data['data']);
    }
    if (dataClassName == 'Portfolio') {
      return deserialize<_i11.Portfolio>(data['data']);
    }
    if (dataClassName == 'PortfolioRule') {
      return deserialize<_i12.PortfolioRule>(data['data']);
    }
    if (dataClassName == 'PriceCache') {
      return deserialize<_i13.PriceCache>(data['data']);
    }
    if (dataClassName == 'Sleeve') {
      return deserialize<_i14.Sleeve>(data['data']);
    }
    if (dataClassName == 'SleeveAsset') {
      return deserialize<_i15.SleeveAsset>(data['data']);
    }
    if (dataClassName == 'TickerMetadata') {
      return deserialize<_i16.TickerMetadata>(data['data']);
    }
    if (dataClassName == 'YahooSymbol') {
      return deserialize<_i17.YahooSymbol>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i19.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i20.Protocol().deserializeByClassName(data);
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
      return _i19.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i20.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
