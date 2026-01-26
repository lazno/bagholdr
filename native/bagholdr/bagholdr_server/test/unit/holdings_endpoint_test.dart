import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('OrderSummary', () {
    test('creates order summary with all fields', () {
      final order = OrderSummary(
        orderDate: DateTime(2024, 6, 15),
        orderType: 'buy',
        quantity: 50.0,
        priceNative: 100.0,
        totalNative: 5000.0,
        totalEur: 5000.0,
        currency: 'EUR',
      );

      expect(order.orderDate, equals(DateTime(2024, 6, 15)));
      expect(order.orderType, equals('buy'));
      expect(order.quantity, equals(50.0));
      expect(order.priceNative, equals(100.0));
      expect(order.totalNative, equals(5000.0));
      expect(order.totalEur, equals(5000.0));
      expect(order.currency, equals('EUR'));
    });

    test('handles fee orders with zero quantity', () {
      final order = OrderSummary(
        orderDate: DateTime(2024, 6, 15),
        orderType: 'fee',
        quantity: 0.0,
        priceNative: 0.0,
        totalNative: 5.0,
        totalEur: 5.0,
        currency: 'EUR',
      );

      expect(order.orderType, equals('fee'));
      expect(order.quantity, equals(0.0));
      expect(order.totalEur, equals(5.0));
    });
  });

  group('AssetDetailResponse', () {
    test('creates asset detail with all fields', () {
      final orders = [
        OrderSummary(
          orderDate: DateTime(2024, 6, 15),
          orderType: 'buy',
          quantity: 50.0,
          priceNative: 100.0,
          totalNative: 5000.0,
          totalEur: 5000.0,
          currency: 'EUR',
        ),
      ];

      final response = AssetDetailResponse(
        assetId: '123e4567-e89b-12d3-a456-426614174001',
        isin: 'IE00B4L5Y983',
        ticker: 'SWDA',
        name: 'iShares Core MSCI World',
        yahooSymbol: 'SWDA.MI',
        assetType: 'etf',
        currency: 'EUR',
        quantity: 123.45,
        value: 12345.67,
        costBasis: 10000.0,
        weight: 25.5,
        periodReturnAbs: 2345.67,
        periodReturnPct: 18.50,
        mwr: 23.45,
        twr: 21.30,
        sleeveId: '123e4567-e89b-12d3-a456-426614174000',
        sleeveName: 'Equity Core',
        orders: orders,
      );

      expect(response.assetId, equals('123e4567-e89b-12d3-a456-426614174001'));
      expect(response.isin, equals('IE00B4L5Y983'));
      expect(response.name, equals('iShares Core MSCI World'));
      expect(response.assetType, equals('etf'));
      expect(response.value, equals(12345.67));
      expect(response.costBasis, equals(10000.0));
      expect(response.weight, equals(25.5));
      expect(response.periodReturnAbs, equals(2345.67));
      expect(response.periodReturnPct, equals(18.50));
      expect(response.mwr, equals(23.45));
      expect(response.twr, equals(21.30));
      expect(response.sleeveName, equals('Equity Core'));
      expect(response.orders.length, equals(1));
    });

    test('allows null optional fields', () {
      final response = AssetDetailResponse(
        assetId: '123e4567-e89b-12d3-a456-426614174001',
        isin: 'IE00B4L5Y983',
        ticker: 'SWDA',
        name: 'iShares Core MSCI World',
        yahooSymbol: null,
        assetType: 'etf',
        currency: 'EUR',
        quantity: 123.45,
        value: 12345.67,
        costBasis: 10000.0,
        weight: 25.5,
        periodReturnAbs: 2345.67,
        periodReturnPct: null,
        mwr: 23.45,
        twr: null,
        sleeveId: null,
        sleeveName: null,
        orders: [],
      );

      expect(response.yahooSymbol, isNull);
      expect(response.twr, isNull);
      expect(response.periodReturnPct, isNull);
      expect(response.sleeveId, isNull);
      expect(response.sleeveName, isNull);
      expect(response.orders, isEmpty);
    });

    test('serializes to JSON correctly', () {
      final response = AssetDetailResponse(
        assetId: '123e4567-e89b-12d3-a456-426614174001',
        isin: 'IE00B4L5Y983',
        ticker: 'SWDA',
        name: 'iShares Core MSCI World',
        yahooSymbol: 'SWDA.MI',
        assetType: 'etf',
        currency: 'EUR',
        quantity: 123.45,
        value: 12345.67,
        costBasis: 10000.0,
        weight: 25.5,
        periodReturnAbs: 2345.67,
        periodReturnPct: 18.50,
        mwr: 23.45,
        twr: 21.30,
        sleeveId: null,
        sleeveName: null,
        orders: [],
      );

      final json = response.toJson();
      expect(json['assetId'], equals('123e4567-e89b-12d3-a456-426614174001'));
      expect(json['isin'], equals('IE00B4L5Y983'));
      expect(json['name'], equals('iShares Core MSCI World'));
      expect(json['assetType'], equals('etf'));
      expect(json['value'], equals(12345.67));
      expect(json['mwr'], equals(23.45));
      expect(json['periodReturnAbs'], equals(2345.67));
      expect(json['periodReturnPct'], equals(18.50));
    });
  });

  group('HoldingResponse', () {
    test('creates holding response with all required fields', () {
      final response = HoldingResponse(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        isin: 'US0378331005',
        value: 1500.00,
        costBasis: 1200.00,
        pl: 300.00,
        weight: 15.5,
        mwr: 0.25,
        twr: 0.22,
        sleeveId: '123e4567-e89b-12d3-a456-426614174000',
        sleeveName: 'Core',
        assetId: '123e4567-e89b-12d3-a456-426614174001',
        quantity: 10.0,
      );

      expect(response.symbol, equals('AAPL'));
      expect(response.name, equals('Apple Inc.'));
      expect(response.isin, equals('US0378331005'));
      expect(response.value, equals(1500.00));
      expect(response.costBasis, equals(1200.00));
      expect(response.pl, equals(300.00));
      expect(response.weight, equals(15.5));
      expect(response.mwr, equals(0.25));
      expect(response.twr, equals(0.22));
      expect(response.sleeveId, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(response.sleeveName, equals('Core'));
      expect(response.assetId, equals('123e4567-e89b-12d3-a456-426614174001'));
      expect(response.quantity, equals(10.0));
    });

    test('allows null optional fields', () {
      final response = HoldingResponse(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        isin: 'US0378331005',
        value: 1500.00,
        costBasis: 1200.00,
        pl: 300.00,
        weight: 15.5,
        mwr: 0.25,
        twr: null,
        sleeveId: null,
        sleeveName: null,
        assetId: '123e4567-e89b-12d3-a456-426614174001',
        quantity: 10.0,
      );

      expect(response.twr, isNull);
      expect(response.sleeveId, isNull);
      expect(response.sleeveName, isNull);
    });

    test('serializes to JSON correctly', () {
      final response = HoldingResponse(
        symbol: 'MSFT',
        name: 'Microsoft Corp.',
        isin: 'US5949181045',
        value: 2000.00,
        costBasis: 1800.00,
        pl: 200.00,
        weight: 20.0,
        mwr: 0.111,
        twr: 0.10,
        sleeveId: '123e4567-e89b-12d3-a456-426614174000',
        sleeveName: 'Tech',
        assetId: '123e4567-e89b-12d3-a456-426614174002',
        quantity: 5.0,
      );

      final json = response.toJson();
      expect(json['symbol'], equals('MSFT'));
      expect(json['name'], equals('Microsoft Corp.'));
      expect(json['value'], equals(2000.00));
      expect(json['pl'], equals(200.00));
      expect(json['mwr'], equals(0.111));
      expect(json['twr'], equals(0.10));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'symbol': 'GOOGL',
        'name': 'Alphabet Inc.',
        'isin': 'US02079K3059',
        'value': 3000.0,
        'costBasis': 2500.0,
        'pl': 500.0,
        'weight': 30.0,
        'mwr': 0.20,
        'twr': 0.18,
        'sleeveId': '123e4567-e89b-12d3-a456-426614174000',
        'sleeveName': 'Growth',
        'assetId': '123e4567-e89b-12d3-a456-426614174003',
        'quantity': 2.0,
      };

      final response = HoldingResponse.fromJson(json);
      expect(response.symbol, equals('GOOGL'));
      expect(response.name, equals('Alphabet Inc.'));
      expect(response.value, equals(3000.0));
      expect(response.mwr, equals(0.20));
    });
  });

  group('HoldingsListResponse', () {
    test('creates list response with holdings', () {
      final holdings = [
        HoldingResponse(
          symbol: 'AAPL',
          name: 'Apple Inc.',
          isin: 'US0378331005',
          value: 1500.00,
          costBasis: 1200.00,
          pl: 300.00,
          weight: 60.0,
          mwr: 0.25,
          twr: 0.22,
          assetId: '123e4567-e89b-12d3-a456-426614174001',
          quantity: 10.0,
        ),
        HoldingResponse(
          symbol: 'MSFT',
          name: 'Microsoft Corp.',
          isin: 'US5949181045',
          value: 1000.00,
          costBasis: 900.00,
          pl: 100.00,
          weight: 40.0,
          mwr: 0.111,
          twr: 0.10,
          assetId: '123e4567-e89b-12d3-a456-426614174002',
          quantity: 5.0,
        ),
      ];

      final response = HoldingsListResponse(
        holdings: holdings,
        totalCount: 10,
        filteredCount: 2,
        totalValue: 2500.00,
      );

      expect(response.holdings.length, equals(2));
      expect(response.totalCount, equals(10));
      expect(response.filteredCount, equals(2));
      expect(response.totalValue, equals(2500.00));
    });

    test('handles empty holdings list', () {
      final response = HoldingsListResponse(
        holdings: [],
        totalCount: 0,
        filteredCount: 0,
        totalValue: 0,
      );

      expect(response.holdings, isEmpty);
      expect(response.totalCount, equals(0));
      expect(response.filteredCount, equals(0));
      expect(response.totalValue, equals(0));
    });

    test('serializes to JSON correctly', () {
      final response = HoldingsListResponse(
        holdings: [
          HoldingResponse(
            symbol: 'AAPL',
            name: 'Apple Inc.',
            isin: 'US0378331005',
            value: 1500.00,
            costBasis: 1200.00,
            pl: 300.00,
            weight: 100.0,
            mwr: 0.25,
            twr: 0.22,
            assetId: '123e4567-e89b-12d3-a456-426614174001',
            quantity: 10.0,
          ),
        ],
        totalCount: 5,
        filteredCount: 1,
        totalValue: 1500.00,
      );

      final json = response.toJson();
      expect(json['totalCount'], equals(5));
      expect(json['filteredCount'], equals(1));
      expect(json['totalValue'], equals(1500.00));
      expect(json['holdings'], isA<List>());
      expect((json['holdings'] as List).length, equals(1));
    });
  });
}
