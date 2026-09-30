import 'package:flutter/material.dart';
import 'package:watch_it/core/common/responsive.dart';
import 'package:watch_it/core/common/widgets/state_illustration.dart';
import 'package:watch_it/core/themes/app_colors.dart';

/// Shared layout for every "nothing to show" screen: animated illustration,
/// title, message and an optional call to action.
///
/// Fading the whole thing in on a curve is what makes an empty state feel
/// intentional rather than like a rendering failure.
class StateScreen extends StatelessWidget {
  const StateScreen({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondaryAction,
    this.illustrationSize = 168,
  });

  final StateIllustration illustration;
  final String title;
  final String message;

  /// Primary call to action, e.g. "Retry".
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Secondary, lower emphasis action, e.g. "Clear search".
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  final double illustrationSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.sizeOf(context).width;

    return Center(
      child: SingleChildScrollView(
        padding: Breakpoints.pagePadding(width) + const EdgeInsets.symmetric(vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Illustration scales down gracefully on small phones.
              StateIllustrationView(
                illustration: illustration,
                size: illustrationSize.clamp(120, width * 0.42),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (onAction != null && actionLabel != null) ...<Widget>[
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(actionLabel!),
                ),
              ],
              if (onSecondaryAction != null && secondaryLabel != null) ...<Widget>[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades + slides a [StateScreen] in when it first appears.
class AnimatedStateScreen extends StatefulWidget {
  const AnimatedStateScreen({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedStateScreen> createState() => _AnimatedStateScreenState();
}

class _AnimatedStateScreenState extends State<AnimatedStateScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}

/// Accent colour associated with an illustration.
Color stateAccent(StateIllustration illustration) => switch (illustration) {
  StateIllustration.emptySearch => AppColors.primaryLight,
  StateIllustration.offline => AppColors.warning,
  StateIllustration.error => AppColors.error,
};
