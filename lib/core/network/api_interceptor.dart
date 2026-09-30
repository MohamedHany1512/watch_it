import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import 'network_info.dart';

/// Dio [Interceptor] responsible for three cross-cutting concerns:
/// 1. short-circuiting the request when the device is offline,
/// 2. attaching the default headers,
/// 3. translating [DioException] into our own [AppException] hierarchy.
class AppInterceptor extends Interceptor {
  AppInterceptor({required NetworkInfo networkInfo}) : _networkInfo = networkInfo;

  final NetworkInfo _networkInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await _networkInfo.isConnected) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NoInternetConnectionException(),
        ),
      );
      return;
    }

    options.headers.addAll(_defaultHeaders);
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapDioException(err),
        stackTrace: err.stackTrace,
      ),
    );
  }

  static const Map<String, String> _defaultHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

/// Converts a [DioException] into the matching [AppException].
///
/// Exposed as a top level function so the same mapping can be reused by any
/// data source that does not go through Dio (e.g. a plugin based one).
AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const ServerException('The server took too long to respond.');
    case DioExceptionType.transformTimeout:
      return const ServerException('The response could not be processed.');
    case DioExceptionType.connectionError:
      return const NoInternetConnectionException();
    case DioExceptionType.badCertificate:
      return const ServerException('The server certificate is not valid.');
    case DioExceptionType.cancel:
      return const ServerException('The request was cancelled.');
    case DioExceptionType.badResponse:
      return ServerException(
        _extractMessage(error.response),
        code: error.response?.statusCode,
      );
    case DioExceptionType.unknown:
      final cause = error.error;
      if (cause is AppException) return cause;
      return UnexpectedException(cause?.toString() ?? 'Unknown network error');
  }
}

String _extractMessage(Response<dynamic>? response) {
  final data = response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'];
    if (message is String && message.isNotEmpty) return message;
  }
  final statusCode = response?.statusCode;
  return 'Request failed with status code $statusCode';
}
