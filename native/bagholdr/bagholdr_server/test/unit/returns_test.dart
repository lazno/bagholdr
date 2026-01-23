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

  group('real data: XBAG.DE bond ETF (close vs adjClose)', () {
    // Real data from database:
    // Asset: XBAG.DE (Xtrackers ESG Global Aggregate Bond UCITS ETF)
    // Orders: All on 2025-09-18
    //   Buy 263 at 8974.35 EUR + commission 9.50
    //   Buy 234 at 7986.42 EUR + commission 9.50
    // Total: 497 units, cost 16979.77 EUR
    //
    // Key insight: This ETF distributes income, so Yahoo's adjClose is
    // retroactively adjusted DOWN for past distributions. But PriceCache
    // stores regularMarketPrice (unadjusted). Using adjClose for historical
    // comparison against current unadjusted price gives wrong results.
    //
    // At order date 2025-09-18:
    //   close = 34.112  (actual traded price)
    //   adjClose = 33.861  (adjusted for distributions since then)
    //
    // Latest (2026-01-22):
    //   close = 33.871
    //   adjClose = 33.871  (no adjustment needed for latest date)
    //
    // PriceCache priceEur = 33.871

    const double closeAtOrderDate = 34.112;
    const double adjCloseAtOrderDate = 33.861;
    const double currentPrice = 33.871;
    const int quantity = 497;
    const double totalCost = 16979.77;

    test('TWR using close gives correct negative return', () {
      // TWR = (currentPrice - historicalClose) / historicalClose
      final twr = (currentPrice - closeAtOrderDate) / closeAtOrderDate;

      // Expected: price dropped from 34.112 to 33.871 = -0.71%
      expect(twr, closeTo(-0.0071, 0.001));
      expect(twr, isNegative);
    });

    test('TWR using adjClose gives wrong positive return', () {
      // This demonstrates the bug: adjClose ≈ current price due to
      // distribution adjustments, so TWR appears near zero or positive
      final twrWrong = (currentPrice - adjCloseAtOrderDate) / adjCloseAtOrderDate;

      // Wrong: shows +0.03% when actual return is -0.71%
      expect(twrWrong, closeTo(0.0003, 0.001));
      expect(twrWrong, isNonNegative); // Incorrectly non-negative!
    });

    test('MWR using close gives correct negative return', () {
      final startValue = quantity * closeAtOrderDate; // 16953.66
      final endValue = quantity * currentPrice; // 16833.89

      final mwrResult = calculateMWR(
        startDate: '2025-09-18',
        endDate: '2026-01-22',
        startValue: startValue,
        endValue: endValue,
        cashFlows: [], // All orders on same day = no intermediate flows
      );

      // Period is < 1 year, so compounded return is the simple return
      expect(mwrResult.compoundedReturn, closeTo(-0.0071, 0.001));
      expect(mwrResult.compoundedReturn, isNegative);
    });

    test('MWR using adjClose gives wrong near-zero return', () {
      final startValue = quantity * adjCloseAtOrderDate; // 16829.12
      final endValue = quantity * currentPrice; // 16833.89

      final mwrResult = calculateMWR(
        startDate: '2025-09-18',
        endDate: '2026-01-22',
        startValue: startValue,
        endValue: endValue,
        cashFlows: [],
      );

      // Wrong: shows ~+0.03% when actual return is -0.71%
      expect(mwrResult.compoundedReturn, closeTo(0.0003, 0.001));
      expect(mwrResult.compoundedReturn, isNonNegative); // Incorrectly non-negative!
    });

    test('cost-basis return matches close-based TWR direction', () {
      final currentValue = quantity * currentPrice; // 16833.89
      final costReturn = (currentValue - totalCost) / totalCost;

      // Cost-basis return should also be negative (price dropped + commissions)
      expect(costReturn, isNegative);
      expect(costReturn, closeTo(-0.0086, 0.001)); // -0.86% (includes commissions)

      // The close-based TWR (-0.71%) should have the same sign as cost return
      final twr = (currentPrice - closeAtOrderDate) / closeAtOrderDate;
      expect(twr.isNegative, equals(costReturn.isNegative));
    });
  });

  group('calculateTotalReturn', () {
    test('IREN ALL period: ~93% total return', () {
      // Real IREN data:
      // Buys: 436.41 + 268.02 + 842.54 = 1546.97
      // Fees: 7.65 + 7.65 + 7.68 + 7.68 + 7.63 = 38.29
      // Sells: 323.26 + 291.11 = 614.37
      // Current value: 55 * 44.473 = 2446.015
      //
      // totalReturn = (2446 + 614.37) / (0 + 1546.97 + 38.29) - 1 = 93%

      final orders = [
        (quantity: 28.0, totalEur: 436.41, date: '2025-07-23'),
        (quantity: 0.0, totalEur: 7.65, date: '2025-07-23'), // fee
        (quantity: 17.0, totalEur: 268.02, date: '2025-07-24'),
        (quantity: 0.0, totalEur: 7.65, date: '2025-07-24'), // fee
        (quantity: -8.0, totalEur: 323.26, date: '2025-10-02'),
        (quantity: 0.0, totalEur: 7.68, date: '2025-10-02'), // fee
        (quantity: -6.0, totalEur: 291.11, date: '2025-10-06'),
        (quantity: 0.0, totalEur: 7.68, date: '2025-10-06'), // fee
        (quantity: 24.0, totalEur: 842.54, date: '2025-12-23'),
        (quantity: 0.0, totalEur: 7.63, date: '2025-12-23'), // fee
      ];

      final result = calculateTotalReturn(
        startValue: 0, // ALL period
        endValue: 2446.015,
        orders: orders,
        periodStartDate: '1900-01-01',
        periodEndDate: '2026-01-23',
      );

      expect(result, isNotNull);
      // (2446.015 + 614.37) / (0 + 1546.97 + 38.29) - 1
      // = 3060.385 / 1585.26 - 1 = 0.930
      expect(result!, closeTo(0.93, 0.01));
    });

    test('sub-period with starting position only: simple price return', () {
      // Start with position worth 1000, no orders during period, ends at 1200
      final result = calculateTotalReturn(
        startValue: 1000,
        endValue: 1200,
        orders: [],
        periodStartDate: '2025-01-01',
        periodEndDate: '2025-06-01',
      );

      expect(result, isNotNull);
      // (1200 + 0) / (1000 + 0 + 0) - 1 = 0.20
      expect(result!, closeTo(0.20, 0.001));
    });

    test('sub-period with starting position + buys: blended return', () {
      // Start with position worth 1000, buy 500 more during period, ends at 1800
      final orders = [
        (quantity: 10.0, totalEur: 500.0, date: '2025-03-01'),
      ];

      final result = calculateTotalReturn(
        startValue: 1000,
        endValue: 1800,
        orders: orders,
        periodStartDate: '2025-01-01',
        periodEndDate: '2025-06-01',
      );

      expect(result, isNotNull);
      // (1800 + 0) / (1000 + 500 + 0) - 1 = 0.20
      expect(result!, closeTo(0.20, 0.001));
    });

    test('returns null when no cost basis (denominator = 0)', () {
      final result = calculateTotalReturn(
        startValue: 0,
        endValue: 1000,
        orders: [],
        periodStartDate: '2025-01-01',
        periodEndDate: '2025-06-01',
      );

      expect(result, isNull);
    });

    test('negative return case', () {
      // Bought at 1000, now worth 800 = -20% return
      final orders = [
        (quantity: 10.0, totalEur: 1000.0, date: '2025-02-01'),
      ];

      final result = calculateTotalReturn(
        startValue: 0,
        endValue: 800,
        orders: orders,
        periodStartDate: '2025-01-01',
        periodEndDate: '2025-06-01',
      );

      expect(result, isNotNull);
      // (800 + 0) / (0 + 1000 + 0) - 1 = -0.20
      expect(result!, closeTo(-0.20, 0.001));
    });

    test('orders outside period are excluded', () {
      final orders = [
        (quantity: 10.0, totalEur: 500.0, date: '2024-12-01'), // before period
        (quantity: 5.0, totalEur: 300.0, date: '2025-03-01'), // in period
        (quantity: 5.0, totalEur: 400.0, date: '2025-07-01'), // after period
      ];

      final result = calculateTotalReturn(
        startValue: 1000,
        endValue: 1500,
        orders: orders,
        periodStartDate: '2025-01-01',
        periodEndDate: '2025-06-01',
      );

      expect(result, isNotNull);
      // Only the 300 buy is in period
      // (1500 + 0) / (1000 + 300 + 0) - 1 = 0.1538
      expect(result!, closeTo(0.1538, 0.001));
    });

    test('fees counted as costs in denominator', () {
      final orders = [
        (quantity: 10.0, totalEur: 1000.0, date: '2025-02-01'),
        (quantity: 0.0, totalEur: 10.0, date: '2025-02-01'), // fee
      ];

      final result = calculateTotalReturn(
        startValue: 0,
        endValue: 1100,
        orders: orders,
        periodStartDate: '2025-01-01',
        periodEndDate: '2025-06-01',
      );

      expect(result, isNotNull);
      // (1100 + 0) / (0 + 1000 + 10) - 1 = 0.0891
      expect(result!, closeTo(0.0891, 0.001));
    });

    test('sells added to numerator', () {
      // Buy 1000, sell some for 300, remaining worth 900
      final orders = [
        (quantity: 10.0, totalEur: 1000.0, date: '2025-02-01'),
        (quantity: -3.0, totalEur: 300.0, date: '2025-04-01'),
      ];

      final result = calculateTotalReturn(
        startValue: 0,
        endValue: 900,
        orders: orders,
        periodStartDate: '2025-01-01',
        periodEndDate: '2025-06-01',
      );

      expect(result, isNotNull);
      // (900 + 300) / (0 + 1000 + 0) - 1 = 0.20
      expect(result!, closeTo(0.20, 0.001));
    });
  });

  group('real data: IREN crypto mining stock (multi-trade MWR)', () {
    // Real data from database for IREN (AU0000185993)
    // Orders:
    //   2025-07-23: Buy 28, totalEur=436.41, fee=7.65
    //   2025-07-24: Buy 17, totalEur=268.02, fee=7.65
    //   2025-10-02: Sell 8, totalEur=323.26, fee=7.68
    //   2025-10-06: Sell 6, totalEur=291.11, fee=7.68
    //   2025-12-23: Buy 24, totalEur=842.54, fee=7.63
    // Current position: 55 shares
    //
    // Daily prices (USD, close == adjClose for this stock):
    //   2025-07-23: 18.99
    //   2025-07-24: 18.14
    //   2025-10-02: 47.02
    //   2025-10-06: 57.75
    //   2025-12-23: 42.07
    //   2026-01-22 (latest): 52.26
    //
    // PriceCache: priceNative=52.26 USD, priceEur=44.473

    const closeAtFirstBuy = 18.99; // USD close on 2025-07-23
    const currentPriceNative = 52.26; // USD from price_cache
    const currentPriceEur = 44.473; // EUR from price_cache
    const derivedFxRate = currentPriceEur / currentPriceNative; // ~0.851
    const historicalPriceEur = closeAtFirstBuy * derivedFxRate; // ~16.16
    const positionAtStart = 28.0; // shares bought on first order date
    const currentQuantity = 55.0;

    test('TWR is ~175% (pure price return)', () {
      // TWR = (currentPrice - startPrice) / startPrice
      final twr = (currentPriceEur - historicalPriceEur) / historicalPriceEur;

      // Stock went from $18.99 to $52.26 = 175% return
      // FX cancels out since both use same derivedFxRate
      expect(twr, closeTo(1.752, 0.01));

      // Verify FX cancels: TWR in USD = same result
      final twrUsd =
          (currentPriceNative - closeAtFirstBuy) / closeAtFirstBuy;
      expect(twrUsd, closeTo(twr, 0.001));
    });

    test('MWR is ~330% (profit relative to starting value)', () {
      final startValue = positionAtStart * historicalPriceEur; // 28 * 16.16
      final endValue = currentQuantity * currentPriceEur; // 55 * 44.473

      // Cash flows AFTER start date (fee orders excluded, qty==0)
      final cashFlows = [
        CashFlow(date: '2025-07-24', amount: 268.02), // Buy 17
        CashFlow(date: '2025-10-02', amount: -323.26), // Sell 8
        CashFlow(date: '2025-10-06', amount: -291.11), // Sell 6
        CashFlow(date: '2025-12-23', amount: 842.54), // Buy 24
      ];

      final mwrResult = calculateMWR(
        startDate: '2025-07-23',
        endDate: '2026-01-23',
        startValue: startValue,
        endValue: endValue,
        cashFlows: cashFlows,
      );

      // Period < 1 year, so we use compoundedReturn
      expect(mwrResult.periodYears, lessThan(1.0));

      // Profit = endValue - startValue - netCashFlow
      //        = 2446 - 452 - 496 = 1497
      // MWR ≈ profit / startValue = 1497 / 452 = 331%
      expect(mwrResult.compoundedReturn, closeTo(3.31, 0.1));
    });

    test('MWR > TWR because capital added during uptrend', () {
      final twr = (currentPriceEur - historicalPriceEur) / historicalPriceEur;

      final startValue = positionAtStart * historicalPriceEur;
      final endValue = currentQuantity * currentPriceEur;

      final mwrResult = calculateMWR(
        startDate: '2025-07-23',
        endDate: '2026-01-23',
        startValue: startValue,
        endValue: endValue,
        cashFlows: [
          CashFlow(date: '2025-07-24', amount: 268.02),
          CashFlow(date: '2025-10-02', amount: -323.26),
          CashFlow(date: '2025-10-06', amount: -291.11),
          CashFlow(date: '2025-12-23', amount: 842.54),
        ],
      );

      // MWR > TWR because user added capital before major price increases
      // (bought early cheap, added more before growth, sold at peaks)
      expect(mwrResult.compoundedReturn, greaterThan(twr));
    });

    test('cost-basis return is much lower (~80%)', () {
      // Average cost method from the code:
      // Buy 28: qty=28, cost=436.41+7.65=444.06
      // Buy 17: qty=45, cost=444.06+268.02+7.65=719.73
      // Sell 8: avgCost=719.73/45=15.994, cost=719.73-127.95=591.78, qty=37
      // +fees: cost=591.78+7.68+7.68=607.14
      // Sell 6: avgCost=607.14/37=16.409, cost=607.14-98.45=508.69, qty=31
      // Buy 24: qty=55, cost=508.69+842.54+7.63=1358.86
      const costBasis = 1358.86;
      final currentValue = currentQuantity * currentPriceEur; // ~2446

      final costReturn = (currentValue - costBasis) / costBasis;

      // Cost-basis return is ~80%, much lower than TWR (175%) or MWR (330%)
      // because it includes all invested capital in the denominator
      expect(costReturn, closeTo(0.80, 0.02));
      expect(costReturn, lessThan(1.752)); // Less than TWR
    });
  });
}
