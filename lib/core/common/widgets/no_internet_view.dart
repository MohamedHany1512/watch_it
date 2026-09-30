import 'package:flutter/material.dart';
import 'package:watch_it/core/common/widgets/state_illustration.dart';
import 'package:watch_it/core/common/widgets/state_screen.dart';

/// Shared "you are offline" screen.
///
/// It is a `core` widget because connectivity is an app-wide concern, and it
/// holds no connectivity logic at all - the Cubit decides, this only renders.
class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key, this.onRetry});

  /// Invoked when the user taps "Try again" (the Cubit re-requests the data).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedStateScreen(
      child: StateScreen(
        illustration: StateIllustration.offline,
        title: 'No internet connection',
        message:
            'Check your Wi-Fi or mobile data, then try again. '
            'Your downloaded videos stay available offline.',
        actionLabel: 'Try again',
        onAction: onRetry,
      ),
    );
  }
}
