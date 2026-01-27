import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Update Asset Type Endpoint', (sessionBuilder, endpoints) {
    group('updateAssetType', () {
      late UuidValue assetId;

      setUp(() async {
        // Create an asset via import
        final csv = _buildCSV([
          '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,Vanguard FTSE All-World,10,1234.56,0,EUR,REF-ASSET-TYPE-TEST',
        ]);

        await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
        );

        // Get the asset ID from database
        final session = await sessionBuilder.build();
        final assets = await Asset.db.find(
          session,
          where: (t) => t.isin.equals('IE00BK5BQT80'),
        );
        expect(assets, isNotEmpty, reason: 'Asset should have been created');
        assetId = assets.first.id!;
      });

      test('updates asset type from etf to stock', () async {
        final result = await endpoints.holdings.updateAssetType(
          sessionBuilder,
          assetId: assetId,
          newType: 'stock',
        );

        expect(result.success, isTrue);
        expect(result.newType, equals('stock'));

        // Verify the change persisted
        final session = await sessionBuilder.build();
        final asset = await Asset.db.findById(session, assetId);
        expect(asset, isNotNull);
        expect(asset!.assetType, equals(AssetType.stock));
      });

      test('updates asset type to bond', () async {
        final result = await endpoints.holdings.updateAssetType(
          sessionBuilder,
          assetId: assetId,
          newType: 'bond',
        );

        expect(result.success, isTrue);
        expect(result.newType, equals('bond'));

        final session = await sessionBuilder.build();
        final asset = await Asset.db.findById(session, assetId);
        expect(asset!.assetType, equals(AssetType.bond));
      });

      test('updates asset type to fund', () async {
        final result = await endpoints.holdings.updateAssetType(
          sessionBuilder,
          assetId: assetId,
          newType: 'fund',
        );

        expect(result.success, isTrue);
        expect(result.newType, equals('fund'));
      });

      test('updates asset type to commodity', () async {
        final result = await endpoints.holdings.updateAssetType(
          sessionBuilder,
          assetId: assetId,
          newType: 'commodity',
        );

        expect(result.success, isTrue);
        expect(result.newType, equals('commodity'));
      });

      test('updates asset type to other', () async {
        final result = await endpoints.holdings.updateAssetType(
          sessionBuilder,
          assetId: assetId,
          newType: 'other',
        );

        expect(result.success, isTrue);
        expect(result.newType, equals('other'));
      });

      test('throws for invalid asset type', () async {
        expect(
          () => endpoints.holdings.updateAssetType(
            sessionBuilder,
            assetId: assetId,
            newType: 'invalid_type',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws for non-existent asset', () async {
        final fakeId = UuidValue.fromString('00000000-0000-0000-0000-000000000000');
        expect(
          () => endpoints.holdings.updateAssetType(
            sessionBuilder,
            assetId: fakeId,
            newType: 'stock',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

/// Build a valid Directa CSV with header lines
String _buildCSV(List<String> dataLines) {
  final header = [
    'ACCOUNT : C6766 Test Account',
    'Line 2',
    'Line 3',
    'Line 4',
    'Line 5',
    'Line 6',
    'Line 7',
    'Line 8',
    'Line 9',
    'Date,Value Date,Type,Ticker,ISIN,Protocol,Description,Quantity,Amount EUR,Currency Amount,Currency,Order Ref',
  ];

  return [...header, ...dataLines].join('\n');
}
