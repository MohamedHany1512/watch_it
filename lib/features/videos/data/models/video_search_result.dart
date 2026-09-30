import 'package:equatable/equatable.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';

/// A single search hit, carrying its relevance score.
///
/// The score lets the UI explain *why* a result matched, and keeps the ordering
/// logic in one place instead of being duplicated across widgets.
class VideoSearchResult extends Equatable {
  const VideoSearchResult({required this.video, required this.score});

  final VideoModel video;

  /// `0` - `100`, the higher the better. See
  /// [AppTextNormalizer.score] for the full table.
  final int score;

  @override
  List<Object?> get props => <Object?>[video, score];
}
