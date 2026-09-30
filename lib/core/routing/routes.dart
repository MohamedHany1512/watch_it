/// Single source of truth for every named route of the app.
///
/// Widgets never import `MaterialPageRoute`; they call
/// `Navigator.pushNamed(context, AppRoutes.videoPlayer, arguments: video)`.
abstract final class AppRoutes {
  /// The video catalogue.
  static const String home = '/';

  /// The YouTube player. Expects a `VideoModel` as route argument.
  static const String videoPlayer = '/video-player';

  /// Fallback for unknown routes.
  static const String notFound = '/not-found';
}
