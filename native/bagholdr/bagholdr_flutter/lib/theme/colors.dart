import 'package:flutter/material.dart';

/// Financial colors for the Bagholdr app.
///
/// Access via: `Theme.of(context).extension<FinancialColors>()!`
///
/// For dynamic category colors (sleeves, sectors, etc.), use the
/// [categoryPalette] and call [categoryColor] with an index.
@immutable
class FinancialColors extends ThemeExtension<FinancialColors> {
  const FinancialColors({
    required this.positive,
    required this.positiveBackground,
    required this.negative,
    required this.negativeBackground,
    required this.neutral,
    required this.chartValue,
    required this.chartCostBasis,
    required this.issueOver,
    required this.issueUnder,
    required this.issueStale,
    required this.issueSync,
    required this.categoryPalette,
  });

  /// Positive returns / gains (green)
  final Color positive;

  /// Background for positive values
  final Color positiveBackground;

  /// Negative returns / losses (red)
  final Color negative;

  /// Background for negative values
  final Color negativeBackground;

  /// Neutral / unchanged values
  final Color neutral;

  // Chart colors
  /// Chart value line (green)
  final Color chartValue;

  /// Chart cost basis line (grey dashed)
  final Color chartCostBasis;

  // Issue indicator colors
  /// Over allocation (orange)
  final Color issueOver;

  /// Under allocation (blue)
  final Color issueUnder;

  /// Stale prices (amber)
  final Color issueStale;

  /// Sync status (grey)
  final Color issueSync;

  /// Palette of distinguishable colors for categories (sleeves, sectors, etc.)
  ///
  /// Use [categoryColor] to get a color by index - it cycles through
  /// the palette if the index exceeds the palette length.
  final List<Color> categoryPalette;

  /// Get a category color by index.
  ///
  /// Cycles through the palette if index >= palette length.
  /// Use for sleeves, sectors, or any dynamic categorization.
  Color categoryColor(int index) {
    return categoryPalette[index % categoryPalette.length];
  }

  /// Light theme financial colors
  static const light = FinancialColors(
    positive: Color(0xFF16A34A), // green-600
    positiveBackground: Color(0xFFDCFCE7), // green-100
    negative: Color(0xFFDC2626), // red-600
    negativeBackground: Color(0xFFFEE2E2), // red-100
    neutral: Color(0xFF6B7280), // gray-500
    chartValue: Color(0xFF22C55E), // green-500
    chartCostBasis: Color(0xFF9CA3AF), // gray-400
    issueOver: Color(0xFFF97316), // orange-500
    issueUnder: Color(0xFF3B82F6), // blue-500
    issueStale: Color(0xFFF59E0B), // amber-500
    issueSync: Color(0xFF9CA3AF), // gray-400
    categoryPalette: _lightCategoryPalette,
  );

  /// Dark theme financial colors
  static const dark = FinancialColors(
    positive: Color(0xFF4ADE80), // green-400
    positiveBackground: Color(0xFF14532D), // green-900
    negative: Color(0xFFF87171), // red-400
    negativeBackground: Color(0xFF7F1D1D), // red-900
    neutral: Color(0xFF9CA3AF), // gray-400
    chartValue: Color(0xFF4ADE80), // green-400
    chartCostBasis: Color(0xFF6B7280), // gray-500
    issueOver: Color(0xFFFB923C), // orange-400
    issueUnder: Color(0xFF60A5FA), // blue-400
    issueStale: Color(0xFFFBBF24), // amber-400
    issueSync: Color(0xFF6B7280), // gray-500
    categoryPalette: _darkCategoryPalette,
  );

  @override
  FinancialColors copyWith({
    Color? positive,
    Color? positiveBackground,
    Color? negative,
    Color? negativeBackground,
    Color? neutral,
    Color? chartValue,
    Color? chartCostBasis,
    Color? issueOver,
    Color? issueUnder,
    Color? issueStale,
    Color? issueSync,
    List<Color>? categoryPalette,
  }) {
    return FinancialColors(
      positive: positive ?? this.positive,
      positiveBackground: positiveBackground ?? this.positiveBackground,
      negative: negative ?? this.negative,
      negativeBackground: negativeBackground ?? this.negativeBackground,
      neutral: neutral ?? this.neutral,
      chartValue: chartValue ?? this.chartValue,
      chartCostBasis: chartCostBasis ?? this.chartCostBasis,
      issueOver: issueOver ?? this.issueOver,
      issueUnder: issueUnder ?? this.issueUnder,
      issueStale: issueStale ?? this.issueStale,
      issueSync: issueSync ?? this.issueSync,
      categoryPalette: categoryPalette ?? this.categoryPalette,
    );
  }

  @override
  FinancialColors lerp(FinancialColors? other, double t) {
    if (other is! FinancialColors) return this;
    return FinancialColors(
      positive: Color.lerp(positive, other.positive, t)!,
      positiveBackground:
          Color.lerp(positiveBackground, other.positiveBackground, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeBackground:
          Color.lerp(negativeBackground, other.negativeBackground, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      chartValue: Color.lerp(chartValue, other.chartValue, t)!,
      chartCostBasis: Color.lerp(chartCostBasis, other.chartCostBasis, t)!,
      issueOver: Color.lerp(issueOver, other.issueOver, t)!,
      issueUnder: Color.lerp(issueUnder, other.issueUnder, t)!,
      issueStale: Color.lerp(issueStale, other.issueStale, t)!,
      issueSync: Color.lerp(issueSync, other.issueSync, t)!,
      // For palette, just use the target (no interpolation for lists)
      categoryPalette: t < 0.5 ? categoryPalette : other.categoryPalette,
    );
  }
}

/// Category palette for light theme.
/// 12 distinguishable colors that work well on light backgrounds.
/// Based on Tailwind's color palette (500 shades).
const _lightCategoryPalette = [
  Color(0xFF3B82F6), // blue-500
  Color(0xFFF59E0B), // amber-500
  Color(0xFF10B981), // emerald-500
  Color(0xFFF97316), // orange-500
  Color(0xFF8B5CF6), // violet-500
  Color(0xFFEC4899), // pink-500
  Color(0xFF06B6D4), // cyan-500
  Color(0xFFEF4444), // red-500
  Color(0xFF84CC16), // lime-500
  Color(0xFF6366F1), // indigo-500
  Color(0xFF14B8A6), // teal-500
  Color(0xFFA855F7), // purple-500
];

/// Category palette for dark theme.
/// Lighter shades (400) for better visibility on dark backgrounds.
const _darkCategoryPalette = [
  Color(0xFF60A5FA), // blue-400
  Color(0xFFFBBF24), // amber-400
  Color(0xFF34D399), // emerald-400
  Color(0xFFFB923C), // orange-400
  Color(0xFFA78BFA), // violet-400
  Color(0xFFF472B6), // pink-400
  Color(0xFF22D3EE), // cyan-400
  Color(0xFFF87171), // red-400
  Color(0xFFA3E635), // lime-400
  Color(0xFF818CF8), // indigo-400
  Color(0xFF2DD4BF), // teal-400
  Color(0xFFC084FC), // purple-400
];

/// Extension to easily access financial colors from BuildContext
extension FinancialColorsExtension on BuildContext {
  FinancialColors get financialColors =>
      Theme.of(this).extension<FinancialColors>()!;
}
