import 'package:dartz/dartz.dart';
import 'package:watch_it/core/errors/exceptions.dart';
import 'package:watch_it/core/errors/failure.dart';
import 'package:watch_it/core/network/network_info.dart';
import 'package:watch_it/features/videos/data/datasources/videos_cache_data_source.dart';
import 'package:watch_it/features/videos/data/datasources/videos_remote_data_source.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';
import 'package:watch_it/core/common/helpers/text_normalizer.dart';
import 'package:watch_it/features/videos/data/models/video_search_result.dart';
import 'package:watch_it/features/videos/data/repos/videos_repository.dart';

/// The single place where the *data sources* are orchestrated.
///
/// This is where "what happens if X fails?" lives - previously that logic was
/// duplicated all over the widgets.
class VideosRepositoryImpl implements VideosRepository {
  const VideosRepositoryImpl({
    required VideosRemoteDataSource remoteDataSource,
    required VideosCacheDataSource cacheDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _cacheDataSource = cacheDataSource,
       _networkInfo = networkInfo;

  final VideosRemoteDataSource _remoteDataSource;
  final VideosCacheDataSource _cacheDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<VideoModel>>> getVideos() async {
    if (!await _networkInfo.isConnected) {
      // Offline: serve the cache if we have one, otherwise tell the user.
      final List<VideoModel> cached = _cacheDataSource.getCachedVideos();
      if (cached.isNotEmpty) return Right<Failure, List<VideoModel>>(cached);
      return const Left<Failure, List<VideoModel>>(
        NoInternetConnectionFailure(),
      );
    }

    try {
      final List<VideoModel> videos = await _remoteDataSource.getVideos();
      if (videos.isEmpty) {
        return const Right<Failure, List<VideoModel>>(<VideoModel>[]);
      }
      await _cacheDataSource.cacheVideos(videos);
      return Right<Failure, List<VideoModel>>(videos);
    } on NoInternetConnectionException catch (e) {
      return _fallbackToCacheOrFailure(
        NoInternetConnectionFailure(e.message),
      );
    } on ServerException catch (e) {
      return _fallbackToCacheOrFailure(
        ServerFailure(e.message, code: e.code),
      );
    } on InvalidDataException catch (e) {
      return _fallbackToCacheOrFailure(InvalidDataFailure(e.message));
    } on CacheException catch (e) {
      return _fallbackToCacheOrFailure(CacheFailure(e.message));
    } catch (e) {
      return _fallbackToCacheOrFailure(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasInternetConnection() => _networkInfo.isConnected;

  @override
  List<VideoSearchResult> searchVideos({
    required String query,
    required List<VideoModel> videos,
  }) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      // An empty query means "show everything", preserving the original order.
      return videos
          .map(
            (VideoModel video) =>
                VideoSearchResult(video: video, score: 0),
          )
          .toList(growable: false);
    }

    final List<VideoSearchResult> results = <VideoSearchResult>[];

    for (final VideoModel video in videos) {
      // The title is the strongest signal, the synonyms only break ties.
      final int titleScore = AppTextNormalizer.score(video.title, trimmed);
      final int keywordScore = video.keywords.isEmpty
          ? 0
          : video.keywords
                .map((String k) => AppTextNormalizer.score(k, trimmed))
                .fold<int>(0, (int best, int value) => value > best ? value : best);

      // Keywords are worth at most a "contains" match so an exact title hit is
      // always ranked above a synonym hit.
      final int finalScore = titleScore > 0
          ? titleScore
          : (keywordScore > 39 ? 30 : keywordScore);

      if (finalScore > 0) {
        results.add(VideoSearchResult(video: video, score: finalScore));
      }
    }

    // Best score first; ties keep the original catalogue order (stable sort).
    results.sort((VideoSearchResult a, VideoSearchResult b) {
      return b.score.compareTo(a.score);
    });

    return List<VideoSearchResult>.unmodifiable(results);
  }

  /// Stale-but-usable beats showing the user an error screen.
  Either<Failure, List<VideoModel>> _fallbackToCacheOrFailure(Failure failure) {
    final List<VideoModel> cached = _cacheDataSource.getCachedVideos();
    if (cached.isNotEmpty) return Right<Failure, List<VideoModel>>(cached);
    return Left<Failure, List<VideoModel>>(failure);
  }
}
