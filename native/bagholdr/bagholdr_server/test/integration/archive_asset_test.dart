import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'archiveAsset endpoint',
    (sessionBuilder, endpoints) {
      test('archives an active asset', () async {
        final session = await sessionBuilder.build();

        // Create a test asset (not archived)
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'TEST123456789',
          ticker: 'TEST',
          yahooSymbol: 'TEST.MI',
          assetType: AssetType.etf,
          currency: 'EUR',
          name: 'Test Asset',
          archived: false,
        );
        await Asset.db.insert(session, [testAsset]);

        // Archive the asset
        final result = await endpoints.holdings.archiveAsset(
          sessionBuilder,
          assetId: assetId,
          archived: true,
        );

        expect(result, isTrue);

        // Verify asset is now archived
        final updatedAsset = await Asset.db.findById(session, assetId);
        expect(updatedAsset, isNotNull);
        expect(updatedAsset!.archived, isTrue);
      });

      test('unarchives an archived asset', () async {
        final session = await sessionBuilder.build();

        // Create an archived test asset
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'TEST987654321',
          ticker: 'TEST2',
          yahooSymbol: 'TEST2.MI',
          assetType: AssetType.stock,
          currency: 'EUR',
          name: 'Test Asset 2',
          archived: true,
        );
        await Asset.db.insert(session, [testAsset]);

        // Unarchive the asset
        final result = await endpoints.holdings.archiveAsset(
          sessionBuilder,
          assetId: assetId,
          archived: false,
        );

        expect(result, isTrue);

        // Verify asset is now not archived
        final updatedAsset = await Asset.db.findById(session, assetId);
        expect(updatedAsset, isNotNull);
        expect(updatedAsset!.archived, isFalse);
      });

      test('returns false for non-existent asset', () async {
        final nonExistentId = UuidValue.fromString(const Uuid().v7());

        final result = await endpoints.holdings.archiveAsset(
          sessionBuilder,
          assetId: nonExistentId,
          archived: true,
        );

        expect(result, isFalse);
      });

      test('archiving already archived asset is idempotent', () async {
        final session = await sessionBuilder.build();

        // Create an already archived asset
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'IDEMPOTENT123',
          ticker: 'IDEM',
          yahooSymbol: null,
          assetType: AssetType.bond,
          currency: 'EUR',
          name: 'Idempotent Test',
          archived: true,
        );
        await Asset.db.insert(session, [testAsset]);

        // Archive again
        final result = await endpoints.holdings.archiveAsset(
          sessionBuilder,
          assetId: assetId,
          archived: true,
        );

        expect(result, isTrue);

        // Verify still archived
        final updatedAsset = await Asset.db.findById(session, assetId);
        expect(updatedAsset!.archived, isTrue);
      });

      test('archiving removes asset from all sleeves', () async {
        final session = await sessionBuilder.build();

        // Create a portfolio
        final portfolioId = UuidValue.fromString(const Uuid().v7());
        final portfolio = Portfolio(
          id: portfolioId,
          name: 'Test Portfolio',
          bandRelativeTolerance: 20.0,
          bandAbsoluteFloor: 5.0,
          bandAbsoluteCap: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await Portfolio.db.insert(session, [portfolio]);

        // Create a sleeve
        final sleeveId = UuidValue.fromString(const Uuid().v7());
        final sleeve = Sleeve(
          id: sleeveId,
          portfolioId: portfolioId,
          name: 'Test Sleeve',
          budgetPercent: 50.0,
          sortOrder: 0,
          isCash: false,
        );
        await Sleeve.db.insert(session, [sleeve]);

        // Create an asset
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'SLEEVE123456',
          ticker: 'SLV',
          yahooSymbol: 'SLV.MI',
          assetType: AssetType.etf,
          currency: 'EUR',
          name: 'Sleeved Asset',
          archived: false,
        );
        await Asset.db.insert(session, [testAsset]);

        // Assign asset to sleeve
        final sleeveAsset = SleeveAsset(
          sleeveId: sleeveId,
          assetId: assetId,
        );
        await SleeveAsset.db.insert(session, [sleeveAsset]);

        // Verify assignment exists
        var assignments = await SleeveAsset.db.find(
          session,
          where: (t) => t.assetId.equals(assetId),
        );
        expect(assignments, hasLength(1));

        // Archive the asset
        final result = await endpoints.holdings.archiveAsset(
          sessionBuilder,
          assetId: assetId,
          archived: true,
        );

        expect(result, isTrue);

        // Verify asset is archived
        final updatedAsset = await Asset.db.findById(session, assetId);
        expect(updatedAsset!.archived, isTrue);

        // Verify sleeve assignment was removed
        assignments = await SleeveAsset.db.find(
          session,
          where: (t) => t.assetId.equals(assetId),
        );
        expect(assignments, isEmpty);
      });

      test('unarchiving does not restore sleeve assignments', () async {
        final session = await sessionBuilder.build();

        // Create an archived asset (no sleeve assignment)
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'NOAUTO123456',
          ticker: 'NAR',
          yahooSymbol: null,
          assetType: AssetType.stock,
          currency: 'EUR',
          name: 'No Auto Restore',
          archived: true,
        );
        await Asset.db.insert(session, [testAsset]);

        // Unarchive the asset
        final result = await endpoints.holdings.archiveAsset(
          sessionBuilder,
          assetId: assetId,
          archived: false,
        );

        expect(result, isTrue);

        // Verify no sleeve assignments exist (should remain empty)
        final assignments = await SleeveAsset.db.find(
          session,
          where: (t) => t.assetId.equals(assetId),
        );
        expect(assignments, isEmpty);
      });
    },
    rollbackDatabase: RollbackDatabase.afterEach,
  );

  withServerpod(
    'getArchivedAssets endpoint',
    (sessionBuilder, endpoints) {
      test('returns empty list when no archived assets', () async {
        final session = await sessionBuilder.build();

        // Create a portfolio
        final portfolioId = UuidValue.fromString(const Uuid().v7());
        final portfolio = Portfolio(
          id: portfolioId,
          name: 'Test Portfolio',
          bandRelativeTolerance: 20.0,
          bandAbsoluteFloor: 5.0,
          bandAbsoluteCap: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await Portfolio.db.insert(session, [portfolio]);

        // Create a non-archived asset
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'ACTIVE123456',
          ticker: 'ACTIVE',
          yahooSymbol: 'ACTIVE.MI',
          assetType: AssetType.etf,
          currency: 'EUR',
          name: 'Active Asset',
          archived: false,
        );
        await Asset.db.insert(session, [testAsset]);

        // Get archived assets
        final result = await endpoints.holdings.getArchivedAssets(
          sessionBuilder,
          portfolioId: portfolioId,
        );

        expect(result, isEmpty);
      });

      test('returns archived assets with basic info', () async {
        final session = await sessionBuilder.build();

        // Create a portfolio
        final portfolioId = UuidValue.fromString(const Uuid().v7());
        final portfolio = Portfolio(
          id: portfolioId,
          name: 'Test Portfolio',
          bandRelativeTolerance: 20.0,
          bandAbsoluteFloor: 5.0,
          bandAbsoluteCap: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await Portfolio.db.insert(session, [portfolio]);

        // Create an archived asset
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'ARCHIVED12345',
          ticker: 'ARCH',
          yahooSymbol: 'ARCH.MI',
          assetType: AssetType.etf,
          currency: 'EUR',
          name: 'Archived Asset',
          archived: true,
        );
        await Asset.db.insert(session, [testAsset]);

        // Get archived assets
        final result = await endpoints.holdings.getArchivedAssets(
          sessionBuilder,
          portfolioId: portfolioId,
        );

        expect(result, hasLength(1));
        expect(result[0].id, equals(assetId.toString()));
        expect(result[0].name, equals('Archived Asset'));
        expect(result[0].isin, equals('ARCHIVED12345'));
        expect(result[0].yahooSymbol, equals('ARCH.MI'));
      });

      test('calculates lastKnownValue from holding and price cache', () async {
        final session = await sessionBuilder.build();

        // Create a portfolio
        final portfolioId = UuidValue.fromString(const Uuid().v7());
        final portfolio = Portfolio(
          id: portfolioId,
          name: 'Test Portfolio',
          bandRelativeTolerance: 20.0,
          bandAbsoluteFloor: 5.0,
          bandAbsoluteCap: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await Portfolio.db.insert(session, [portfolio]);

        // Create a test account
        final accountId = UuidValue.fromString(const Uuid().v7());
        final account = Account(
          id: accountId,
          name: 'Test Account',
          accountType: 'real',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await Account.db.insert(session, [account]);

        // Link account to portfolio
        final portfolioAccount = PortfolioAccount(
          portfolioId: portfolioId,
          accountId: accountId,
        );
        await PortfolioAccount.db.insert(session, [portfolioAccount]);

        // Create an archived asset with holding and price
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'VALUE1234567',
          ticker: 'VAL',
          yahooSymbol: 'VAL.MI',
          assetType: AssetType.stock,
          currency: 'EUR',
          name: 'Value Asset',
          archived: true,
        );
        await Asset.db.insert(session, [testAsset]);

        // Create a holding
        final holding = Holding(
          accountId: accountId,
          assetId: assetId,
          quantity: 10.0,
          totalCostEur: 1000.0,
        );
        await Holding.db.insert(session, [holding]);

        // Create a price cache entry
        final priceCache = PriceCache(
          ticker: 'VAL.MI',
          priceNative: 120.0,
          currency: 'EUR',
          priceEur: 120.0,
          fetchedAt: DateTime.now(),
        );
        await PriceCache.db.insert(session, [priceCache]);

        // Get archived assets
        final result = await endpoints.holdings.getArchivedAssets(
          sessionBuilder,
          portfolioId: portfolioId,
        );

        expect(result, hasLength(1));
        // lastKnownValue = priceEur * quantity = 120 * 10 = 1200
        expect(result[0].lastKnownValue, equals(1200.0));
      });

      test('returns assets sorted by name', () async {
        final session = await sessionBuilder.build();

        // Create a portfolio
        final portfolioId = UuidValue.fromString(const Uuid().v7());
        final portfolio = Portfolio(
          id: portfolioId,
          name: 'Test Portfolio',
          bandRelativeTolerance: 20.0,
          bandAbsoluteFloor: 5.0,
          bandAbsoluteCap: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await Portfolio.db.insert(session, [portfolio]);

        // Create archived assets in unsorted order
        final assets = [
          Asset(
            id: UuidValue.fromString(const Uuid().v7()),
            isin: 'ZZZZZ1234567',
            ticker: 'ZZZ',
            yahooSymbol: null,
            assetType: AssetType.etf,
            currency: 'EUR',
            name: 'Zeta Asset',
            archived: true,
          ),
          Asset(
            id: UuidValue.fromString(const Uuid().v7()),
            isin: 'AAAAA1234567',
            ticker: 'AAA',
            yahooSymbol: null,
            assetType: AssetType.etf,
            currency: 'EUR',
            name: 'Alpha Asset',
            archived: true,
          ),
          Asset(
            id: UuidValue.fromString(const Uuid().v7()),
            isin: 'MMMMM1234567',
            ticker: 'MMM',
            yahooSymbol: null,
            assetType: AssetType.etf,
            currency: 'EUR',
            name: 'Medium Asset',
            archived: true,
          ),
        ];
        await Asset.db.insert(session, assets);

        // Get archived assets
        final result = await endpoints.holdings.getArchivedAssets(
          sessionBuilder,
          portfolioId: portfolioId,
        );

        expect(result, hasLength(3));
        expect(result[0].name, equals('Alpha Asset'));
        expect(result[1].name, equals('Medium Asset'));
        expect(result[2].name, equals('Zeta Asset'));
      });
    },
    rollbackDatabase: RollbackDatabase.afterEach,
  );
}
