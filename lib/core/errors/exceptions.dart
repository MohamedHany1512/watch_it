/// Exceptions are thrown by the **data layer** (data sources / API consumer).
///
/// They describe *what went wrong at the technical level*.
/// They are never shown to the user directly - the repository converts them
/// into [Failure] objects which are user-facing.
library;

/// Base class for every exception thrown inside the data layer.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  /// Human readable technical description of the problem.
  final String message;

  /// Optional server status code (when the failure came from a response).
  final int? code;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server replied with an error status code (4xx / 5xx).
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// The request could not reach the server at all (no internet, DNS, ...).
class NoInternetConnectionException extends AppException {
  const NoInternetConnectionException([
    super.message = 'No internet connection available',
  ]);
}

/// Reading from / writing to the local cache failed.
class CacheException extends AppException {
  const CacheException(super.message);
}

/// The payload could not be parsed into the expected model.
class InvalidDataException extends AppException {
  const InvalidDataException(super.message);
}

/// Anything that is not covered by the cases above.
class UnexpectedException extends AppException {
  const UnexpectedException(super.message);
}
