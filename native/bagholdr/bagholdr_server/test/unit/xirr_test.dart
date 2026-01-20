import 'package:test/test.dart';
import 'package:bagholdr_server/src/utils/xirr.dart';

void main() {
  group('xirr', () {
    test('calculates simple investment return', () {
      // Invest $1000, get back $1100 after 1 year = 10% return
      final transactions = [
        XirrTransaction(amount: -1000, when: DateTime(2023, 1, 1)),
        XirrTransaction(amount: 1100, when: DateTime(2024, 1, 1)),
      ];

      final result = xirr(transactions);
      expect(result, closeTo(0.10, 0.001));
    });

    test('calculates return with intermediate cash flows', () {
      // Invest $1000, add $500 after 6 months, get $1800 after 1 year
      final transactions = [
        XirrTransaction(amount: -1000, when: DateTime(2023, 1, 1)),
        XirrTransaction(amount: -500, when: DateTime(2023, 7, 1)),
        XirrTransaction(amount: 1800, when: DateTime(2024, 1, 1)),
      ];

      final result = xirr(transactions);
      // The return should account for the timing of cash flows
      expect(result, greaterThan(0.1));
      expect(result, lessThan(0.3));
    });

    test('calculates negative return', () {
      // Invest $1000, get back $900 after 1 year = -10% return
      final transactions = [
        XirrTransaction(amount: -1000, when: DateTime(2023, 1, 1)),
        XirrTransaction(amount: 900, when: DateTime(2024, 1, 1)),
      ];

      final result = xirr(transactions);
      expect(result, closeTo(-0.10, 0.001));
    });

    test('handles break-even', () {
      // Invest $1000, get back $1000 after 1 year = 0% return
      final transactions = [
        XirrTransaction(amount: -1000, when: DateTime(2023, 1, 1)),
        XirrTransaction(amount: 1000, when: DateTime(2024, 1, 1)),
      ];

      final result = xirr(transactions);
      expect(result, closeTo(0.0, 0.001));
    });

    test('handles short period', () {
      // Invest $1000, get back $1010 after 1 month
      final transactions = [
        XirrTransaction(amount: -1000, when: DateTime(2023, 1, 1)),
        XirrTransaction(amount: 1010, when: DateTime(2023, 2, 1)),
      ];

      final result = xirr(transactions);
      // Should be annualized to a higher rate
      expect(result, greaterThan(0.10));
    });
  });

  group('calculateMWR', () {
    test('calculates MWR with no cash flows', () {
      final result = calculateMWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        startValue: 1000,
        endValue: 1100,
        cashFlows: [],
      );

      expect(result.annualizedReturn, closeTo(0.10, 0.001));
      expect(result.compoundedReturn, closeTo(0.10, 0.001));
      expect(result.netCashFlow, equals(0));
      expect(result.cashFlowCount, equals(0));
      expect(result.periodYears, closeTo(1.0, 0.01));
    });

    test('calculates MWR with deposits', () {
      final result = calculateMWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        startValue: 1000,
        endValue: 2200,
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: 1000), // deposit
        ],
      );

      expect(result.netCashFlow, equals(1000));
      expect(result.cashFlowCount, equals(1));
      // The return should be positive but account for the deposit
      expect(result.annualizedReturn, greaterThan(0));
    });

    test('calculates MWR with withdrawals', () {
      final result = calculateMWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        startValue: 2000,
        endValue: 1100,
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: -1000), // withdrawal
        ],
      );

      expect(result.netCashFlow, equals(-1000));
      expect(result.cashFlowCount, equals(1));
    });

    test('handles short period', () {
      final result = calculateMWR(
        startDate: '2023-01-01',
        endDate: '2023-01-02',
        startValue: 1000,
        endValue: 1010,
        cashFlows: [],
      );

      // Very short period - should just use simple return
      expect(result.periodYears, lessThan(0.01));
    });

    test('handles zero start value', () {
      final result = calculateMWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        startValue: 0,
        endValue: 1100,
        cashFlows: [],
      );

      expect(result.annualizedReturn, equals(0));
      expect(result.compoundedReturn, equals(0));
    });
  });

  group('formatPeriodLabel', () {
    test('formats days', () {
      expect(formatPeriodLabel(1 / 365.25), equals('1d'));
      expect(formatPeriodLabel(5 / 365.25), equals('5d'));
    });

    test('formats weeks', () {
      expect(formatPeriodLabel(7 / 365.25), equals('1w'));
      expect(formatPeriodLabel(14 / 365.25), equals('2w'));
    });

    test('formats months', () {
      expect(formatPeriodLabel(30 / 365.25), equals('1mo'));
      expect(formatPeriodLabel(90 / 365.25), equals('3mo'));
      expect(formatPeriodLabel(180 / 365.25), equals('6mo'));
    });

    test('formats years', () {
      expect(formatPeriodLabel(1.0), equals('1.0y'));
      expect(formatPeriodLabel(1.5), equals('1.5y'));
      expect(formatPeriodLabel(2.0), equals('2.0y'));
    });
  });
}
