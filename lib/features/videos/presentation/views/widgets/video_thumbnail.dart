import 'package:flutter/material.dart';
import 'package:watch_it/core/themes/app_colors.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';

class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({
    super.key,
    required this.video,
    this.compact = false,
  });

  final VideoModel video;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String? duration = video.formattedDuration;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          VideoThumbnailImage(video: video),


          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Color(0xB3000000)],
                stops: <double>[0.45, 1],
              ),
            ),
          ),

          Center(child: PlayButton(compact: compact)),

          if (duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: DurationBadge(label: duration),
            ),
        ],
      ),
    );
  }
}

class DurationBadge extends StatelessWidget {
  const DurationBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.schedule_rounded, size: 11, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The glowing play button, animated in with a subtle overshoot.
class PlayButton extends StatelessWidget {
  const PlayButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double value, Widget? child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        // Soft radial "play" glow behind the badge.
        padding: EdgeInsets.all(compact ? 5 : 7),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              AppColors.youtubeRed.withValues(alpha: 0.45),
              AppColors.youtubeRed.withValues(alpha: 0),
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(compact ? 9 : 13),
          decoration: BoxDecoration(
            color: AppColors.youtubeRed,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.white,
            size: compact ? 24 : 32,
          ),
        ),
      ),
    );
  }
}


/// Network image with a cross-fade and a branded failure fallback.
class VideoThumbnailImage extends StatelessWidget {
  const VideoThumbnailImage({super.key, required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      video.thumbnailUrl,
      fit: BoxFit.cover,
      semanticLabel: video.title,
      // Fade the real image in so list scrolling never looks glitchy.
      frameBuilder:
          (
            BuildContext context,
            Widget child,
            int? frame,
            bool wasSynchronouslyLoaded,
          ) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              child: child,
            );
          },
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? progress,
          ) {
            if (progress == null) return child;
            return const ColoredBox(
              color: AppColors.surfaceMuted,
              child: SizedBox.expand(),
            );
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return _ThumbnailFallback(title: video.title);
          },
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.image_not_supported_outlined,
              size: 34,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
