import 'package:equatable/equatable.dart';
import 'package:watch_it/core/errors/failure.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';

/// The complete set of states the videos feature can be in.
///
/// Modelled as a `sealed` hierarchy so the UI can `switch` over it and the
/// compiler guarantees that every possible state is handled.
sealed class VideoState extends Equatable {
  const VideoState();

  /// Nothing has been requested yet.
  const factory VideoState.initial() = VideoInitial;

  /// A request is in flight - show a progress indicator.
  const factory VideoState.loading() = VideoLoading;

  /// Videos are available. [query] is non empty while searching.
  factory VideoState.success({
    required List<VideoModel> videos,
    String query = '',
  }) => VideoSuccess(videos: videos, query: query);

  /// The (optional) [query] returned no result.
  factory VideoState.empty({String query = ''}) => VideoNoVideosFound(query: query);

  /// A search is in flight (debouncing or filtering).
  factory VideoState.searchLoading({
    required String query,
    List<VideoModel> previousVideos = const <VideoModel>[],
  }) => VideoSearchLoading(query: query, previousVideos: previousVideos);

  /// The search returned results.
  factory VideoState.searchSuccess({
    required List<VideoModel> videos,
    String query = '',
  }) => VideoSearchSuccess(videos: videos, query: query);

  /// The search returned nothing.
  factory VideoState.searchEmpty({String query = ''}) => VideoSearchEmpty(query: query);

  /// Something went wrong while loading.
  const factory VideoState.failure(Failure failure) = VideoError;

  /// The device is offline and there is no cache to fall back on.
  const factory VideoState.noInternetConnection() = VideoNoInternetConnection;
}

/// Nothing has been requested yet.
final class VideoInitial extends VideoState {
  const VideoInitial();

  @override
  List<Object?> get props => const <Object?>[];
}

/// A request is in flight.
final class VideoLoading extends VideoState {
  const VideoLoading();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Videos are available.
final class VideoSuccess extends VideoState {
  const VideoSuccess({required this.videos, this.query = ''});

  final List<VideoModel> videos;

  /// The active search term, empty when the full list is shown.
  final String query;

  bool get isFiltered => query.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[videos, query];
}

/// The active search term returned nothing.
final class VideoNoVideosFound extends VideoState {
  const VideoNoVideosFound({this.query = ''});

  final String query;

  bool get isFiltered => query.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[query];
}

/// A technical failure that the user should know about.
final class VideoError extends VideoState {
  const VideoError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

/// The device is offline.
final class VideoNoInternetConnection extends VideoState {
  const VideoNoInternetConnection();

  @override
  List<Object?> get props => const <Object?>[];
}

/// A search is being debounced / executed.
///
/// [previousVideos] keeps the previous result set so the UI can keep rendering
/// the list (dimmed, with a progress bar) instead of flashing a spinner on
/// every keystroke.
final class VideoSearchLoading extends VideoState {
  const VideoSearchLoading({
    required this.query,
    this.previousVideos = const <VideoModel>[],
  });

  final String query;
  final List<VideoModel> previousVideos;

  bool get hasPreviousResults => previousVideos.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[query, previousVideos];
}

/// The search returned at least one result.
final class VideoSearchSuccess extends VideoState {
  const VideoSearchSuccess({required this.videos, this.query = ''});

  final List<VideoModel> videos;
  final String query;

  bool get isFiltered => query.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[videos, query];
}

/// The search returned no result for [query].
final class VideoSearchEmpty extends VideoState {
  const VideoSearchEmpty({this.query = ''});

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

