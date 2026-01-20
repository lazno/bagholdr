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

/// ChartDataPoint - Single data point for portfolio chart
abstract class ChartDataPoint
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ChartDataPoint._({
    required this.date,
    required this.investedValue,
    required this.costBasis,
  });

  factory ChartDataPoint({
    required String date,
    required double investedValue,
    required double costBasis,
  }) = _ChartDataPointImpl;

  factory ChartDataPoint.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChartDataPoint(
      date: jsonSerialization['date'] as String,
      investedValue: (jsonSerialization['investedValue'] as num).toDouble(),
      costBasis: (jsonSerialization['costBasis'] as num).toDouble(),
    );
  }

  /// Date in YYYY-MM-DD format
  String date;

  /// Portfolio invested value on this date
  double investedValue;

  /// Portfolio cost basis on this date
  double costBasis;

  /// Returns a shallow copy of this [ChartDataPoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChartDataPoint copyWith({
    String? date,
    double? investedValue,
    double? costBasis,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChartDataPoint',
      'date': date,
      'investedValue': investedValue,
      'costBasis': costBasis,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChartDataPoint',
      'date': date,
      'investedValue': investedValue,
      'costBasis': costBasis,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ChartDataPointImpl extends ChartDataPoint {
  _ChartDataPointImpl({
    required String date,
    required double investedValue,
    required double costBasis,
  }) : super._(
         date: date,
         investedValue: investedValue,
         costBasis: costBasis,
       );

  /// Returns a shallow copy of this [ChartDataPoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChartDataPoint copyWith({
    String? date,
    double? investedValue,
    double? costBasis,
  }) {
    return ChartDataPoint(
      date: date ?? this.date,
      investedValue: investedValue ?? this.investedValue,
      costBasis: costBasis ?? this.costBasis,
    );
  }
}
