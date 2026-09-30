import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_it/core/errors/failure.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';
import 'package:watch_it/features/videos/data/models/video_search_result.dart';
import 'package:watch_it/features/videos/data/repos/videos_repository.dart';
import 'package:watch_it/features/videos/presentation/cubit/video_state.dart';

/// Owns **all** business logic of the videos feature:
/// loading, failure mapping and search filtering.
///
/// The widgets know nothing about the repository, failures or filtering - they
/// only render a [VideoState] and forward user intents back to this cubit.
class VideoCubit extends Cubit<VideoState> {
  VideoCubit({
    required VideosRepository videosRepository,
    Duration searchDebounce = defaultSearchDebounce,
  }) : _videosRepository = videosRepository,
       _searchDebounce = searchDebounce,
       super(const VideoState.initial());

  /// Typing "surat" should not trigger 5 searches - only the settled value.
  static const Duration defaultSearchDebounce = Duration(milliseconds: 300);

  final VideosRepository _videosRepository;
  final Duration _searchDebounce;

  /// The unfiltered catalogue, kept so search can be re-applied instantly
  /// without hitting the repository again.
  List<VideoModel> _catalogue = const <VideoModel>[];

  /// The last emitted result set, used to keep the list visible while a new
  /// search is being debounced.
  List<VideoModel> _lastResults = const <VideoModel>[];

  Timer? _searchDebounceTimer;

  /// The active search term, exposed so the UI can restore the field content.
  String get currentQuery => switch (state) {
    VideoSearchLoading(:final query) => query,
    VideoSearchSuccess(:final query) => query,
    VideoSearchEmpty(:final query) => query,
    _ => '',
  };

  /// Loads the videos. Safe to call again for a "retry".
  Future<void> getVideos() async {
    if (isClosed) return;
    _cancelPendingSearch();
    emit(const VideoState.loading());

    final Either<Failure, List<VideoModel>> result = await _videosRepository
        .getVideos();
    if (isClosed) return;

    result.fold(_emitFailure, _emitSuccess);
  }

  /// Debounced entry point, wired to the search field `onChanged`.
  ///
  /// Each call cancels the previous timer, so only the last keystroke of a
  /// "burst" actually runs a search.
  void searchVideos(String query) {
    if (isClosed) return;
    _cancelPendingSearch();

    final String trimmed = query.trim();

    // Clearing the field restores the full catalogue immediately, there is
    // nothing to debounce.
    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    emit(
      VideoState.searchLoading(
        query: trimmed,
        previousVideos: _lastResults,
      ),
    );

    _searchDebounceTimer = Timer(
      _searchDebounce,
      () => _performSearch(trimmed),
    );
  }

  /// Runs the search right away - used by the keyboard "search" action, which
  /// should not wait for the debounce.
  void searchVideosImmediately(String query) {
    if (isClosed) return;
    _cancelPendingSearch();

    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }
    _performSearch(trimmed);
  }

  /// Restores the full catalogue and resets the search.
  void clearSearch() {
    if (_catalogue.isEmpty || isClosed) return;
    _cancelPendingSearch();

    _lastResults = _catalogue;
    emit(VideoState.success(videos: _catalogue));
  }

  /// Probes connectivity before opening a video, so the user gets a snack bar
  /// instead of a black player screen.
  Future<bool> canOpenVideo() async {
    if (isClosed) return false;
    return _videosRepository.hasInternetConnection();
  }

  @override
  Future<void> close() {
    // A pending timer firing after close() would throw.
    _cancelPendingSearch();
    return super.close();
  }

  void _performSearch(String query) {
    if (isClosed) return;

    final List<VideoSearchResult> results = _videosRepository.searchVideos(
      query: query,
      videos: _catalogue,
    );

    final List<VideoModel> matches = results
        .map((VideoSearchResult result) => result.video)
        .toList(growable: false);

    _lastResults = matches;

    emit(
      matches.isEmpty
          ? VideoState.searchEmpty(query: query)
          : VideoState.searchSuccess(videos: matches, query: query),
    );
  }

  void _cancelPendingSearch() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
  }

  void _emitSuccess(List<VideoModel> videos) {
    _catalogue = List<VideoModel>.unmodifiable(videos);
    _lastResults = _catalogue;
    emit(
      _catalogue.isEmpty
          ? VideoState.empty()
          : VideoState.success(videos: _catalogue),
    );
  }

  void _emitFailure(Failure failure) {
    emit(
      switch (failure) {
        NoInternetConnectionFailure() => const VideoState.noInternetConnection(),
        _ => VideoState.failure(failure),
      },
    );
  }
}
