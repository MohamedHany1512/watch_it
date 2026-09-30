import 'package:equatable/equatable.dart';

/// A [Failure] is the **domain-safe** representation of an [AppException].
///
/// Failures are intentionally free of any `Dio` / `SharedPreferences`
/// dependency so that the presentation layer can consume them safely.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Message that is safe to render in the UI.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// The device has no internet access.
class NoInternetConnectionFailure extends Failure {
  const NoInternetConnectionFailure([
    super.message = 'No internet connection available',
  ]);
}

/// The remote server answered with an error.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.code});

  final int? code;

  @override
  List<Object?> get props => <Object?>[message, code];
}

/// The local cache (SharedPreferences) could not be used.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// The server answered but the payload had an unexpected shape.
class InvalidDataFailure extends Failure {
  const InvalidDataFailure(super.message);
}

/// Last-resort failure for unhandled technical errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
