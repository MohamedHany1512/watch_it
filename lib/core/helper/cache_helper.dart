import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';

/// Thin, typed wrapper around [SharedPreferences].
///
/// It only deals with primitives / JSON, which keeps `core` free from any
/// dependency on feature models. Converting those JSON maps into models is the
/// responsibility of the feature data layer.
class CacheHelper {
  const CacheHelper(this._preferences);

  final SharedPreferences _preferences;

  static const String keyVideos = 'watch_it.cached_videos';

  /// Reads a raw [String].
  String? getString(String key) {
    try {
      return _preferences.getString(key);
    } catch (e) {
      throw CacheException('Failed to read "$key" from cache: $e');
    }
  }

  /// Persists a raw [String].
  Future<bool> saveString(String key, String value) async {
    try {
      return await _preferences.setString(key, value);
    } catch (e) {
      throw CacheException('Failed to write "$key" to cache: $e');
    }
  }

  /// Reads a list of JSON objects previously stored by [saveJsonList].
  ///
  /// Returns `null` when the key is absent or the stored value is corrupted.
  List<Map<String, dynamic>>? getJsonList(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    } catch (_) {
      // A corrupted cache entry must never crash the app.
      remove(key);
      return null;
    }
  }

  /// Persists a list of JSON objects.
  Future<bool> saveJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) {
    return saveString(key, jsonEncode(value));
  }

  /// Removes a single entry.
  Future<bool> remove(String key) => _preferences.remove(key);

  /// Wipes every entry owned by this app.
  Future<bool> clear() => _preferences.clear();
}
