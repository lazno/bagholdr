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
import 'return_period.dart' as _i2;

/// PeriodReturn - Return calculation for a specific time period
abstract class PeriodReturn
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PeriodReturn._({
    required this.period,
    required this.currentValue,
    required this.startValue,
    required this.absoluteReturn,
    required this.compoundedReturn,
    required this.annualizedReturn,
    required this.periodYears,
    required this.comparisonDate,
    required this.netCashFlow,
    required this.cashFlowCount,
  });

  factory PeriodReturn({
    required _i2.ReturnPeriod period,
    required double currentValue,
    required double startValue,
    required double absoluteReturn,
    required double compoundedReturn,
    required double annualizedReturn,
    required double periodYears,
    required String comparisonDate,
    required double netCashFlow,
    required int cashFlowCount,
  }) = _PeriodReturnImpl;

  factory PeriodReturn.fromJson(Map<String, dynamic> jsonSerialization) {
    return PeriodReturn(
      period: _i2.ReturnPeriod.fromJson(
        (jsonSerialization['period'] as String),
      ),
      currentValue: (jsonSerialization['currentValue'] as num).toDouble(),
      startValue: (jsonSerialization['startValue'] as num).toDouble(),
      absoluteReturn: (jsonSerialization['absoluteReturn'] as num).toDouble(),
      compoundedReturn: (jsonSerialization['compoundedReturn'] as num)
          .toDouble(),
      annualizedReturn: (jsonSerialization['annualizedReturn'] as num)
          .toDouble(),
      periodYears: (jsonSerialization['periodYears'] as num).toDouble(),
      comparisonDate: jsonSerialization['comparisonDate'] as String,
      netCashFlow: (jsonSerialization['netCashFlow'] as num).toDouble(),
      cashFlowCount: jsonSerialization['cashFlowCount'] as int,
    );
  }

  /// The period this return covers
  _i2.ReturnPeriod period;

  /// Current portfolio value
  double currentValue;

  /// Portfolio value at period start
  double startValue;

  /// Absolute return (profit) in EUR
  double absoluteReturn;

  /// Total percentage return over period (MWR)
  double compoundedReturn;

  /// Annualized percentage return (p.a.)
  double annualizedReturn;

  /// Length of period in years
  double periodYears;

  /// Comparison date (period start)
  String comparisonDate;

  /// Net cash flows during period (deposits - withdrawals)
  double netCashFlow;

  /// Number of cash flow events in period
  int cashFlowCount;

  /// Returns a shallow copy of this [PeriodReturn]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PeriodReturn copyWith({
    _i2.ReturnPeriod? period,
    double? currentValue,
    double? startValue,
    double? absoluteReturn,
    double? compoundedReturn,
    double? annualizedReturn,
    double? periodYears,
    String? comparisonDate,
    double? netCashFlow,
    int? cashFlowCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PeriodReturn',
      'period': period.toJson(),
      'currentValue': currentValue,
      'startValue': startValue,
      'absoluteReturn': absoluteReturn,
      'compoundedReturn': compoundedReturn,
      'annualizedReturn': annualizedReturn,
      'periodYears': periodYears,
      'comparisonDate': comparisonDate,
      'netCashFlow': netCashFlow,
      'cashFlowCount': cashFlowCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PeriodReturn',
      'period': period.toJson(),
      'currentValue': currentValue,
      'startValue': startValue,
      'absoluteReturn': absoluteReturn,
      'compoundedReturn': compoundedReturn,
      'annualizedReturn': annualizedReturn,
      'periodYears': periodYears,
      'comparisonDate': comparisonDate,
      'netCashFlow': netCashFlow,
      'cashFlowCount': cashFlowCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PeriodReturnImpl extends PeriodReturn {
  _PeriodReturnImpl({
    required _i2.ReturnPeriod period,
    required double currentValue,
    required double startValue,
    required double absoluteReturn,
    required double compoundedReturn,
    required double annualizedReturn,
    required double periodYears,
    required String comparisonDate,
    required double netCashFlow,
    required int cashFlowCount,
  }) : super._(
         period: period,
         currentValue: currentValue,
         startValue: startValue,
         absoluteReturn: absoluteReturn,
         compoundedReturn: compoundedReturn,
         annualizedReturn: annualizedReturn,
         periodYears: periodYears,
         comparisonDate: comparisonDate,
         netCashFlow: netCashFlow,
         cashFlowCount: cashFlowCount,
       );

  /// Returns a shallow copy of this [PeriodReturn]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PeriodReturn copyWith({
    _i2.ReturnPeriod? period,
    double? currentValue,
    double? startValue,
    double? absoluteReturn,
    double? compoundedReturn,
    double? annualizedReturn,
    double? periodYears,
    String? comparisonDate,
    double? netCashFlow,
    int? cashFlowCount,
  }) {
    return PeriodReturn(
      period: period ?? this.period,
      currentValue: currentValue ?? this.currentValue,
      startValue: startValue ?? this.startValue,
      absoluteReturn: absoluteReturn ?? this.absoluteReturn,
      compoundedReturn: compoundedReturn ?? this.compoundedReturn,
      annualizedReturn: annualizedReturn ?? this.annualizedReturn,
      periodYears: periodYears ?? this.periodYears,
      comparisonDate: comparisonDate ?? this.comparisonDate,
      netCashFlow: netCashFlow ?? this.netCashFlow,
      cashFlowCount: cashFlowCount ?? this.cashFlowCount,
    );
  }
}
