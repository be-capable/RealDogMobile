import 'package:dio/dio.dart';
import '../../storage/storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final StorageService _storage;
  final Dio _dio;
  
  // Concurrency Lock handled by QueuedInterceptor?
  // Actually QueuedInterceptor queues requests but we need to handle the refresh specifically.
  // When 401 happens, QueuedInterceptor locks the queue automatically if we don't resolve immediately.
  // But for manual control (like the report said "isRefreshing"), standard QueuedInterceptor 
  // in Dio processes requests sequentially. 
  // However, `onError` is where we catch 401. 
  // Since we use QueuedInterceptor, if we do an async operation in onError, 
  // subsequent requests are queued until we resolve the handler.
  // So we don't need a manual `isRefreshing` bool if we rely on QueuedInterceptor correctly.
  
  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Check if we have a refresh token
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        // No RT, just fail
        return handler.next(err);
      }

      try {
        // Create a new Dio instance to avoid circular dependency and using the same interceptors
        // We do NOT want AuthInterceptor on the refresh call itself to avoid infinite loops
        // But we MIGHT want SignInterceptor if the backend requires signature for refresh
        // For safety, let's assume refresh endpoint is public/signed but doesn't need AT.
        final refreshDio = Dio(BaseOptions(
          baseUrl: _dio.options.baseUrl,
          headers: {
             'Content-Type': 'application/json',
             // Add signature manually or copy SignInterceptor if needed
             // For now simple bearer
          }
        ));
        
        // Add signature if needed (assuming SignInterceptor is separate)
        // But here we are making a raw call.
        
        final response = await refreshDio.post(
          '/auth/refresh',
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];

          if (newAccessToken != null && newRefreshToken != null) {
            await _storage.saveAccessToken(newAccessToken);
            await _storage.saveRefreshToken(newRefreshToken);

            // Retry original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            
            // We need to use _dio to retry so it goes through other interceptors (like logging/sign)
            // But we must be careful not to trigger AuthInterceptor logic again if it fails?
            // Actually, we just want to fetch.
            // Using _dio.fetch might trigger interceptors again.
            // But since we are inside an interceptor, triggering "onRequest" again is fine.
            final clonedResponse = await _dio.fetch(opts);
            return handler.resolve(clonedResponse);
          }
        }
      } catch (e) {
        // Refresh failed (Network or 403)
        // Clear tokens
        await _storage.deleteAll();
        // Propagate error (UI should listen to this or storage changes to logout)
      }
    }
    super.onError(err, handler);
  }
}
