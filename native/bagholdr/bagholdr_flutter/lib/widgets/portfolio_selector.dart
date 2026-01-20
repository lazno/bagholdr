import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

/// A dropdown-style selector for choosing the active portfolio.
///
/// Adapts to screen size:
/// - **Web/Desktop (wide screens)**: Shows a popup menu dropdown
/// - **Mobile (narrow screens)**: Shows a bottom sheet
///
/// Matches the mockup header design:
/// ```
/// ┌─────────────────────────────────────────┐
/// │ ☰  Main Portfolio ▼          👁  🟢    │
/// └─────────────────────────────────────────┘
/// ```
class PortfolioSelector extends StatelessWidget {
  const PortfolioSelector({
    super.key,
    required this.portfolios,
    required this.selected,
    required this.onChanged,
  });

  /// List of available portfolios.
  final List<Portfolio> portfolios;

  /// Currently selected portfolio.
  final Portfolio selected;

  /// Called when user selects a different portfolio.
  final ValueChanged<Portfolio> onChanged;

  /// Breakpoint for switching between mobile and desktop UX.
  /// Below this width: bottom sheet. Above: dropdown menu.
  static const double _mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useMobileUX = screenWidth < _mobileBreakpoint;

    if (useMobileUX) {
      return _MobileSelector(
        portfolios: portfolios,
        selected: selected,
        onChanged: onChanged,
      );
    } else {
      return _DesktopSelector(
        portfolios: portfolios,
        selected: selected,
        onChanged: onChanged,
      );
    }
  }
}

/// Desktop/web version using PopupMenuButton for a real dropdown.
class _DesktopSelector extends StatelessWidget {
  const _DesktopSelector({
    required this.portfolios,
    required this.selected,
    required this.onChanged,
  });

  final List<Portfolio> portfolios;
  final Portfolio selected;
  final ValueChanged<Portfolio> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Portfolio>(
      initialValue: selected,
      onSelected: (portfolio) {
        if (portfolio.id != selected.id) {
          onChanged(portfolio);
        }
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      itemBuilder: (context) => portfolios.map((portfolio) {
        final isSelected = portfolio.id == selected.id;
        return PopupMenuItem<Portfolio>(
          value: portfolio,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      portfolio.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Band tolerance: ${portfolio.bandRelativeTolerance.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile version using bottom sheet for better touch UX.
class _MobileSelector extends StatelessWidget {
  const _MobileSelector({
    required this.portfolios,
    required this.selected,
    required this.onChanged,
  });

  final List<Portfolio> portfolios;
  final Portfolio selected;
  final ValueChanged<Portfolio> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPortfolioSheet(context),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showPortfolioSheet(BuildContext context) {
    showModalBottomSheet<Portfolio>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _PortfolioBottomSheet(
        portfolios: portfolios,
        selected: selected,
        onSelected: (portfolio) {
          Navigator.pop(context);
          if (portfolio.id != selected.id) {
            onChanged(portfolio);
          }
        },
      ),
    );
  }
}

/// Bottom sheet content showing the list of portfolios (mobile only).
class _PortfolioBottomSheet extends StatelessWidget {
  const _PortfolioBottomSheet({
    required this.portfolios,
    required this.selected,
    required this.onSelected,
  });

  final List<Portfolio> portfolios;
  final Portfolio selected;
  final ValueChanged<Portfolio> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select Portfolio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Divider(height: 1),
          // Portfolio list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: portfolios.length,
              itemBuilder: (context, index) {
                final portfolio = portfolios[index];
                final isSelected = portfolio.id == selected.id;

                return ListTile(
                  title: Text(
                    portfolio.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'Band tolerance: ${portfolio.bandRelativeTolerance.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                        )
                      : null,
                  onTap: () => onSelected(portfolio),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
