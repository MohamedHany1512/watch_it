import 'package:flutter/material.dart';
import 'package:watch_it/core/themes/app_colors.dart';


class SearchResultsHeader extends StatelessWidget {
  const SearchResultsHeader({
    super.key,
    required this.query,
    required this.resultCount,
    this.isLoading = false,
  });

  final String query;
  final int resultCount;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String label = _label();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    label,
                    key: ValueKey<String>(label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        // Indeterminate bar pinned to the top edge of the results.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoading
              ? const LinearProgressIndicator(
                  key: ValueKey<String>('search-progress'),
                  minHeight: 2,
                  color: AppColors.primaryLight,
                  backgroundColor: AppColors.surfaceMuted,
                )
              : const SizedBox(
                  key: ValueKey<String>('search-idle'),
                  height: 2,
                ),
        ),
      ],
    );
  }

  String _label() {
    if (resultCount == 0) return 'No results for "$query"';
    if (resultCount == 1) return '1 result for "$query"';
    return '$resultCount results for "$query"';
  }
}
