import 'package:flutter/material.dart';
import 'package:watch_it/core/themes/app_colors.dart';

/// Centred progress indicator, used for short blocking waits.
///
/// Long waits use the shimmering `SkeletonVideoCard` placeholders instead -
/// a bare spinner reads as "something is broken", a skeleton reads as
/// "content is coming".
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.message, this.size = 34});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 2.6,
              color: AppColors.primaryLight,
            ),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
