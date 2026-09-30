import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_it/core/common/helpers/app_snack_bar.dart';
import 'package:watch_it/core/common/widgets/app_error_view.dart';
import 'package:watch_it/core/common/widgets/glass_surface.dart';
import 'package:watch_it/core/common/widgets/no_internet_view.dart';
import 'package:watch_it/core/routing/routes.dart';
import 'package:watch_it/core/themes/app_colors.dart';
import 'package:watch_it/core/themes/app_theme.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';
import 'package:watch_it/features/videos/presentation/cubit/video_cubit.dart';
import 'package:watch_it/features/videos/presentation/cubit/video_state.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/floating_search_bar.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/no_videos_found_view.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/search_results_header.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/videos_list_skeleton.dart';
import 'package:watch_it/features/videos/presentation/views/widgets/videos_list_view.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<VideoCubit>().clearSearch();
  }

  Future<void> _openVideo(VideoModel video) async {
    final VideoCubit cubit = context.read<VideoCubit>();

    final bool canPlay = await cubit.canOpenVideo();
    if (!mounted) return;

    if (!canPlay) {
      AppSnackBar.show(context, message: 'No internet connection');
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.videoPlayer, arguments: video);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemOverlay,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            // The ambient glow layer sits behind *everything*.
            const Positioned.fill(child: AmbientBackground()),

            BlocConsumer<VideoCubit, VideoState>(
              listenWhen: (VideoState previous, VideoState current) =>
                  current is VideoError,
              listener: (BuildContext context, VideoState state) {
                if (state is VideoError) {
                  AppSnackBar.showError(context, message: state.failure.message);
                }
              },
              builder: (BuildContext context, VideoState state) =>
                  _buildBody(context, state),
            ),

            // Floating glass bar, pinned above the scrolling content.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const BrandHeader(),
                      const SizedBox(height: 12),
                      FloatingSearchBar(
                        controller: _searchController,
                        onChanged: context.read<VideoCubit>().searchVideos,
                        onSubmitted: context
                            .read<VideoCubit>()
                            .searchVideosImmediately,
                        onClear: _clearSearch,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBody(BuildContext context, VideoState state) {
    final VideoCubit cubit = context.read<VideoCubit>();

    const double headerSpace = 176;

    final Widget content = switch (state) {
      VideoInitial() => const VideosListSkeleton(),

      VideoLoading() => const VideosListSkeleton(),

      VideoNoInternetConnection() => NoInternetView(onRetry: cubit.getVideos),

      VideoError(:final failure) => AppErrorView(
        message: failure.message,
        onRetry: cubit.getVideos,
      ),

      VideoSearchLoading(:final previousVideos) => Column(
        children: <Widget>[
          SearchResultsHeader(
            query: cubit.currentQuery,
            resultCount: previousVideos.length,
            isLoading: true,
          ),
          Expanded(
            child: previousVideos.isEmpty
                ? const VideosListSkeleton(itemCount: 4)
                : Opacity(
                    opacity: 0.5,
                    child: VideosListView(
                      videos: previousVideos,
                      onVideoTap: _openVideo,
                      // Suppress the stagger: these items are already on
                      // screen, they must not re-animate on every keystroke.
                      stagger: false,
                    ),
                  ),
          ),
        ],
      ),

      VideoSearchSuccess(:final videos, :final query) => Column(
        children: <Widget>[
          SearchResultsHeader(query: query, resultCount: videos.length),
          Expanded(
            child: VideosListView(
              videos: videos,
              highlightQuery: query,
              onVideoTap: _openVideo,
            ),
          ),
        ],
      ),

      VideoSearchEmpty(:final query) => NoVideosFoundView(
        query: query,
        onClearSearch: _clearSearch,
      ),

      VideoSuccess(:final videos) => VideosListView(
        videos: videos,
        onVideoTap: _openVideo,
      ),

      VideoNoVideosFound() => const NoVideosFoundView(),
    };

    return Padding(
      // Push the content below the floating bar.
      padding: const EdgeInsets.only(top: headerSpace),
      child: content,
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        // Gradient "play" mark.
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.primary, AppColors.accentWarm],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'WatchIt',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        GlassSurface(
          borderRadius: 14,
          blur: 18,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.wifi_tethering_rounded,
                size: 15,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'Online',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
