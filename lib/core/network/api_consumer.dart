import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import 'api_interceptor.dart';
import 'endpoint.dart';
import 'network_info.dart';

/// The single entry point the data layer uses to talk to the network.
///
/// It hides Dio completely: callers only ever see [Response] on success and an
/// [AppException] on failure, never a raw [DioException].
class ApiConsumer {
  const ApiConsumer(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

/// Factory used by the service locator so every consumer shares the same
/// configuration (base url, timeouts, interceptors).
Dio buildDio(NetworkInfo networkInfo) {
  return Dio(
    BaseOptions(
      baseUrl: Endpoint.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: Endpoint.defaultHeaders,
      responseType: ResponseType.json,
    ),
  )..interceptors.add(AppInterceptor(networkInfo: networkInfo));
}
