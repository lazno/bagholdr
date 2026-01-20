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
import 'chart_data_point.dart' as _i2;
import 'package:bagholdr_server/src/generated/protocol.dart' as _i3;

/// ChartDataResult - Chart data response
abstract class ChartDataResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ChartDataResult._({
    required this.dataPoints,
    required this.hasData,
  });

  factory ChartDataResult({
    required List<_i2.ChartDataPoint> dataPoints,
    required bool hasData,
  }) = _ChartDataResultImpl;

  factory ChartDataResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChartDataResult(
      dataPoints: _i3.Protocol().deserialize<List<_i2.ChartDataPoint>>(
        jsonSerialization['dataPoints'],
      ),
      hasData: jsonSerialization['hasData'] as bool,
    );
  }

  /// Data points for the chart
  List<_i2.ChartDataPoint> dataPoints;

  /// Whether there is data to display
  bool hasData;

  /// Returns a shallow copy of this [ChartDataResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChartDataResult copyWith({
    List<_i2.ChartDataPoint>? dataPoints,
    bool? hasData,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChartDataResult',
      'dataPoints': dataPoints.toJson(valueToJson: (v) => v.toJson()),
      'hasData': hasData,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChartDataResult',
      'dataPoints': dataPoints.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'hasData': hasData,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ChartDataResultImpl extends ChartDataResult {
  _ChartDataResultImpl({
    required List<_i2.ChartDataPoint> dataPoints,
    required bool hasData,
  }) : super._(
         dataPoints: dataPoints,
         hasData: hasData,
       );

  /// Returns a shallow copy of this [ChartDataResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChartDataResult copyWith({
    List<_i2.ChartDataPoint>? dataPoints,
    bool? hasData,
  }) {
    return ChartDataResult(
      dataPoints:
          dataPoints ?? this.dataPoints.map((e0) => e0.copyWith()).toList(),
      hasData: hasData ?? this.hasData,
    );
  }
}
