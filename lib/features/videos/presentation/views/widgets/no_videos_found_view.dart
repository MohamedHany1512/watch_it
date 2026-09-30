import 'package:flutter/material.dart';
import 'package:watch_it/core/common/widgets/state_illustration.dart';
import 'package:watch_it/core/common/widgets/state_screen.dart';
import 'package:watch_it/core/themes/app_colors.dart';

class NoVideosFoundView extends StatelessWidget {
  const NoVideosFoundView({
    super.key,
    this.query = '',
    this.onClearSearch,
  });

  final String query;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    return AnimatedStateScreen(
      child: StateScreen(
        illustration: StateIllustration.emptySearch,
        title: 'No videos found',
        message: query.isEmpty
            ? 'There is nothing to watch yet. Pull to refresh in a moment.'
            : 'Nothing matched that search. Spelling variants and Arabic '
                  'diacritics are ignored, so double-check the keywords.',
        actionLabel: onClearSearch == null ? null : 'Clear search',
        onAction: onClearSearch,
      ),
    );
  }
}

class NoVideosFoundCompact extends StatelessWidget {
  const NoVideosFoundCompact({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const StateIllustrationView(
              illustration: StateIllustration.emptySearch,
              size: 140,
            ),
            const SizedBox(height: 22),
            Text(
              'No videos found',
              style: theme.textTheme.titleMedium,
            ),
            if (query.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  '“$query”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
