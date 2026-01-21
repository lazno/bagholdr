import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('Issue', () {
    test('creates over allocation issue with all fields', () {
      final issue = Issue(
        type: IssueType.overAllocation,
        severity: IssueSeverity.warning,
        message: 'Growth +5pp over target',
        sleeveId: '123e4567-e89b-12d3-a456-426614174000',
        sleeveName: 'Growth',
        driftPp: 5.0,
        color: '#fcd34d',
      );

      expect(issue.type, equals(IssueType.overAllocation));
      expect(issue.severity, equals(IssueSeverity.warning));
      expect(issue.message, equals('Growth +5pp over target'));
      expect(issue.sleeveId, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(issue.sleeveName, equals('Growth'));
      expect(issue.driftPp, equals(5.0));
      expect(issue.color, equals('#fcd34d'));
      expect(issue.assetId, isNull);
    });

    test('creates under allocation issue', () {
      final issue = Issue(
        type: IssueType.underAllocation,
        severity: IssueSeverity.warning,
        message: 'Bonds -3pp under target',
        sleeveId: '123e4567-e89b-12d3-a456-426614174001',
        sleeveName: 'Bonds',
        driftPp: -3.0,
        color: '#93c5fd',
      );

      expect(issue.type, equals(IssueType.underAllocation));
      expect(issue.severity, equals(IssueSeverity.warning));
      expect(issue.driftPp, equals(-3.0));
    });

    test('creates stale price issue', () {
      final issue = Issue(
        type: IssueType.stalePrice,
        severity: IssueSeverity.warning,
        message: '3 assets have stale prices',
      );

      expect(issue.type, equals(IssueType.stalePrice));
      expect(issue.severity, equals(IssueSeverity.warning));
      expect(issue.message, equals('3 assets have stale prices'));
      expect(issue.sleeveId, isNull);
      expect(issue.assetId, isNull);
    });

    test('creates sync status issue', () {
      final issue = Issue(
        type: IssueType.syncStatus,
        severity: IssueSeverity.info,
        message: 'Last sync: 2 hours ago',
      );

      expect(issue.type, equals(IssueType.syncStatus));
      expect(issue.severity, equals(IssueSeverity.info));
      expect(issue.message, equals('Last sync: 2 hours ago'));
    });

    test('serializes to JSON correctly', () {
      final issue = Issue(
        type: IssueType.overAllocation,
        severity: IssueSeverity.warning,
        message: 'Growth +5pp over target',
        sleeveId: '123e4567-e89b-12d3-a456-426614174000',
        sleeveName: 'Growth',
        driftPp: 5.0,
        color: '#fcd34d',
      );

      final json = issue.toJson();
      expect(json['type'], equals('overAllocation'));
      expect(json['severity'], equals('warning'));
      expect(json['message'], equals('Growth +5pp over target'));
      expect(json['sleeveId'], equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(json['sleeveName'], equals('Growth'));
      expect(json['driftPp'], equals(5.0));
      expect(json['color'], equals('#fcd34d'));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'type': 'underAllocation',
        'severity': 'warning',
        'message': 'Bonds -3pp under target',
        'sleeveId': '123e4567-e89b-12d3-a456-426614174001',
        'sleeveName': 'Bonds',
        'driftPp': -3.0,
        'color': '#93c5fd',
      };

      final issue = Issue.fromJson(json);
      expect(issue.type, equals(IssueType.underAllocation));
      expect(issue.severity, equals(IssueSeverity.warning));
      expect(issue.message, equals('Bonds -3pp under target'));
      expect(issue.sleeveName, equals('Bonds'));
      expect(issue.driftPp, equals(-3.0));
    });

    test('handles null optional fields in JSON', () {
      final json = {
        'type': 'stalePrice',
        'severity': 'warning',
        'message': '1 asset has stale prices',
      };

      final issue = Issue.fromJson(json);
      expect(issue.sleeveId, isNull);
      expect(issue.sleeveName, isNull);
      expect(issue.assetId, isNull);
      expect(issue.driftPp, isNull);
      expect(issue.color, isNull);
    });
  });

  group('IssueType', () {
    test('enum values exist', () {
      expect(IssueType.values, contains(IssueType.overAllocation));
      expect(IssueType.values, contains(IssueType.underAllocation));
      expect(IssueType.values, contains(IssueType.stalePrice));
      expect(IssueType.values, contains(IssueType.syncStatus));
    });

    test('serializes to JSON correctly', () {
      expect(IssueType.overAllocation.toJson(), equals('overAllocation'));
      expect(IssueType.underAllocation.toJson(), equals('underAllocation'));
      expect(IssueType.stalePrice.toJson(), equals('stalePrice'));
      expect(IssueType.syncStatus.toJson(), equals('syncStatus'));
    });
  });

  group('IssueSeverity', () {
    test('enum values exist', () {
      expect(IssueSeverity.values, contains(IssueSeverity.warning));
      expect(IssueSeverity.values, contains(IssueSeverity.info));
    });

    test('serializes to JSON correctly', () {
      expect(IssueSeverity.warning.toJson(), equals('warning'));
      expect(IssueSeverity.info.toJson(), equals('info'));
    });
  });

  group('IssuesResponse', () {
    test('creates response with issues', () {
      final issues = [
        Issue(
          type: IssueType.overAllocation,
          severity: IssueSeverity.warning,
          message: 'Growth +5pp over target',
          sleeveId: 'sleeve-1',
          sleeveName: 'Growth',
          driftPp: 5.0,
          color: '#fcd34d',
        ),
        Issue(
          type: IssueType.stalePrice,
          severity: IssueSeverity.warning,
          message: '3 assets have stale prices',
        ),
        Issue(
          type: IssueType.syncStatus,
          severity: IssueSeverity.info,
          message: 'Last sync: 2 hours ago',
        ),
      ];

      final response = IssuesResponse(
        issues: issues,
        totalCount: 3,
      );

      expect(response.issues.length, equals(3));
      expect(response.totalCount, equals(3));
      expect(response.issues[0].type, equals(IssueType.overAllocation));
      expect(response.issues[1].type, equals(IssueType.stalePrice));
      expect(response.issues[2].type, equals(IssueType.syncStatus));
    });

    test('handles empty issues list', () {
      final response = IssuesResponse(
        issues: [],
        totalCount: 0,
      );

      expect(response.issues, isEmpty);
      expect(response.totalCount, equals(0));
    });

    test('serializes to JSON correctly', () {
      final response = IssuesResponse(
        issues: [
          Issue(
            type: IssueType.overAllocation,
            severity: IssueSeverity.warning,
            message: 'Test issue',
            sleeveId: 'sleeve-1',
            sleeveName: 'Test',
            driftPp: 1.0,
            color: '#ff0000',
          ),
        ],
        totalCount: 1,
      );

      final json = response.toJson();
      expect(json['totalCount'], equals(1));
      expect(json['issues'], isA<List>());
      expect((json['issues'] as List).length, equals(1));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'issues': [
          {
            'type': 'overAllocation',
            'severity': 'warning',
            'message': 'Growth +5pp over target',
            'sleeveId': 'sleeve-1',
            'sleeveName': 'Growth',
            'driftPp': 5.0,
            'color': '#fcd34d',
          },
          {
            'type': 'syncStatus',
            'severity': 'info',
            'message': 'Last sync: 2 hours ago',
          },
        ],
        'totalCount': 2,
      };

      final response = IssuesResponse.fromJson(json);
      expect(response.issues.length, equals(2));
      expect(response.totalCount, equals(2));
      expect(response.issues[0].type, equals(IssueType.overAllocation));
      expect(response.issues[1].type, equals(IssueType.syncStatus));
    });
  });
}
