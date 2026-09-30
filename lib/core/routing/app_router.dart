import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_it/core/routing/routes.dart';
import 'package:watch_it/core/services/service_locator.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';
import 'package:watch_it/features/videos/presentation/cubit/video_cubit.dart';
import 'package:watch_it/features/videos/presentation/views/home_page.dart';
import 'package:watch_it/features/videos/presentation/views/video_player_page.dart';

abstract final class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => BlocProvider<VideoCubit>(
          // `..getVideos()` kicks off the very first request.
          create: (_) => getIt<VideoCubit>()..getVideos(),
          child: const HomePage(),
        ),
      ),
      AppRoutes.videoPlayer => _videoPlayerRoute(settings),
      _ => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _UnknownRouteView(),
      ),
    };
  }

  static Route<dynamic> _videoPlayerRoute(RouteSettings settings) {
    final Object? arguments = settings.arguments;

    if (arguments is! VideoModel) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _UnknownRouteView(
          title: 'Invalid arguments',
          message: 'A VideoModel is required to open this screen.',
        ),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => VideoPlayerPage(video: arguments),
    );
  }
}

class _UnknownRouteView extends StatelessWidget {
  const _UnknownRouteView({
    this.title = 'Page not found',
    this.message = 'The page you are looking for does not exist.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WatchIt')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 72),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
