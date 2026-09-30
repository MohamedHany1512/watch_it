import 'package:equatable/equatable.dart';
import 'package:watch_it/core/errors/exceptions.dart';

/// Immutable data transfer object for a single video.
///
/// It replaces the old `List<Map<String, dynamic>>`: the fields are now typed,
/// the object is immutable, comparable and (de)serialisable to JSON.
class VideoModel extends Equatable {
  const VideoModel({
    required this.id,
    required this.title,
    this.duration,
    this.keywords = const <String>[],
  });

  /// Builds a [VideoModel] from a decoded JSON map.
  ///
  /// Throws [InvalidDataException] when the payload has an unexpected shape so
  /// the repository can translate it into a user facing failure.
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? title = json['title'];

    if (id is! String || id.isEmpty) {
      throw const InvalidDataException('Video "id" is missing or not a String');
    }
    if (title is! String) {
      throw const InvalidDataException('Video "title" is missing or not a String');
    }

    final Object? rawKeywords = json['keywords'];
    return VideoModel(
      id: id,
      title: title,
      duration: _parseDuration(json['durationSeconds']),
      keywords: rawKeywords is List
          ? rawKeywords.whereType<String>().toList(growable: false)
          : const <String>[],
    );
  }

  /// Accepts either ISO-8601 (`PT1H2M3S`, as returned by the YouTube API) or a
  /// plain number of seconds.
  static Duration? _parseDuration(Object? raw) {
    if (raw is int) return Duration(seconds: raw);
    if (raw is! String || raw.isEmpty) return null;

    if (raw.startsWith('PT') || raw.startsWith('P')) {
      final RegExp pattern = RegExp(
        r'(\d+)(H|M|S)',
        caseSensitive: false,
      );
      int seconds = 0;
      for (final RegExpMatch match in pattern.allMatches(raw)) {
        final int value = int.parse(match.group(1)!);
        seconds = switch (match.group(2)!.toUpperCase()) {
          'H' => seconds + (value * 3600),
          'M' => seconds + (value * 60),
          _ => seconds + value,
        };
      }
      return Duration(seconds: seconds);
    }

    final int? seconds = int.tryParse(raw);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  /// `1:05` / `1:02:03` badge label, or `null` when the duration is unknown.
  String? get formattedDuration {
    final Duration? value = duration;
    if (value == null) return null;

    final int totalSeconds = value.inSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$ss';
    }
    return '$minutes:$ss';
  }

  /// Parses a decoded JSON array into a list of [VideoModel].
  static List<VideoModel> listFromJson(List<dynamic> json) {
    return json
        .whereType<Map<String, dynamic>>()
        .map(VideoModel.fromJson)
        .toList(growable: false);
  }

  /// The YouTube video id (the part after `v=` in the watch url).
  final String id;

  /// Human readable title shown in the list and the app bar.
  final String title;

  /// Runtime badge shown on the thumbnail, e.g. `12:04`.
  ///
  /// Nullable: a duration is only known once the YouTube Data API provides
  /// `contentDetails.duration`, so the badge is simply hidden when absent.
  final Duration? duration;

  /// Thumbnail served by YouTube for this video.
  String get thumbnailUrl => 'https://img.youtube.com/vi/$id/0.jpg';

  /// Full watch url, handy for sharing / deep links.
  String get watchUrl => 'https://www.youtube.com/watch?v=$id';

  /// Everything the search engine may match against (title + synonyms).
  String get searchableText =>
      keywords.isEmpty ? title : '$title ${keywords.join(' ')}';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    if (duration != null) 'durationSeconds': duration!.inSeconds,
    if (keywords.isNotEmpty) 'keywords': keywords,
  };

  static List<Map<String, dynamic>> seedToJson() =>
      seedCatalogue.map((VideoModel video) => video.toJson()).toList(growable: false);

  /// The catalogue bundled with the application.
  ///
  /// https://www.youtube.com/watch?v=zSH15dIl7D0
  /// The part after `v=` is what we store in [id].
  ///
  /// A few English aliases are included on purpose so that searching in
  /// English also returns meaningful results for this Arabic catalogue.
  static const List<VideoModel> seedCatalogue = <VideoModel>[
    VideoModel(
      id: 'pUb9EW770d0',
      title: 'سورة الفاتحة',
      duration: Duration(minutes: 4, seconds: 12),
      keywords: <String>['fatiha', 'opening'],
    ),
    VideoModel(
      id: 'WhJU-XK0vB0',
      title: 'سورة البقرة',
      duration: Duration(hours: 1, minutes: 48, seconds: 5),
      keywords: <String>['baqara', 'cow'],
    ),
    VideoModel(
      id: 'TU6aL-om8FE',
      title: 'سورة الناس',
      duration: Duration(minutes: 6, seconds: 41),
      keywords: <String>['nas', 'people'],
    ),
    VideoModel(
      id: 'EVKeevUaGeU',
      title: 'سورة الفلق',
      duration: Duration(minutes: 3, seconds: 58),
      keywords: <String>['falaq', 'dawn'],
    ),
    VideoModel(
      id: 'L5E0L2I5lAU',
      title: 'سورة الاخلاص',
      duration: Duration(seconds: 52),
      keywords: <String>['ikhlas', 'sincerity'],
    ),
  ];

  /// Optional extra terms used for searching, never displayed.
  ///
  /// Keeping them in the *data* layer means the UI never has to know about
  /// synonyms, and they are serialised with the model.
  final List<String> keywords;

  @override
  List<Object?> get props => <Object?>[id, title];
}

