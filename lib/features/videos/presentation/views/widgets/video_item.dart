import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:watch_it/core/themes/app_colors.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/video_thumbnail.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/video_title.dart';


class VideoItem extends StatelessWidget {
  const VideoItem({
    super.key,
    required this.video,
    required this.onTap,
    this.layout = VideoItemLayout.list,
    this.highlightQuery = '',
  });

  final VideoModel video;
  final VoidCallback onTap;
  final VideoItemLayout layout;

  final String highlightQuery;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool compact = layout == VideoItemLayout.grid;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 32,
            spreadRadius: -8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.cardRadius),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppColors.cardRadius),
                splashColor: AppColors.primary.withValues(alpha: 0.14),
                highlightColor: AppColors.primary.withValues(alpha: 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    VideoThumbnail(video: video, compact: compact),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          14,
                          compact ? 10 : 14,
                          14,
                          compact ? 12 : 16,
                        ),
                        child: VideoTitle(
                          text: video.title,
                          query: highlightQuery,
                          style:
                              theme.textTheme.titleMedium?.copyWith(
                                fontSize: compact ? 14.5 : 16.5,
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                              ) ??
                              const TextStyle(fontSize: 16),
                          maxLines: compact ? 2 : 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum VideoItemLayout { list, grid }

