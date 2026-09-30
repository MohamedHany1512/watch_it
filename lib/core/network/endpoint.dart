/// Central place for every remote endpoint used by the application.
class Endpoint {
  const Endpoint._();

  static const String baseUrl = 'https://www.googleapis.com/youtube/v3/';

  /// Public catalogue of videos. The key is intentionally empty so the
  /// request stays a valid demo call until a real API key is provided.
  static const String videos = 'search';

  static const Map<String, String> defaultHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
