import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';
import 'package:bagholdr_server/src/services/asset_returns_calculator.dart';

void main() {
  final uuid = Uuid();

  /// Helper to create a test asset
  Asset createAsset({
    String? yahooSymbol,
    String ticker = 'TEST',
    String currency = 'EUR',
  }) {
    return Asset(
      id: UuidValue.fromString(uuid.v4()),
      isin: 'TEST123456789',
      ticker: ticker,
      name: 'Test Asset',
      assetType: AssetType.etf,
      currency: currency,
      yahooSymbol: yahooSymbol,
      archived: false,
    );
  }

  /// Helper to create a test holding
  Holding createHolding({
    required UuidValue assetId,
    required double quantity,
    required double totalCostEur,
  }) {
    return Holding(
      id: UuidValue.fromString(uuid.v4()),
      assetId: assetId,
      quantity: quantity,
      totalCostEur: totalCostEur,
    );
  }

  /// Helper to create a buy order
  Order createBuyOrder({
    required UuidValue assetId,
    required DateTime orderDate,
    required double quantity,
    required double totalEur,
    double priceNative = 0,
    double totalNative = 0,
    String currency = 'EUR',
  }) {
    return Order(
      id: UuidValue.fromString(uuid.v4()),
      assetId: assetId,
      orderDate: orderDate,
      quantity: quantity,
      priceNative: priceNative != 0 ? priceNative : totalEur / quantity,
      totalNative: totalNative != 0 ? totalNative : totalEur,
      totalEur: totalEur,
      currency: currency,
      importedAt: DateTime.now(),
    );
  }

  /// Helper to create a sell order
  Order createSellOrder({
    required UuidValue assetId,
    required DateTime orderDate,
    required double quantity,
    required double totalEur,
  }) {
    return Order(
      id: UuidValue.fromString(uuid.v4()),
      assetId: assetId,
      orderDate: orderDate,
      quantity: -quantity, // Sell orders have negative quantity
      priceNative: totalEur / quantity,
      totalNative: totalEur,
      totalEur: totalEur,
      currency: 'EUR',
      importedAt: DateTime.now(),
    );
  }

  group('AssetReturnsCalculator', () {
    group('Period P/L calculation', () {
      test('calculates period P/L correctly when price goes up', () {
        // Setup: Asset bought at €100, now worth €120
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000, // €100 per share
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26', // 1 month ago
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0}, // Current price €120
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0}, // Price 1 month ago: €110
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Period P/L should be: currentValue - startValue
        // = (10 * €120) - (10 * €110) = €1200 - €1100 = €100
        expect(result.periodPL, equals(100.0));
        expect(result.value, equals(1200.0));
        expect(result.costBasis, equals(1000.0));
      });

      test('calculates period P/L for short holding (acquired during period)', () {
        // Setup: Asset bought mid-period at €100, now worth €120
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 12, 15), // Bought after period start
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26', // Period starts before buy date
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {
            'TEST.MI': {
              '2024-11-26': 95.0, // Price at period start
              '2024-12-15': 100.0, // Price when bought
            },
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Short holding: effective start is buy date
        // Period P/L = currentValue - (positionAtBuy * priceAtBuy) - buyAmount
        // Since it's acquired at period start (effectively), startValue=0
        // Period P/L = 1200 - 0 - 1000 = €200
        expect(result.periodPL, equals(200.0));
      });

      test('calculates period P/L with additional buys during period', () {
        // Setup: Asset initially bought, then more bought during period
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 20, // 10 + 10
          totalCostEur: 2200, // 1000 + 1200
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 12, 10),
            quantity: 10,
            totalEur: 1200, // €120/share
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 130.0}, // Current price €130
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0}, // Price at period start
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Period P/L = currentValue - startValue + netCashFlows
        // currentValue = 20 * €130 = €2600
        // startValue = 10 * €110 = €1100
        // netCashFlows = -€1200 (buy during period)
        // Period P/L = €2600 - €1100 - €1200 = €300
        expect(result.periodPL, equals(300.0));
      });

      test('calculates period P/L with sells during period', () {
        // Setup: Some shares sold during the period
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 5, // Started with 10, sold 5
          totalCostEur: 500,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 12, 10),
            quantity: 5,
            totalEur: 600, // €120/share (profit)
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 130.0}, // Current price €130
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0}, // Price at period start
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Period P/L = currentValue - startValue + netCashFlows
        // currentValue = 5 * €130 = €650
        // startValue = 10 * €110 = €1100
        // netCashFlows = +€600 (sell proceeds)
        // Period P/L = €650 - €1100 + €600 = €150
        expect(result.periodPL, equals(150.0));
      });

      test('calculates period P/L when no historical price available', () {
        // Setup: No historical price data
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {}, // No historical prices
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Without historical price, startValue = 0
        // Period P/L = currentValue - 0 + 0 = €1200
        expect(result.periodPL, equals(1200.0));
      });
    });

    group('Cost basis calculation', () {
      test('calculates cost basis with buys only', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 20,
          totalCostEur: 2200,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 6, 1),
            quantity: 10,
            totalEur: 1200,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 100.0},
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        expect(result.costBasis, equals(2200.0));
      });

      test('calculates cost basis with sells (average cost)', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 5,
          totalCostEur: 500,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 6, 1),
            quantity: 5,
            totalEur: 600, // Sold for €120/share
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 100.0},
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // After selling 5 shares at avg cost €100, remaining cost basis = €500
        expect(result.costBasis, equals(500.0));
      });
    });

    group('MWR calculation', () {
      test('calculates MWR when no historical price available', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {}, // No historical data
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Simple return: (1200 - 1000) / 1000 = 0.2 = 20%
        expect(result.mwr, closeTo(0.2, 0.01));
      });

      test('calculates MWR with historical price', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0},
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // 1-month return: (1200 - 1100) / 1100 = 0.0909 = ~9.09%
        expect(result.mwr, closeTo(0.0909, 0.01));
      });
    });

    group('TWR calculation', () {
      test('returns null when no historical price available', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {}, // No historical data
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        expect(result.twr, isNull);
      });

      test('calculates TWR with historical price (simple price return)', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 100.0},
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // TWR = (120 - 100) / 100 = 0.2 = 20%
        expect(result.twr, closeTo(0.2, 0.001));
      });
    });

    group('Total Return calculation', () {
      test('calculates total return for ALL period', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Total return = (endValue + sellProceeds) / (startValue + buyCosts) - 1
        // = (1200 + 0) / (0 + 1000) - 1 = 0.2 = 20%
        expect(result.totalReturn, closeTo(0.2, 0.001));
      });
    });

    group('FX conversion', () {
      test('applies derived FX rate to historical prices', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI', currency: 'USD');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0}, // Price already in EUR
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 100.0}, // Historical price in native currency
          },
          derivedFxRateMap: {'TEST.MI': 0.95}, // USD -> EUR rate
          fxRateMap: {},
        );

        // Historical price in EUR = 100 * 0.95 = 95
        // TWR = (120 - 95) / 95 = 0.263...
        expect(result.twr, closeTo(0.263, 0.01));
      });

      test('falls back to FX rate map when no derived rate', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI', currency: 'USD');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 100.0},
          },
          derivedFxRateMap: {}, // No derived rate
          fxRateMap: {'USDEUR': 0.92}, // Fallback FX rate
        );

        // Historical price in EUR = 100 * 0.92 = 92
        // TWR = (120 - 92) / 92 = 0.304...
        expect(result.twr, closeTo(0.304, 0.01));
      });
    });

    group('Unrealized P/L calculation', () {
      test('calculates unrealized P/L for ALL period as value minus cost basis', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0}, // Current price €120
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Unrealized P/L = current value - cost basis = €1200 - €1000 = €200
        expect(result.unrealizedPL, equals(200.0));
        // Percentage = €200 / €1000 = 20%
        expect(result.unrealizedPLPct, closeTo(0.2, 0.001));
      });

      test('calculates unrealized P/L for sub-period using historical price', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0}, // Current price €120
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0}, // Price 1 month ago
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Unrealized P/L = current value - reference value
        // = €1200 - (10 * €110) = €1200 - €1100 = €100
        expect(result.unrealizedPL, equals(100.0));
        // Percentage = €100 / €1100 = ~9.09%
        expect(result.unrealizedPLPct, closeTo(0.0909, 0.01));
      });

      test('calculates unrealized P/L with purchases during period', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 20,
          totalCostEur: 2200,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 12, 10),
            quantity: 10,
            totalEur: 1200, // €120/share bought during period
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 130.0}, // Current price €130
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0},
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Reference value = (10 * €110) + €1200 = €1100 + €1200 = €2300
        // Current value = 20 * €130 = €2600
        // Unrealized P/L = €2600 - €2300 = €300
        expect(result.unrealizedPL, equals(300.0));
      });

      test('unrealized P/L excludes realized gains from sales', () {
        // This tests that unrealized P/L only considers current holdings (Kursgewinn)
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 5, // Started with 10, sold 5
          totalCostEur: 500,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 12, 10),
            quantity: 5,
            totalEur: 650, // €130/share (profit)
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 130.0}, // Current price €130
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0},
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Unrealized P/L (Kursgewinn) = price gain on CURRENT holdings
        // Current holdings: 5 shares
        // All 5 shares are "old" shares (were held at period start)
        // Reference = 5 * €110 = €550
        // Current value = 5 * €130 = €650
        // Unrealized P/L = €650 - €550 = €100
        expect(result.unrealizedPL, equals(100.0));

        // The realized gain from the sale (€150) is separate and calculated elsewhere
        // This ensures unrealized P/L shows true paper gain on remaining position
      });
    });

    group('Realized P/L calculation', () {
      test('calculates realized P/L from sales for ALL period', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 5,
          totalCostEur: 500,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 6, 1),
            quantity: 5,
            totalEur: 600, // €120/share
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 130.0},
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Realized P/L = sale proceeds - cost of sold shares
        // = €600 - (5 * €100) = €600 - €500 = €100
        expect(result.realizedPL, equals(100.0));
      });

      test('calculates realized P/L only for sales within period', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 5,
          totalCostEur: 500,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 12, 10), // Within 1-month period
            quantity: 5,
            totalEur: 600,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 130.0},
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0},
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Sale was after period start, so realized P/L is included
        // Realized P/L = €600 - (5 * €100) = €100
        expect(result.realizedPL, equals(100.0));
      });

      test('excludes sales before period from realized P/L', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 5,
          totalCostEur: 500,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 6, 1), // Before 1-month period
            quantity: 5,
            totalEur: 600,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 130.0},
          priceByTickerDate: {
            'TEST.MI': {'2024-11-26': 110.0},
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Sale was before period start, so no realized P/L for this period
        expect(result.realizedPL, equals(0.0));
      });

      test('returns zero realized P/L when no sales', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        expect(result.realizedPL, equals(0.0));
      });

      test('handles multiple sales with changing average cost', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 5,
          totalCostEur: 550,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000, // €100/share
          ),
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 3, 1),
            quantity: 10,
            totalEur: 1200, // €120/share
          ),
          // Now: 20 shares, cost €2200, avg €110
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 6, 1),
            quantity: 5,
            totalEur: 600, // €120/share
          ),
          // Now: 15 shares, cost €1650 (€2200 - 5*€110), avg €110
          createSellOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 9, 1),
            quantity: 10,
            totalEur: 1300, // €130/share
          ),
          // Now: 5 shares, cost €550 (€1650 - 10*€110)
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 140.0},
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // First sale: €600 - (5 * €110) = €600 - €550 = €50
        // Second sale: €1300 - (10 * €110) = €1300 - €1100 = €200
        // Total realized: €250
        expect(result.realizedPL, equals(250.0));
      });
    });

    group('Edge cases', () {
      test('handles zero quantity holding', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 0,
          totalCostEur: 0,
        );
        final orders = <Order>[];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 100.0},
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        expect(result.value, equals(0.0));
        expect(result.costBasis, equals(0.0));
        expect(result.periodPL, equals(0.0));
        expect(result.mwr, equals(0.0));
      });

      test('handles asset without yahoo symbol', () {
        final asset = createAsset(yahooSymbol: null, ticker: 'CUSTOM');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.all,
          comparisonDate: '2024-01-01',
          todayStr: '2024-12-26',
          priceMap: {}, // No price for this ticker
          priceByTickerDate: {},
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Falls back to totalCostEur for value
        expect(result.value, equals(1000.0));
        expect(result.twr, isNull);
      });

      test('uses nearest prior date when exact date not available', () {
        final asset = createAsset(yahooSymbol: 'TEST.MI');
        final holding = createHolding(
          assetId: asset.id!,
          quantity: 10,
          totalCostEur: 1000,
        );
        final orders = [
          createBuyOrder(
            assetId: asset.id!,
            orderDate: DateTime(2024, 1, 1),
            quantity: 10,
            totalEur: 1000,
          ),
        ];

        final result = AssetReturnsCalculator.calculate(
          asset: asset,
          orders: orders,
          holding: holding,
          period: ReturnPeriod.oneMonth,
          comparisonDate: '2024-11-26', // No price for this exact date
          todayStr: '2024-12-26',
          priceMap: {'TEST.MI': 120.0},
          priceByTickerDate: {
            'TEST.MI': {
              '2024-11-22': 100.0, // Nearest prior date
              '2024-11-28': 105.0, // After comparison date
            },
          },
          derivedFxRateMap: {},
          fxRateMap: {},
        );

        // Should use 2024-11-22 price (100.0)
        // TWR = (120 - 100) / 100 = 0.2
        expect(result.twr, closeTo(0.2, 0.001));
      });
    });
  });
}
