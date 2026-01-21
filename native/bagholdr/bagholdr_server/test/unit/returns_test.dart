import 'package:test/test.dart';
import 'package:bagholdr_server/src/utils/returns.dart';

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

    test('throws when all cash flows are positive', () {
      final transactions = [
        XirrTransaction(amount: 1000, when: DateTime(2023, 1, 1)),
        XirrTransaction(amount: 1100, when: DateTime(2024, 1, 1)),
      ];

      expect(() => xirr(transactions), throwsArgumentError);
    });

    test('throws when all cash flows are negative', () {
      final transactions = [
        XirrTransaction(amount: -1000, when: DateTime(2023, 1, 1)),
        XirrTransaction(amount: -500, when: DateTime(2024, 1, 1)),
      ];

      expect(() => xirr(transactions), throwsArgumentError);
    });

    test('throws when transactions list is empty', () {
      expect(() => xirr([]), throwsArgumentError);
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

  group('calculateTWR', () {
    test('calculates simple return with no cash flows', () {
      // Portfolio grows from 1000 to 1100 = 10% return
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          if (date == '2024-01-01') return 1100.0;
          return 1000.0;
        },
      );

      expect(result.isValid, isTrue);
      expect(result.twr, closeTo(0.10, 0.001));
      expect(result.cashFlowCount, equals(0));
    });

    test('neutralizes cash flow impact', () {
      // Portfolio starts at 1000, grows to 1050 (5%) by mid-year
      // User deposits 1000 on July 1 (total now 2050)
      // Portfolio grows to 2255 by year end (10% in second half)
      //
      // MWR would be lower because deposit was before a 10% gain
      // TWR = (1.05) * (1.10) - 1 = 15.5%
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: 1000),
        ],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          if (date == '2023-06-30') return 1050.0; // day before cash flow
          if (date == '2024-01-01') return 2255.0;
          return 1000.0;
        },
      );

      // TWR = (1.05) * (2255 / 2050) - 1 = 1.05 * 1.10 - 1 = 0.155
      expect(result.isValid, isTrue);
      expect(result.twr, closeTo(0.155, 0.01));
      expect(result.cashFlowCount, equals(1));
    });

    test('handles withdrawal correctly', () {
      // Portfolio starts at 2000, grows to 2100 (5%) by mid-year
      // User withdraws 1000 on July 1 (total now 1100)
      // Portfolio grows to 1210 by year end (10% in second half)
      //
      // TWR = (1.05) * (1.10) - 1 = 15.5%
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: -1000), // withdrawal
        ],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 2000.0;
          if (date == '2023-06-30') return 2100.0; // day before withdrawal
          if (date == '2024-01-01') return 1210.0;
          return 2000.0;
        },
      );

      // TWR = (2100/2000) * (1210/1100) - 1 = 1.05 * 1.10 - 1 = 0.155
      expect(result.isValid, isTrue);
      expect(result.twr, closeTo(0.155, 0.01));
      expect(result.cashFlowCount, equals(1));
    });

    test('handles multiple cash flows', () {
      // Multiple deposits throughout the year
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2023-12-31',
        cashFlows: [
          CashFlow(date: '2023-04-01', amount: 500),
          CashFlow(date: '2023-07-01', amount: 500),
          CashFlow(date: '2023-10-01', amount: 500),
        ],
        getPortfolioValueAtDate: (date) {
          // Simplified: 2% growth per quarter
          if (date == '2023-01-01') return 1000.0;
          if (date == '2023-03-31') return 1020.0; // +2%
          if (date == '2023-06-30') return 1550.4; // (1020+500)*1.02
          if (date == '2023-09-30') return 2091.4; // (1550.4+500)*1.02
          if (date == '2023-12-31') return 2643.2; // (2091.4+500)*1.02
          return 1000.0;
        },
      );

      // Each sub-period has 2% growth, so TWR = 1.02^4 - 1 ≈ 8.24%
      expect(result.isValid, isTrue);
      expect(result.twr, closeTo(0.0824, 0.01));
      expect(result.cashFlowCount, equals(3));
    });

    test('returns zero for zero start value with no cash flows', () {
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [],
        getPortfolioValueAtDate: (date) => 0.0,
      );

      // No capital and no flows - nothing to measure, return 0
      expect(result.isValid, isTrue);
      expect(result.twr, equals(0));
      expect(result.cashFlowCount, equals(0));
    });

    test('fails for zero start value with cash flows', () {
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: 1000),
        ],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 0.0;
          return 1000.0;
        },
      );

      // Can't measure return when starting from zero with contributions
      expect(result.isValid, isFalse);
      expect(result.twr, isNull);
      expect(result.error, contains('no starting capital'));
    });

    test('handles negative return', () {
      // Portfolio drops from 1000 to 900 = -10% return
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          if (date == '2024-01-01') return 900.0;
          return 1000.0;
        },
      );

      expect(result.isValid, isTrue);
      expect(result.twr, closeTo(-0.10, 0.001));
    });

    test('groups multiple cash flows on same day', () {
      // Two deposits on the same day should be treated as one
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: 500),
          CashFlow(date: '2023-07-01', amount: 500), // same day
        ],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          if (date == '2023-06-30') return 1050.0;
          if (date == '2024-01-01') return 2255.0;
          return 1000.0;
        },
      );

      // Should be same as single 1000 deposit
      expect(result.isValid, isTrue);
      expect(result.twr, closeTo(0.155, 0.01));
      expect(result.cashFlowCount, equals(2)); // counts individual flows
    });

    test('fails when portfolio fully withdrawn mid-period', () {
      // Portfolio starts at 1000, fully withdrawn mid-year, then restarted
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: -1000), // full withdrawal
          CashFlow(date: '2023-10-01', amount: 500), // restart
        ],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          if (date == '2023-06-30') return 1000.0;
          if (date == '2023-09-30') return 0.0; // zero after withdrawal
          if (date == '2024-01-01') return 550.0;
          return 0.0;
        },
      );

      // TWR undefined when portfolio hits zero
      expect(result.isValid, isFalse);
      expect(result.twr, isNull);
      expect(result.error, contains('withdrawn'));
    });

    test('handles weekend cash flow dates correctly', () {
      // Cash flow on Monday - should get Friday's value for "day before"
      final result = calculateTWR(
        startDate: '2023-01-02', // Monday
        endDate: '2023-01-16', // Monday
        cashFlows: [
          CashFlow(date: '2023-01-09', amount: 500), // Monday
        ],
        getPortfolioValueAtDate: (date) {
          // Callback handles non-trading days by returning last available
          if (date == '2023-01-02') return 1000.0;
          if (date == '2023-01-06') return 1020.0; // Friday before flow
          if (date == '2023-01-07') return 1020.0; // Saturday (uses Friday)
          if (date == '2023-01-08') return 1020.0; // Sunday (uses Friday)
          if (date == '2023-01-16') return 1570.0;
          return 1000.0;
        },
      );

      expect(result.isValid, isTrue);
      // First period: 1000 -> 1020 = 2%
      // After flow: 1020 + 500 = 1520
      // Second period: 1520 -> 1570 = 3.29%
      // TWR = 1.02 * 1.0329 - 1 ≈ 5.36%
      expect(result.twr, closeTo(0.0536, 0.01));
    });

    test('fails when callback returns non-finite value', () {
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          return double.nan; // Invalid value
        },
      );

      expect(result.isValid, isFalse);
      expect(result.twr, isNull);
      expect(result.error, contains('non-finite'));
    });

    test('fails when callback returns negative value', () {
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          return -500.0; // Invalid negative value
        },
      );

      expect(result.isValid, isFalse);
      expect(result.twr, isNull);
      expect(result.error, contains('negative'));
    });

    test('fails when market losses drop portfolio to zero', () {
      // Portfolio starts at 1000, market crash drops it to 0 before a deposit
      final result = calculateTWR(
        startDate: '2023-01-01',
        endDate: '2024-01-01',
        cashFlows: [
          CashFlow(date: '2023-07-01', amount: 1000),
        ],
        getPortfolioValueAtDate: (date) {
          if (date == '2023-01-01') return 1000.0;
          if (date == '2023-06-30') return 0.0; // Total loss before deposit
          if (date == '2024-01-01') return 1100.0;
          return 0.0;
        },
      );

      expect(result.isValid, isFalse);
      expect(result.twr, isNull);
      expect(result.error, contains('dropped to zero'));
    });
  });
}
