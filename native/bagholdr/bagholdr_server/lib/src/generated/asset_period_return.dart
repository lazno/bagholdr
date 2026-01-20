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
import 'package:serverpod/serverpod.dart' as _i1;

/// AssetPeriodReturn - Return calculation for a single asset over a period
abstract class AssetPeriodReturn
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AssetPeriodReturn._({
    required this.isin,
    required this.ticker,
    this.currentPrice,
    this.historicalPrice,
    this.absoluteReturn,
    this.compoundedReturn,
    this.annualizedReturn,
    this.periodYears,
    required this.isShortHolding,
    this.holdingPeriodLabel,
  });

  factory AssetPeriodReturn({
    required String isin,
    required String ticker,
    double? currentPrice,
    double? historicalPrice,
    double? absoluteReturn,
    double? compoundedReturn,
    double? annualizedReturn,
    double? periodYears,
    required bool isShortHolding,
    String? holdingPeriodLabel,
  }) = _AssetPeriodReturnImpl;

  factory AssetPeriodReturn.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetPeriodReturn(
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      currentPrice: (jsonSerialization['currentPrice'] as num?)?.toDouble(),
      historicalPrice: (jsonSerialization['historicalPrice'] as num?)
          ?.toDouble(),
      absoluteReturn: (jsonSerialization['absoluteReturn'] as num?)?.toDouble(),
      compoundedReturn: (jsonSerialization['compoundedReturn'] as num?)
          ?.toDouble(),
      annualizedReturn: (jsonSerialization['annualizedReturn'] as num?)
          ?.toDouble(),
      periodYears: (jsonSerialization['periodYears'] as num?)?.toDouble(),
      isShortHolding: jsonSerialization['isShortHolding'] as bool,
      holdingPeriodLabel: jsonSerialization['holdingPeriodLabel'] as String?,
    );
  }

  /// ISIN identifier
  String isin;

  /// Broker ticker symbol
  String ticker;

  /// Current price in EUR (null if not available)
  double? currentPrice;

  /// Historical price in EUR at period start (null if not available)
  double? historicalPrice;

  /// Absolute return (profit/loss) in EUR for the period
  double? absoluteReturn;

  /// Total percentage return over period
  double? compoundedReturn;

  /// Annualized percentage return (p.a.)
  double? annualizedReturn;

  /// Actual period in years (may be shorter if recently purchased)
  double? periodYears;

  /// Whether this asset was purchased after period start
  bool isShortHolding;

  /// Holding period label for short holdings (e.g., "6mo", "3mo")
  String? holdingPeriodLabel;

  /// Returns a shallow copy of this [AssetPeriodReturn]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AssetPeriodReturn copyWith({
    String? isin,
    String? ticker,
    double? currentPrice,
    double? historicalPrice,
    double? absoluteReturn,
    double? compoundedReturn,
    double? annualizedReturn,
    double? periodYears,
    bool? isShortHolding,
    String? holdingPeriodLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetPeriodReturn',
      'isin': isin,
      'ticker': ticker,
      if (currentPrice != null) 'currentPrice': currentPrice,
      if (historicalPrice != null) 'historicalPrice': historicalPrice,
      if (absoluteReturn != null) 'absoluteReturn': absoluteReturn,
      if (compoundedReturn != null) 'compoundedReturn': compoundedReturn,
      if (annualizedReturn != null) 'annualizedReturn': annualizedReturn,
      if (periodYears != null) 'periodYears': periodYears,
      'isShortHolding': isShortHolding,
      if (holdingPeriodLabel != null) 'holdingPeriodLabel': holdingPeriodLabel,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssetPeriodReturn',
      'isin': isin,
      'ticker': ticker,
      if (currentPrice != null) 'currentPrice': currentPrice,
      if (historicalPrice != null) 'historicalPrice': historicalPrice,
      if (absoluteReturn != null) 'absoluteReturn': absoluteReturn,
      if (compoundedReturn != null) 'compoundedReturn': compoundedReturn,
      if (annualizedReturn != null) 'annualizedReturn': annualizedReturn,
      if (periodYears != null) 'periodYears': periodYears,
      'isShortHolding': isShortHolding,
      if (holdingPeriodLabel != null) 'holdingPeriodLabel': holdingPeriodLabel,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetPeriodReturnImpl extends AssetPeriodReturn {
  _AssetPeriodReturnImpl({
    required String isin,
    required String ticker,
    double? currentPrice,
    double? historicalPrice,
    double? absoluteReturn,
    double? compoundedReturn,
    double? annualizedReturn,
    double? periodYears,
    required bool isShortHolding,
    String? holdingPeriodLabel,
  }) : super._(
         isin: isin,
         ticker: ticker,
         currentPrice: currentPrice,
         historicalPrice: historicalPrice,
         absoluteReturn: absoluteReturn,
         compoundedReturn: compoundedReturn,
         annualizedReturn: annualizedReturn,
         periodYears: periodYears,
         isShortHolding: isShortHolding,
         holdingPeriodLabel: holdingPeriodLabel,
       );

  /// Returns a shallow copy of this [AssetPeriodReturn]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AssetPeriodReturn copyWith({
    String? isin,
    String? ticker,
    Object? currentPrice = _Undefined,
    Object? historicalPrice = _Undefined,
    Object? absoluteReturn = _Undefined,
    Object? compoundedReturn = _Undefined,
    Object? annualizedReturn = _Undefined,
    Object? periodYears = _Undefined,
    bool? isShortHolding,
    Object? holdingPeriodLabel = _Undefined,
  }) {
    return AssetPeriodReturn(
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      currentPrice: currentPrice is double? ? currentPrice : this.currentPrice,
      historicalPrice: historicalPrice is double?
          ? historicalPrice
          : this.historicalPrice,
      absoluteReturn: absoluteReturn is double?
          ? absoluteReturn
          : this.absoluteReturn,
      compoundedReturn: compoundedReturn is double?
          ? compoundedReturn
          : this.compoundedReturn,
      annualizedReturn: annualizedReturn is double?
          ? annualizedReturn
          : this.annualizedReturn,
      periodYears: periodYears is double? ? periodYears : this.periodYears,
      isShortHolding: isShortHolding ?? this.isShortHolding,
      holdingPeriodLabel: holdingPeriodLabel is String?
          ? holdingPeriodLabel
          : this.holdingPeriodLabel,
    );
  }
}
