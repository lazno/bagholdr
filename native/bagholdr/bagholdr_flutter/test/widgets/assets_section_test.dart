import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/colors.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/assets_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates mock HoldingResponse for testing.
HoldingResponse createMockHolding({
  String symbol = 'X.IUSQ',
  String name = 'iShares MSCI ACWI UCITS',
  String isin = 'IE00B6R52259',
  double value = 42500.0,
  double costBasis = 37845.0,
  double pl = 4655.0,
  double weight = 37.5,
  double mwr = 12.3,
  double? twr = 10.5,
  String? sleeveId = 'sleeve-1',
  String? sleeveName = 'Equities',
  String assetId = 'asset-1',
  double quantity = 100.0,
}) {
  return HoldingResponse(
    symbol: symbol,
    name: name,
    isin: isin,
    value: value,
    costBasis: costBasis,
    pl: pl,
    weight: weight,
    mwr: mwr,
    twr: twr,
    sleeveId: sleeveId,
    sleeveName: sleeveName,
    assetId: assetId,
    quantity: quantity,
  );
}

void main() {
  Widget buildWidget({
    List<HoldingResponse>? holdings,
    int totalCount = 32,
    int filteredCount = 32,
    String selectedSleeveName = 'All',
    String searchQuery = '',
    ValueChanged<String>? onSearchChanged,
    VoidCallback? onLoadMore,
    bool hasMore = false,
    ValueChanged<HoldingResponse>? onAssetTap,
    bool isLoading = false,
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: AssetsSection(
            holdings: holdings ?? [createMockHolding()],
            totalCount: totalCount,
            filteredCount: filteredCount,
            selectedSleeveName: selectedSleeveName,
            searchQuery: searchQuery,
            onSearchChanged: onSearchChanged ?? (_) {},
            onLoadMore: onLoadMore ?? () {},
            hasMore: hasMore,
            onAssetTap: onAssetTap ?? (_) {},
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }

  group('AssetsSection', () {
    testWidgets('displays section header with title and count',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        filteredCount: 32,
        selectedSleeveName: 'All',
      ));

      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('All \u00b7 32'), findsOneWidget);
    });

    testWidgets('displays search bar', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search assets...'), findsOneWidget);
    });

    testWidgets('displays table header', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('ASSET'), findsOneWidget);
      expect(find.text('PERFORMANCE'), findsOneWidget);
      expect(find.text('WEIGHT'), findsOneWidget);
    });

    testWidgets('displays holding data correctly', (tester) async {
      await tester.pumpWidget(buildWidget(
        holdings: [
          createMockHolding(
            name: 'iShares MSCI ACWI',
            symbol: 'X.IUSQ',
            value: 42500.0,
            pl: 4655.0,
            mwr: 12.3,
            twr: 10.5,
            weight: 37.5,
          ),
        ],
      ));

      // Asset name
      expect(find.text('iShares MSCI ACWI'), findsOneWidget);

      // Symbol and value in meta row
      expect(find.text('X.IUSQ'), findsOneWidget);
      expect(find.text('€42,500.00'), findsOneWidget);

      // P/L
      expect(find.text('+€4,655.00'), findsOneWidget);

      // MWR
      expect(find.text('+12.30%'), findsOneWidget);

      // TWR
      expect(find.text('TWR +10.50%'), findsOneWidget);

      // Weight
      expect(find.text('37.5%'), findsOneWidget);
    });

    testWidgets('shows positive P/L in green', (tester) async {
      await tester.pumpWidget(buildWidget(
        holdings: [createMockHolding(pl: 4655.0)],
      ));

      final plFinder = find.text('+€4,655.00');
      expect(plFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(plFinder);
      final financialColors = FinancialColors.light;
      expect(textWidget.style?.color, financialColors.positive);
    });

    testWidgets('shows negative P/L in red', (tester) async {
      await tester.pumpWidget(buildWidget(
        holdings: [createMockHolding(pl: -2000.0)],
      ));

      final plFinder = find.text('-€2,000.00');
      expect(plFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(plFinder);
      final financialColors = FinancialColors.light;
      expect(textWidget.style?.color, financialColors.negative);
    });

    testWidgets('handles null TWR gracefully', (tester) async {
      await tester.pumpWidget(buildWidget(
        holdings: [createMockHolding(twr: null)],
      ));

      // TWR should not be displayed
      expect(find.textContaining('TWR'), findsNothing);

      // Other values should still appear
      expect(find.text('+€4,655.00'), findsOneWidget);
    });

    testWidgets('shows no results message when holdings empty', (tester) async {
      await tester.pumpWidget(buildWidget(
        holdings: [],
        filteredCount: 0,
      ));

      expect(find.text('No assets match your search'), findsOneWidget);
    });

    testWidgets('shows load more button when hasMore is true', (tester) async {
      await tester.pumpWidget(buildWidget(
        hasMore: true,
      ));

      expect(find.text('Show more assets'), findsOneWidget);
    });

    testWidgets('hides load more button when hasMore is false',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        hasMore: false,
      ));

      expect(find.text('Show more assets'), findsNothing);
    });

    testWidgets('calls onLoadMore when load more button tapped',
        (tester) async {
      var loadMoreCalled = false;
      await tester.pumpWidget(buildWidget(
        hasMore: true,
        onLoadMore: () => loadMoreCalled = true,
      ));

      await tester.tap(find.text('Show more assets'));
      expect(loadMoreCalled, isTrue);
    });

    testWidgets('calls onAssetTap when asset row tapped', (tester) async {
      HoldingResponse? tappedHolding;
      final holding = createMockHolding(name: 'Test Asset');

      await tester.pumpWidget(buildWidget(
        holdings: [holding],
        onAssetTap: (h) => tappedHolding = h,
      ));

      await tester.tap(find.text('Test Asset'));
      expect(tappedHolding?.name, 'Test Asset');
    });

    testWidgets('displays loading indicator on load more button',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        hasMore: true,
        isLoading: true,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Show more assets'), findsNothing);
    });

    testWidgets('displays multiple holdings', (tester) async {
      await tester.pumpWidget(buildWidget(
        holdings: [
          createMockHolding(name: 'Asset 1', symbol: 'A1'),
          createMockHolding(name: 'Asset 2', symbol: 'A2'),
          createMockHolding(name: 'Asset 3', symbol: 'A3'),
        ],
        filteredCount: 3,
      ));

      expect(find.text('Asset 1'), findsOneWidget);
      expect(find.text('Asset 2'), findsOneWidget);
      expect(find.text('Asset 3'), findsOneWidget);
    });

    testWidgets('updates count badge with sleeve name', (tester) async {
      await tester.pumpWidget(buildWidget(
        selectedSleeveName: 'Equities',
        filteredCount: 12,
      ));

      expect(find.text('Equities \u00b7 12'), findsOneWidget);
    });

    testWidgets('displays correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BagholdrTheme.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AssetsSection(
                holdings: [createMockHolding()],
                totalCount: 32,
                filteredCount: 32,
                selectedSleeveName: 'All',
                searchQuery: '',
                onSearchChanged: (_) {},
                onLoadMore: () {},
                hasMore: false,
                onAssetTap: (_) {},
                isLoading: false,
              ),
            ),
          ),
        ),
      );

      // Values should display
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('iShares MSCI ACWI UCITS'), findsOneWidget);
    });
  });
}
