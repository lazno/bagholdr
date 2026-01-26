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

/// OrderSummary - Simplified order for display in asset detail
abstract class OrderSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  OrderSummary._({
    required this.orderDate,
    required this.orderType,
    required this.quantity,
    required this.priceNative,
    required this.totalNative,
    required this.totalEur,
    required this.currency,
  });

  factory OrderSummary({
    required DateTime orderDate,
    required String orderType,
    required double quantity,
    required double priceNative,
    required double totalNative,
    required double totalEur,
    required String currency,
  }) = _OrderSummaryImpl;

  factory OrderSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderSummary(
      orderDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['orderDate'],
      ),
      orderType: jsonSerialization['orderType'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      priceNative: (jsonSerialization['priceNative'] as num).toDouble(),
      totalNative: (jsonSerialization['totalNative'] as num).toDouble(),
      totalEur: (jsonSerialization['totalEur'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
    );
  }

  /// Order date
  DateTime orderDate;

  /// Order type: buy, sell, fee
  String orderType;

  /// Quantity (positive for buy, negative for sell, 0 for fee)
  double quantity;

  /// Price per unit in native currency
  double priceNative;

  /// Total in native currency
  double totalNative;

  /// Total in EUR
  double totalEur;

  /// Currency code
  String currency;

  /// Returns a shallow copy of this [OrderSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderSummary copyWith({
    DateTime? orderDate,
    String? orderType,
    double? quantity,
    double? priceNative,
    double? totalNative,
    double? totalEur,
    String? currency,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderSummary',
      'orderDate': orderDate.toJson(),
      'orderType': orderType,
      'quantity': quantity,
      'priceNative': priceNative,
      'totalNative': totalNative,
      'totalEur': totalEur,
      'currency': currency,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrderSummary',
      'orderDate': orderDate.toJson(),
      'orderType': orderType,
      'quantity': quantity,
      'priceNative': priceNative,
      'totalNative': totalNative,
      'totalEur': totalEur,
      'currency': currency,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _OrderSummaryImpl extends OrderSummary {
  _OrderSummaryImpl({
    required DateTime orderDate,
    required String orderType,
    required double quantity,
    required double priceNative,
    required double totalNative,
    required double totalEur,
    required String currency,
  }) : super._(
         orderDate: orderDate,
         orderType: orderType,
         quantity: quantity,
         priceNative: priceNative,
         totalNative: totalNative,
         totalEur: totalEur,
         currency: currency,
       );

  /// Returns a shallow copy of this [OrderSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderSummary copyWith({
    DateTime? orderDate,
    String? orderType,
    double? quantity,
    double? priceNative,
    double? totalNative,
    double? totalEur,
    String? currency,
  }) {
    return OrderSummary(
      orderDate: orderDate ?? this.orderDate,
      orderType: orderType ?? this.orderType,
      quantity: quantity ?? this.quantity,
      priceNative: priceNative ?? this.priceNative,
      totalNative: totalNative ?? this.totalNative,
      totalEur: totalEur ?? this.totalEur,
      currency: currency ?? this.currency,
    );
  }
}
