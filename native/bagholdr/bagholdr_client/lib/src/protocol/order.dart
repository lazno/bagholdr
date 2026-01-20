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

/// Order - Raw imported orders from broker CSV
/// Global table (audit trail), not per-portfolio
abstract class Order implements _i1.SerializableModel {
  Order._({
    this.id,
    required this.assetId,
    required this.orderDate,
    required this.quantity,
    required this.priceNative,
    required this.totalNative,
    required this.totalEur,
    required this.currency,
    this.orderReference,
    required this.importedAt,
  });

  factory Order({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required DateTime orderDate,
    required double quantity,
    required double priceNative,
    required double totalNative,
    required double totalEur,
    required String currency,
    String? orderReference,
    required DateTime importedAt,
  }) = _OrderImpl;

  factory Order.fromJson(Map<String, dynamic> jsonSerialization) {
    return Order(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
      orderDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['orderDate'],
      ),
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      priceNative: (jsonSerialization['priceNative'] as num).toDouble(),
      totalNative: (jsonSerialization['totalNative'] as num).toDouble(),
      totalEur: (jsonSerialization['totalEur'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
      orderReference: jsonSerialization['orderReference'] as String?,
      importedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['importedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  /// Date the order was executed
  DateTime orderDate;

  /// Quantity bought (positive) or sold (negative)
  double quantity;

  /// Price per unit in the native currency
  double priceNative;

  /// Total value in native currency (quantity * priceNative)
  double totalNative;

  /// Total value in EUR (converted at order time)
  double totalEur;

  /// Currency of the order (e.g., EUR, USD)
  String currency;

  /// Optional broker order reference number
  String? orderReference;

  /// Timestamp when this order was imported into the system
  DateTime importedAt;

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Order copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? assetId,
    DateTime? orderDate,
    double? quantity,
    double? priceNative,
    double? totalNative,
    double? totalEur,
    String? currency,
    String? orderReference,
    DateTime? importedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Order',
      if (id != null) 'id': id?.toJson(),
      'assetId': assetId.toJson(),
      'orderDate': orderDate.toJson(),
      'quantity': quantity,
      'priceNative': priceNative,
      'totalNative': totalNative,
      'totalEur': totalEur,
      'currency': currency,
      if (orderReference != null) 'orderReference': orderReference,
      'importedAt': importedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderImpl extends Order {
  _OrderImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required DateTime orderDate,
    required double quantity,
    required double priceNative,
    required double totalNative,
    required double totalEur,
    required String currency,
    String? orderReference,
    required DateTime importedAt,
  }) : super._(
         id: id,
         assetId: assetId,
         orderDate: orderDate,
         quantity: quantity,
         priceNative: priceNative,
         totalNative: totalNative,
         totalEur: totalEur,
         currency: currency,
         orderReference: orderReference,
         importedAt: importedAt,
       );

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Order copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? assetId,
    DateTime? orderDate,
    double? quantity,
    double? priceNative,
    double? totalNative,
    double? totalEur,
    String? currency,
    Object? orderReference = _Undefined,
    DateTime? importedAt,
  }) {
    return Order(
      id: id is _i1.UuidValue? ? id : this.id,
      assetId: assetId ?? this.assetId,
      orderDate: orderDate ?? this.orderDate,
      quantity: quantity ?? this.quantity,
      priceNative: priceNative ?? this.priceNative,
      totalNative: totalNative ?? this.totalNative,
      totalEur: totalEur ?? this.totalEur,
      currency: currency ?? this.currency,
      orderReference: orderReference is String?
          ? orderReference
          : this.orderReference,
      importedAt: importedAt ?? this.importedAt,
    );
  }
}
