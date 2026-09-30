import 'package:flutter/widgets.dart';

/// Layout breakpoints following the Material 3 window size classes.
abstract final class Breakpoints {
  const Breakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1240;

  /// Below this width a single column is used (phones).
  static bool isCompact(double width) => width < compact;

  /// Phones in landscape and small tablets.
  static bool isMedium(double width) =>
      width >= compact && width < expanded;

  /// Large tablets and desktop.
  static bool isExpanded(double width) => width >= expanded;

  /// Maximum number of columns a video grid may use.
  ///
  /// Keeps line length readable instead of stretching cards forever.
  static int gridColumnCount(double width, {double minTileWidth = 280}) {
    if (width <= 0) return 1;
    final int columns = (width / minTileWidth).floor();
    return columns.clamp(1, 4);
  }

  /// Horizontal page padding, scaled with the available width.
  static EdgeInsets pagePadding(double width) {
    if (width >= expanded) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    if (width >= medium) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  }

  /// Maximum width of the content, so text never becomes unreadable wide.
  static double maxContentWidth(double width) {
    if (width >= expanded) return 1200;
    if (width >= medium) return 900;
    return width;
  }
}

/// Convenience builder that exposes the current constraints to [builder].
///
/// Using this instead of `MediaQuery.of(context).size` means the layout reacts
/// correctly inside dialogs, split views and during orientation changes.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return builder(context, constraints);
      },
    );
  }
}
