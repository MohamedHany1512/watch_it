import 'package:flutter/material.dart';
import 'package:watch_it/core/common/widgets/fade_slide_in.dart';
import 'package:watch_it/core/common/responsive.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/video_item.dart';


class VideosListView extends StatelessWidget {
  const VideosListView({
    super.key,
    required this.videos,
    required this.onVideoTap,
    this.highlightQuery = '',
    this.padding,
    this.stagger = true,
  });

  final List<VideoModel> videos;
  final void Function(VideoModel video) onVideoTap;
  final String highlightQuery;
  final EdgeInsets? padding;

  final bool stagger;

  static const Duration staggerStep = Duration(milliseconds: 55);

  static Duration delayFor(int index) => Duration(
    milliseconds: (index * staggerStep.inMilliseconds).clamp(0, 400),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = Breakpoints.gridColumnCount(constraints.maxWidth) > 1;
        final EdgeInsets insets =
            padding ?? Breakpoints.pagePadding(constraints.maxWidth);

        if (wide) {
          return _Grid(
            videos: videos,
            onVideoTap: onVideoTap,
            highlightQuery: highlightQuery,
            padding: insets,
            stagger: stagger,
          );
        }

        return _List(
          videos: videos,
          onVideoTap: onVideoTap,
          highlightQuery: highlightQuery,
          padding: insets,
          stagger: stagger,
        );
      },
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.videos,
    required this.onVideoTap,
    required this.highlightQuery,
    required this.padding,
    required this.stagger,
  });

  final List<VideoModel> videos;
  final void Function(VideoModel video) onVideoTap;
  final String highlightQuery;
  final EdgeInsets padding;
  final bool stagger;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      restorationId: 'videos-list',
      itemCount: videos.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 16),
      itemBuilder: (BuildContext context, int index) {
        final VideoModel video = videos[index];
        return FadeSlideIn(
          key: ValueKey<String>(video.id),
          delay: stagger ? VideosListView.delayFor(index) : Duration.zero,
          child: VideoItem(
            video: video,
            layout: VideoItemLayout.list,
            highlightQuery: highlightQuery,
            onTap: () => onVideoTap(video),
          ),
        );
      },
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.videos,
    required this.onVideoTap,
    required this.highlightQuery,
    required this.padding,
    required this.stagger,
  });

  final List<VideoModel> videos;
  final void Function(VideoModel video) onVideoTap;
  final String highlightQuery;
  final EdgeInsets padding;
  final bool stagger;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      restorationId: 'videos-grid',
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        // 16:9 thumbnail + a two line title block, with headroom so the card
        // never overflows whatever tile width the delegate computes.
        childAspectRatio: 1.15,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: videos.length,
      itemBuilder: (BuildContext context, int index) {
        final VideoModel video = videos[index];
        return FadeSlideIn(
          key: ValueKey<String>(video.id),
          delay: stagger ? VideosListView.delayFor(index) : Duration.zero,
          offset: const Offset(0, 0.08),
          child: VideoItem(
            video: video,
            layout: VideoItemLayout.grid,
            highlightQuery: highlightQuery,
            onTap: () => onVideoTap(video),
          ),
        );
      },
    );
  }
}
