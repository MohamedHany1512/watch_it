import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Contract for "do we have internet right now?".
///
/// Declared as an interface so tests can inject a fake implementation and so the
/// UI never depends on `internet_connection_checker_plus` directly.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Default implementation backed by `internet_connection_checker_plus`.
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  /// `InternetConnection` is not const-constructible, hence `final`.
  static final InternetConnection _checker = InternetConnection();

  @override
  Future<bool> get isConnected async {
    try {
      return await _checker.hasInternetAccess;
    } catch (_) {
      // If the platform channel fails we optimistically assume we are online
      // and let the actual request fail with a proper error.
      return true;
    }
  }
}
