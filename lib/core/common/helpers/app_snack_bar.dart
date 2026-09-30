import 'package:flutter/material.dart';

/// Helpers to display feedback without repeating `ScaffoldMessenger.of(context)`
/// all over the widgets.
abstract final class AppSnackBar {
  /// Shows an error style snack bar.
  static void showError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    show(
      context,
      message: message,
      onRetry: onRetry,
    );
  }

  /// Shows a neutral snack bar, tinted with the error colour when the user is
  /// offered a retry action.
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool isError = onRetry != null;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // `margin` is only valid with a floating behaviour, so it must be
          // set explicitly here and not only through the theme.
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(15),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : null,
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          action: isError
              ? SnackBarAction(label: 'Retry', onPressed: onRetry)
              : null,
        ),
      );
  }
}
