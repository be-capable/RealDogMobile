import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_session.dart';
import '../storage/storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/api_log_interceptor.dart';
import 'interceptors/sign_interceptor.dart';
// import 'interceptors/log_interceptor.dart'; // Create if needed

final httpServiceProvider = Provider<HttpService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HttpService(
    storage,
    onUnauthorized: () => ref.read(authSessionProvider.notifier).clear(),
  );
});

class HttpService {
  final StorageService _storage;
  final Future<void> Function() _onUnauthorized;
  late final Dio _dio;

  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  HttpService(this._storage, {required Future<void> Function() onUnauthorized})
      : _onUnauthorized = onUnauthorized {
    final baseUrl = _baseUrlOverride.isNotEmpty ? _baseUrlOverride : _defaultBaseUrl();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptors
    _dio.interceptors.addAll([
      SignInterceptor(),
      AuthInterceptor(_storage, _dio, _onUnauthorized),
      if (kDebugMode)
        ApiLogInterceptor(),
    ]);
  }

  Dio get client => _dio;

  // Convenience methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }
}
