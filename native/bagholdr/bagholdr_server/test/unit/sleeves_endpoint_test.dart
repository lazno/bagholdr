import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('SleeveNode', () {
    test('creates sleeve node with all required fields', () {
      final node = SleeveNode(
        id: '123e4567-e89b-12d3-a456-426614174000',
        name: 'Core',
        parentId: null,
        color: '#3b82f6',
        targetPct: 75.0,
        currentPct: 72.5,
        driftPp: -2.5,
        driftStatus: 'ok',
        value: 85000.00,
        mwr: 12.5,
        twr: 10.2,
        assetCount: 8,
        childSleeveCount: 2,
        children: null,
      );

      expect(node.id, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(node.name, equals('Core'));
      expect(node.parentId, isNull);
      expect(node.color, equals('#3b82f6'));
      expect(node.targetPct, equals(75.0));
      expect(node.currentPct, equals(72.5));
      expect(node.driftPp, equals(-2.5));
      expect(node.driftStatus, equals('ok'));
      expect(node.value, equals(85000.00));
      expect(node.mwr, equals(12.5));
      expect(node.twr, equals(10.2));
      expect(node.assetCount, equals(8));
      expect(node.childSleeveCount, equals(2));
      expect(node.children, isNull);
    });

    test('allows null twr when calculation fails', () {
      final node = SleeveNode(
        id: '123e4567-e89b-12d3-a456-426614174000',
        name: 'Equities',
        parentId: '123e4567-e89b-12d3-a456-426614174001',
        color: '#60a5fa',
        targetPct: 50.0,
        currentPct: 55.0,
        driftPp: 5.0,
        driftStatus: 'over',
        value: 50000.00,
        mwr: 15.0,
        twr: null,
        assetCount: 5,
        childSleeveCount: 0,
        children: null,
      );

      expect(node.twr, isNull);
      expect(node.driftStatus, equals('over'));
    });

    test('creates sleeve node with children', () {
      final childNode = SleeveNode(
        id: 'child-1',
        name: 'Equities',
        parentId: 'parent-1',
        color: '#60a5fa',
        targetPct: 50.0,
        currentPct: 48.0,
        driftPp: -2.0,
        driftStatus: 'ok',
        value: 45000.00,
        mwr: 14.0,
        twr: 12.5,
        assetCount: 3,
        childSleeveCount: 0,
        children: null,
      );

      final parentNode = SleeveNode(
        id: 'parent-1',
        name: 'Core',
        parentId: null,
        color: '#3b82f6',
        targetPct: 75.0,
        currentPct: 72.0,
        driftPp: -3.0,
        driftStatus: 'ok',
        value: 85000.00,
        mwr: 12.5,
        twr: 10.2,
        assetCount: 2,
        childSleeveCount: 1,
        children: [childNode],
      );

      expect(parentNode.children, isNotNull);
      expect(parentNode.children!.length, equals(1));
      expect(parentNode.children![0].name, equals('Equities'));
    });

    test('serializes to JSON correctly', () {
      final node = SleeveNode(
        id: '123e4567-e89b-12d3-a456-426614174000',
        name: 'Core',
        parentId: null,
        color: '#3b82f6',
        targetPct: 75.0,
        currentPct: 72.5,
        driftPp: -2.5,
        driftStatus: 'ok',
        value: 85000.00,
        mwr: 12.5,
        twr: 10.2,
        assetCount: 8,
        childSleeveCount: 2,
        children: null,
      );

      final json = node.toJson();
      expect(json['id'], equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(json['name'], equals('Core'));
      expect(json['color'], equals('#3b82f6'));
      expect(json['targetPct'], equals(75.0));
      expect(json['currentPct'], equals(72.5));
      expect(json['driftPp'], equals(-2.5));
      expect(json['value'], equals(85000.00));
      expect(json['mwr'], equals(12.5));
      expect(json['twr'], equals(10.2));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'name': 'Satellite',
        'parentId': null,
        'color': '#f59e0b',
        'targetPct': 25.0,
        'currentPct': 28.0,
        'driftPp': 3.0,
        'driftStatus': 'over',
        'value': 30000.0,
        'mwr': 18.5,
        'twr': 16.0,
        'assetCount': 4,
        'childSleeveCount': 2,
        'children': null,
      };

      final node = SleeveNode.fromJson(json);
      expect(node.name, equals('Satellite'));
      expect(node.color, equals('#f59e0b'));
      expect(node.driftStatus, equals('over'));
      expect(node.mwr, equals(18.5));
    });

    test('drift status values are valid', () {
      final okNode = SleeveNode(
        id: 'ok-node',
        name: 'Core',
        parentId: null,
        color: '#3b82f6',
        targetPct: 75.0,
        currentPct: 75.0,
        driftPp: 0,
        driftStatus: 'ok',
        value: 75000.00,
        mwr: 10.0,
        twr: 10.0,
        assetCount: 5,
        childSleeveCount: 0,
        children: null,
      );

      final overNode = SleeveNode(
        id: 'over-node',
        name: 'Core',
        parentId: null,
        color: '#3b82f6',
        targetPct: 75.0,
        currentPct: 85.0,
        driftPp: 10.0,
        driftStatus: 'over',
        value: 85000.00,
        mwr: 10.0,
        twr: 10.0,
        assetCount: 5,
        childSleeveCount: 0,
        children: null,
      );

      final underNode = SleeveNode(
        id: 'under-node',
        name: 'Core',
        parentId: null,
        color: '#3b82f6',
        targetPct: 75.0,
        currentPct: 65.0,
        driftPp: -10.0,
        driftStatus: 'under',
        value: 65000.00,
        mwr: 10.0,
        twr: 10.0,
        assetCount: 5,
        childSleeveCount: 0,
        children: null,
      );

      expect(okNode.driftStatus, equals('ok'));
      expect(overNode.driftStatus, equals('over'));
      expect(underNode.driftStatus, equals('under'));
    });
  });

  group('SleeveTreeResponse', () {
    test('creates tree response with sleeves', () {
      final sleeves = [
        SleeveNode(
          id: 'core-id',
          name: 'Core',
          parentId: null,
          color: '#3b82f6',
          targetPct: 75.0,
          currentPct: 72.5,
          driftPp: -2.5,
          driftStatus: 'ok',
          value: 85000.00,
          mwr: 12.5,
          twr: 10.2,
          assetCount: 8,
          childSleeveCount: 2,
          children: null,
        ),
        SleeveNode(
          id: 'satellite-id',
          name: 'Satellite',
          parentId: null,
          color: '#f59e0b',
          targetPct: 25.0,
          currentPct: 27.5,
          driftPp: 2.5,
          driftStatus: 'ok',
          value: 32000.00,
          mwr: 18.0,
          twr: 15.5,
          assetCount: 4,
          childSleeveCount: 2,
          children: null,
        ),
      ];

      final response = SleeveTreeResponse(
        sleeves: sleeves,
        totalValue: 117000.00,
        totalMwr: 14.0,
        totalTwr: 11.5,
        totalAssetCount: 12,
      );

      expect(response.sleeves.length, equals(2));
      expect(response.totalValue, equals(117000.00));
      expect(response.totalMwr, equals(14.0));
      expect(response.totalTwr, equals(11.5));
      expect(response.totalAssetCount, equals(12));
    });

    test('handles empty sleeves list', () {
      final response = SleeveTreeResponse(
        sleeves: [],
        totalValue: 0,
        totalMwr: 0,
        totalTwr: null,
        totalAssetCount: 0,
      );

      expect(response.sleeves, isEmpty);
      expect(response.totalValue, equals(0));
      expect(response.totalMwr, equals(0));
      expect(response.totalTwr, isNull);
      expect(response.totalAssetCount, equals(0));
    });

    test('allows null totalTwr', () {
      final response = SleeveTreeResponse(
        sleeves: [],
        totalValue: 100000.00,
        totalMwr: 10.0,
        totalTwr: null,
        totalAssetCount: 5,
      );

      expect(response.totalTwr, isNull);
    });

    test('serializes to JSON correctly', () {
      final response = SleeveTreeResponse(
        sleeves: [
          SleeveNode(
            id: 'core-id',
            name: 'Core',
            parentId: null,
            color: '#3b82f6',
            targetPct: 75.0,
            currentPct: 75.0,
            driftPp: 0,
            driftStatus: 'ok',
            value: 75000.00,
            mwr: 10.0,
            twr: 10.0,
            assetCount: 5,
            childSleeveCount: 0,
            children: null,
          ),
        ],
        totalValue: 75000.00,
        totalMwr: 10.0,
        totalTwr: 10.0,
        totalAssetCount: 5,
      );

      final json = response.toJson();
      expect(json['totalValue'], equals(75000.00));
      expect(json['totalMwr'], equals(10.0));
      expect(json['totalTwr'], equals(10.0));
      expect(json['totalAssetCount'], equals(5));
      expect(json['sleeves'], isA<List>());
      expect((json['sleeves'] as List).length, equals(1));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'sleeves': [
          {
            'id': 'core-id',
            'name': 'Core',
            'parentId': null,
            'color': '#3b82f6',
            'targetPct': 75.0,
            'currentPct': 75.0,
            'driftPp': 0.0,
            'driftStatus': 'ok',
            'value': 75000.0,
            'mwr': 10.0,
            'twr': 10.0,
            'assetCount': 5,
            'childSleeveCount': 0,
            'children': null,
          },
        ],
        'totalValue': 75000.0,
        'totalMwr': 10.0,
        'totalTwr': 10.0,
        'totalAssetCount': 5,
      };

      final response = SleeveTreeResponse.fromJson(json);
      expect(response.sleeves.length, equals(1));
      expect(response.sleeves[0].name, equals('Core'));
      expect(response.totalValue, equals(75000.0));
    });
  });
}
