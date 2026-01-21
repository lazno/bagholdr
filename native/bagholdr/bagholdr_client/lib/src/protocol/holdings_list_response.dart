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
import 'holding_response.dart' as _i2;
import 'package:bagholdr_client/src/protocol/protocol.dart' as _i3;

/// HoldingsListResponse - Paginated list of holdings
abstract class HoldingsListResponse implements _i1.SerializableModel {
  HoldingsListResponse._({
    required this.holdings,
    required this.totalCount,
    required this.filteredCount,
    required this.totalValue,
  });

  factory HoldingsListResponse({
    required List<_i2.HoldingResponse> holdings,
    required int totalCount,
    required int filteredCount,
    required double totalValue,
  }) = _HoldingsListResponseImpl;

  factory HoldingsListResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HoldingsListResponse(
      holdings: _i3.Protocol().deserialize<List<_i2.HoldingResponse>>(
        jsonSerialization['holdings'],
      ),
      totalCount: jsonSerialization['totalCount'] as int,
      filteredCount: jsonSerialization['filteredCount'] as int,
      totalValue: (jsonSerialization['totalValue'] as num).toDouble(),
    );
  }

  /// List of holdings
  List<_i2.HoldingResponse> holdings;

  /// Total holdings count (before filtering)
  int totalCount;

  /// Count after search/sleeve filter
  int filteredCount;

  /// Total portfolio value (for weight calculation context)
  double totalValue;

  /// Returns a shallow copy of this [HoldingsListResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HoldingsListResponse copyWith({
    List<_i2.HoldingResponse>? holdings,
    int? totalCount,
    int? filteredCount,
    double? totalValue,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HoldingsListResponse',
      'holdings': holdings.toJson(valueToJson: (v) => v.toJson()),
      'totalCount': totalCount,
      'filteredCount': filteredCount,
      'totalValue': totalValue,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _HoldingsListResponseImpl extends HoldingsListResponse {
  _HoldingsListResponseImpl({
    required List<_i2.HoldingResponse> holdings,
    required int totalCount,
    required int filteredCount,
    required double totalValue,
  }) : super._(
         holdings: holdings,
         totalCount: totalCount,
         filteredCount: filteredCount,
         totalValue: totalValue,
       );

  /// Returns a shallow copy of this [HoldingsListResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HoldingsListResponse copyWith({
    List<_i2.HoldingResponse>? holdings,
    int? totalCount,
    int? filteredCount,
    double? totalValue,
  }) {
    return HoldingsListResponse(
      holdings: holdings ?? this.holdings.map((e0) => e0.copyWith()).toList(),
      totalCount: totalCount ?? this.totalCount,
      filteredCount: filteredCount ?? this.filteredCount,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}
