import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for app theme mode (light/dark/system).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Provider for privacy mode (hide/show balances).
final hideBalancesProvider = StateProvider<bool>((ref) => false);

/// Provider for currently selected portfolio ID.
///
/// Set by PortfolioListScreen when a portfolio is selected.
/// Used by other screens (e.g., SettingsScreen) to access current context.
final selectedPortfolioIdProvider = StateProvider<String?>((ref) => null);
