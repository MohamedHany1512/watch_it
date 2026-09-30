import 'package:flutter/material.dart';
import 'package:watch_it/core/common/responsive.dart';
import 'package:watch_it/core/common/widgets/shimmer.dart';
import 'package:watch_it/core/themes/app_colors.dart';


class VideosListSkeleton extends StatelessWidget {
  const VideosListSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = Breakpoints.gridColumnCount(constraints.maxWidth) > 1;
        final EdgeInsets insets = Breakpoints.pagePadding(
          constraints.maxWidth,
        );

        if (wide) {
          return GridView.builder(
            padding: insets,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              childAspectRatio: 1.15,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) =>
                const SkeletonVideoCard(compact: true),
          );
        }

        return ListView.separated(
          padding: insets,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 16),
          itemBuilder: (BuildContext context, int index) =>
              const SkeletonVideoCard(compact: false),
        );
      },
    );
  }
}

/// A single shimmering video card placeholder.
class SkeletonVideoCard extends StatelessWidget {
  const SkeletonVideoCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 16:9 thumbnail placeholder, matching the real card.
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: Shimmer(child: SizedBox.expand()),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              compact ? 10 : 14,
              14,
              compact ? 12 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                ShimmerBox(height: 13, borderRadius: BorderRadius.all(Radius.circular(7))),
                SizedBox(height: 9),
                ShimmerBox(
                  height: 13,
                  width: 160,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
