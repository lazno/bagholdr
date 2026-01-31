import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:bagholdr_server/src/utils/portfolio_accounts.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('aggregateHoldingsByAsset', () {
    test('returns empty map for empty holdings list', () {
      final result = aggregateHoldingsByAsset([]);
      expect(result, isEmpty);
    });

    test('returns single holding unchanged', () {
      final assetId = UuidValue.fromString('11111111-1111-1111-1111-111111111111');
      final accountId = UuidValue.fromString('22222222-2222-2222-2222-222222222222');
      final holdings = [
        Holding(
          accountId: accountId,
          assetId: assetId,
          quantity: 100,
          totalCostEur: 1000,
        ),
      ];

      final result = aggregateHoldingsByAsset(holdings);

      expect(result.length, equals(1));
      expect(result[assetId.toString()]!.quantity, equals(100));
      expect(result[assetId.toString()]!.totalCostEur, equals(1000));
    });

    test('aggregates holdings for same asset from different accounts', () {
      final assetId = UuidValue.fromString('11111111-1111-1111-1111-111111111111');
      final account1Id = UuidValue.fromString('22222222-2222-2222-2222-222222222222');
      final account2Id = UuidValue.fromString('33333333-3333-3333-3333-333333333333');

      final holdings = [
        Holding(
          accountId: account1Id,
          assetId: assetId,
          quantity: 100,
          totalCostEur: 1000,
        ),
        Holding(
          accountId: account2Id,
          assetId: assetId,
          quantity: 50,
          totalCostEur: 600,
        ),
      ];

      final result = aggregateHoldingsByAsset(holdings);

      expect(result.length, equals(1));
      expect(result[assetId.toString()]!.quantity, equals(150));
      expect(result[assetId.toString()]!.totalCostEur, equals(1600));
    });

    test('keeps different assets separate', () {
      final asset1Id = UuidValue.fromString('11111111-1111-1111-1111-111111111111');
      final asset2Id = UuidValue.fromString('44444444-4444-4444-4444-444444444444');
      final accountId = UuidValue.fromString('22222222-2222-2222-2222-222222222222');

      final holdings = [
        Holding(
          accountId: accountId,
          assetId: asset1Id,
          quantity: 100,
          totalCostEur: 1000,
        ),
        Holding(
          accountId: accountId,
          assetId: asset2Id,
          quantity: 50,
          totalCostEur: 500,
        ),
      ];

      final result = aggregateHoldingsByAsset(holdings);

      expect(result.length, equals(2));
      expect(result[asset1Id.toString()]!.quantity, equals(100));
      expect(result[asset2Id.toString()]!.quantity, equals(50));
    });

    test('handles multiple assets from multiple accounts', () {
      final asset1Id = UuidValue.fromString('11111111-1111-1111-1111-111111111111');
      final asset2Id = UuidValue.fromString('44444444-4444-4444-4444-444444444444');
      final account1Id = UuidValue.fromString('22222222-2222-2222-2222-222222222222');
      final account2Id = UuidValue.fromString('33333333-3333-3333-3333-333333333333');

      final holdings = [
        // Asset 1 in both accounts
        Holding(
          accountId: account1Id,
          assetId: asset1Id,
          quantity: 100,
          totalCostEur: 1000,
        ),
        Holding(
          accountId: account2Id,
          assetId: asset1Id,
          quantity: 25,
          totalCostEur: 300,
        ),
        // Asset 2 only in account 1
        Holding(
          accountId: account1Id,
          assetId: asset2Id,
          quantity: 50,
          totalCostEur: 500,
        ),
      ];

      final result = aggregateHoldingsByAsset(holdings);

      expect(result.length, equals(2));
      expect(result[asset1Id.toString()]!.quantity, equals(125));
      expect(result[asset1Id.toString()]!.totalCostEur, equals(1300));
      expect(result[asset2Id.toString()]!.quantity, equals(50));
      expect(result[asset2Id.toString()]!.totalCostEur, equals(500));
    });
  });
}
