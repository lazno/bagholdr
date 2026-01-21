import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

/// A collapsible issues bar that displays portfolio health indicators.
///
/// Shows a count badge and expands to reveal individual issues when tapped.
///
/// **Collapsed state**:
/// - Yellow background with badge showing issue count
/// - Text: "Issues need attention"
/// - Chevron (▶) indicating expandable
///
/// **Expanded state**:
/// - Chevron rotates 90°
/// - Panel slides down showing issue list
/// - Max height 160px, scrollable if more issues
///
/// Issue types and their dot colors:
/// - Over allocation: Orange (#f97316)
/// - Under allocation: Blue (#3b82f6)
/// - Stale prices: Amber (#f59e0b)
/// - Sync status: Grey (#9ca3af)
///
/// Usage:
/// ```dart
/// IssuesBar(
///   issues: [
///     Issue(type: IssueType.overAllocation, severity: IssueSeverity.warning,
///           message: 'Growth +5pp over target', color: '#fcd34d'),
///   ],
///   onIssueTap: (issue) => print('Tapped: ${issue.message}'),
/// )
/// ```
class IssuesBar extends StatefulWidget {
  const IssuesBar({
    super.key,
    required this.issues,
    this.onIssueTap,
  });

  /// List of issues to display.
  final List<Issue> issues;

  /// Callback when an issue item is tapped.
  final void Function(Issue issue)? onIssueTap;

  @override
  State<IssuesBar> createState() => _IssuesBarState();
}

class _IssuesBarState extends State<IssuesBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _expansionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.issues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Collapsed bar (always visible)
        _IssuesHeader(
          issueCount: widget.issues.length,
          rotationAnimation: _rotationAnimation,
          onTap: _toggleExpanded,
        ),
        // Expanded panel (animated)
        SizeTransition(
          sizeFactor: _expansionAnimation,
          child: _IssuesPanel(
            issues: widget.issues,
            onIssueTap: widget.onIssueTap,
          ),
        ),
      ],
    );
  }
}

/// The header bar showing issue count and toggle chevron.
class _IssuesHeader extends StatelessWidget {
  const _IssuesHeader({
    required this.issueCount,
    required this.rotationAnimation,
    required this.onTap,
  });

  final int issueCount;
  final Animation<double> rotationAnimation;
  final VoidCallback onTap;

  // Design colors from mockup
  static const _backgroundColor = Color(0xFFFFFBEB);
  static const _hoverColor = Color(0xFFFEF3C7);
  static const _borderColor = Color(0xFFFDE68A);
  static const _badgeColor = Color(0xFFFACC15);
  static const _badgeTextColor = Color(0xFF713F12);
  static const _textColor = Color(0xFF92400E);
  static const _chevronColor = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor,
      child: InkWell(
        onTap: onTap,
        hoverColor: _hoverColor,
        splashColor: _hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _borderColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Badge with count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$issueCount',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _badgeTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Text
              const Expanded(
                child: Text(
                  'Issues need attention',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textColor,
                  ),
                ),
              ),
              // Chevron with rotation animation
              RotationTransition(
                turns: rotationAnimation,
                child: const Text(
                  '▶',
                  style: TextStyle(
                    fontSize: 12,
                    color: _chevronColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The expanded panel showing individual issue items.
class _IssuesPanel extends StatelessWidget {
  const _IssuesPanel({
    required this.issues,
    this.onIssueTap,
  });

  final List<Issue> issues;
  final void Function(Issue issue)? onIssueTap;

  // Design colors from mockup
  static const _backgroundColor = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      constraints: const BoxConstraints(maxHeight: 160),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        itemCount: issues.length,
        itemBuilder: (context, index) {
          final issue = issues[index];
          final isLast = index == issues.length - 1;
          return _IssueItem(
            issue: issue,
            showBorder: !isLast,
            onTap: onIssueTap != null ? () => onIssueTap!(issue) : null,
          );
        },
      ),
    );
  }
}

/// Individual issue item with colored dot, message, and action text.
class _IssueItem extends StatelessWidget {
  const _IssueItem({
    required this.issue,
    required this.showBorder,
    this.onTap,
  });

  final Issue issue;
  final bool showBorder;
  final VoidCallback? onTap;

  // Design colors from mockup
  static const _textColor = Color(0xFF78350F);
  static const _borderColor = Color(0xFFFDE68A);
  static const _actionColor = Color(0xFFB45309);

  // Dot colors by issue type
  static const _overAllocationColor = Color(0xFFF97316); // Orange
  static const _underAllocationColor = Color(0xFF3B82F6); // Blue
  static const _stalePriceColor = Color(0xFFF59E0B); // Amber
  static const _syncStatusColor = Color(0xFF9CA3AF); // Grey

  Color _getDotColor() {
    // If the issue has a custom color (for allocation issues with sleeve color), use it
    if (issue.color != null && issue.color!.isNotEmpty) {
      return _parseHexColor(issue.color!);
    }

    // Otherwise use default colors by type
    switch (issue.type) {
      case IssueType.overAllocation:
        return _overAllocationColor;
      case IssueType.underAllocation:
        return _underAllocationColor;
      case IssueType.stalePrice:
        return _stalePriceColor;
      case IssueType.syncStatus:
        return _syncStatusColor;
    }
  }

  Color _parseHexColor(String hex) {
    final hexClean = hex.replaceFirst('#', '');
    if (hexClean.length == 6) {
      return Color(int.parse('FF$hexClean', radix: 16));
    }
    return _syncStatusColor; // Fallback
  }

  String _getActionText() {
    switch (issue.type) {
      case IssueType.overAllocation:
      case IssueType.underAllocation:
        return 'Rebalance →';
      case IssueType.stalePrice:
        return 'Refresh →';
      case IssueType.syncStatus:
        return 'Sync →';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: showBorder
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _borderColor, width: 1),
                ),
              )
            : null,
        child: Row(
          children: [
            // Colored dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _getDotColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Issue text
            Expanded(
              child: Text(
                issue.message,
                style: const TextStyle(
                  fontSize: 12,
                  color: _textColor,
                ),
              ),
            ),
            // Action text
            Text(
              _getActionText(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _actionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
