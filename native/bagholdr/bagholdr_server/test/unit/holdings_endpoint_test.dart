import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
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
