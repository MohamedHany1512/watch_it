import 'package:flutter/material.dart';
import 'package:watch_it/core/common/widgets/state_illustration.dart';
import 'package:watch_it/core/common/widgets/state_screen.dart';

/// Generic error screen with a retry affordance.
///
/// Renders *any* failure message, so the page does not need to know about
/// server errors, cache errors, ...
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
    this.illustration = StateIllustration.error,
  });

  final String message;
  final String title;
  final StateIllustration illustration;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedStateScreen(
      child: StateScreen(
        illustration: illustration,
        title: title,
        message: message,
        actionLabel: 'Try again',
        onAction: onRetry,
      ),
    );
  }
}
