import 'package:dartz/dartz.dart';
import 'package:watch_it/core/errors/failure.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';
import 'package:watch_it/features/videos/data/models/video_search_result.dart';

/// Contract consumed by the presentation layer (Cubit / Views).
///
/// It returns an `Either<Failure, List<VideoModel>>` so callers **must** deal
/// with the failure branch - it is impossible to forget, unlike a nullable
/// return value or a thrown exception.
abstract class VideosRepository {
  /// Loads the catalogue of videos.
  ///
  /// - [Left] a [Failure] when the videos could not be loaded,
  /// - [Right] the list of videos (possibly served from the cache).
  Future<Either<Failure, List<VideoModel>>> getVideos();

  /// Searches [videos] for [query], Arabic or English.
  ///
  /// Results are **ranked by relevance** (exact match first, then prefix,
  /// token matches, then fuzzy matches). An empty [query] returns [videos]
  /// untouched, which lets the UI reset to the full catalogue with one call.
  List<VideoSearchResult> searchVideos({
    required String query,
    required List<VideoModel> videos,
  });

  /// Lightweight connectivity probe used before opening a video.
  Future<bool> hasInternetConnection();
}

