import 'package:watch_it/core/errors/exceptions.dart';
import 'package:watch_it/core/helper/cache_helper.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';

/// Contract of the *local* (offline) source of videos.
abstract class VideosCacheDataSource {
  /// Returns the cached catalogue, or an empty list when nothing was cached.
  List<VideoModel> getCachedVideos();

  /// Stores the catalogue for offline usage.
  Future<void> cacheVideos(List<VideoModel> videos);
}

class VideosCacheDataSourceImpl implements VideosCacheDataSource {
  const VideosCacheDataSourceImpl({required CacheHelper cacheHelper})
    : _cacheHelper = cacheHelper;

  final CacheHelper _cacheHelper;

  @override
  List<VideoModel> getCachedVideos() {
    try {
      final List<Map<String, dynamic>>? cached = _cacheHelper.getJsonList(
        CacheHelper.keyVideos,
      );
      if (cached == null || cached.isEmpty) return const <VideoModel>[];

      return cached.map(VideoModel.fromJson).toList(growable: false);
    } on InvalidDataException {
      // A single broken entry invalidates the whole cache entry.
      _cacheHelper.remove(CacheHelper.keyVideos);
      return const <VideoModel>[];
    } on CacheException {
      return const <VideoModel>[];
    }
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      await _cacheHelper.saveJsonList(
        CacheHelper.keyVideos,
        videos.map((VideoModel v) => v.toJson()).toList(growable: false),
      );
    } on CacheException {
      // Caching is a best-effort optimisation, never fail the request for it.
    }
  }
}
