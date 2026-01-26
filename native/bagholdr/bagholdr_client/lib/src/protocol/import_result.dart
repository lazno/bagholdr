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
import 'package:bagholdr_client/src/protocol/protocol.dart' as _i2;

/// ImportResult - Result of importing orders from CSV
/// Not persisted - just a response type
abstract class ImportResult implements _i1.SerializableModel {
  ImportResult._({
    required this.ordersImported,
    required this.rowsSkipped,
    required this.assetsCreated,
    required this.holdingsUpdated,
    required this.errors,
    required this.warnings,
  });

  factory ImportResult({
    required int ordersImported,
    required int rowsSkipped,
    required int assetsCreated,
    required int holdingsUpdated,
    required List<String> errors,
    required List<String> warnings,
  }) = _ImportResultImpl;

  factory ImportResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImportResult(
      ordersImported: jsonSerialization['ordersImported'] as int,
      rowsSkipped: jsonSerialization['rowsSkipped'] as int,
      assetsCreated: jsonSerialization['assetsCreated'] as int,
      holdingsUpdated: jsonSerialization['holdingsUpdated'] as int,
      errors: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['errors'],
      ),
      warnings: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
    );
  }

  /// Number of orders successfully imported
  int ordersImported;

  /// Number of rows skipped (non-importable transaction types)
  int rowsSkipped;

  /// Number of new assets created
  int assetsCreated;

  /// Number of holdings updated
  int holdingsUpdated;

  /// Parse errors encountered (line number: message)
  List<String> errors;

  /// Warnings (non-fatal issues)
  List<String> warnings;

  /// Returns a shallow copy of this [ImportResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImportResult copyWith({
    int? ordersImported,
    int? rowsSkipped,
    int? assetsCreated,
    int? holdingsUpdated,
    List<String>? errors,
    List<String>? warnings,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ImportResult',
      'ordersImported': ordersImported,
      'rowsSkipped': rowsSkipped,
      'assetsCreated': assetsCreated,
      'holdingsUpdated': holdingsUpdated,
      'errors': errors.toJson(),
      'warnings': warnings.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ImportResultImpl extends ImportResult {
  _ImportResultImpl({
    required int ordersImported,
    required int rowsSkipped,
    required int assetsCreated,
    required int holdingsUpdated,
    required List<String> errors,
    required List<String> warnings,
  }) : super._(
         ordersImported: ordersImported,
         rowsSkipped: rowsSkipped,
         assetsCreated: assetsCreated,
         holdingsUpdated: holdingsUpdated,
         errors: errors,
         warnings: warnings,
       );

  /// Returns a shallow copy of this [ImportResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImportResult copyWith({
    int? ordersImported,
    int? rowsSkipped,
    int? assetsCreated,
    int? holdingsUpdated,
    List<String>? errors,
    List<String>? warnings,
  }) {
    return ImportResult(
      ordersImported: ordersImported ?? this.ordersImported,
      rowsSkipped: rowsSkipped ?? this.rowsSkipped,
      assetsCreated: assetsCreated ?? this.assetsCreated,
      holdingsUpdated: holdingsUpdated ?? this.holdingsUpdated,
      errors: errors ?? this.errors.map((e0) => e0).toList(),
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
    );
  }
}
