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

/// DividendEvent - Dividend payout history from Yahoo Finance
/// Tracks ex-dates and amounts for dividend-paying assets
abstract class DividendEvent implements _i1.SerializableModel {
  DividendEvent._({
    this.id,
    required this.ticker,
    required this.exDate,
    required this.amount,
    required this.currency,
    required this.fetchedAt,
  });

  factory DividendEvent({
    _i1.UuidValue? id,
    required String ticker,
    required String exDate,
    required double amount,
    required String currency,
    required DateTime fetchedAt,
  }) = _DividendEventImpl;

  factory DividendEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DividendEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      exDate: jsonSerialization['exDate'] as String,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Ex-dividend date in YYYY-MM-DD format
  String exDate;

  /// Dividend amount per share
  double amount;

  /// Currency of the dividend
  String currency;

  /// When this dividend data was fetched
  DateTime fetchedAt;

  /// Returns a shallow copy of this [DividendEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DividendEvent copyWith({
    _i1.UuidValue? id,
    String? ticker,
    String? exDate,
    double? amount,
    String? currency,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DividendEvent',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'exDate': exDate,
      'amount': amount,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DividendEventImpl extends DividendEvent {
  _DividendEventImpl({
    _i1.UuidValue? id,
    required String ticker,
    required String exDate,
    required double amount,
    required String currency,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         exDate: exDate,
         amount: amount,
         currency: currency,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [DividendEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DividendEvent copyWith({
    Object? id = _Undefined,
    String? ticker,
    String? exDate,
    double? amount,
    String? currency,
    DateTime? fetchedAt,
  }) {
    return DividendEvent(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      exDate: exDate ?? this.exDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
