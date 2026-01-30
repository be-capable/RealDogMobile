import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final int retryDelay; // milliseconds

  RetryInterceptor(this._dio, {this.maxRetries = 3, this.retryDelay = 1000});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra['retryCount'] ?? 0) as int;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      // Exponential backoff
      final delay = retryDelay * (1 << retryCount);
      await Future.delayed(Duration(milliseconds: delay));

      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // Continue to next error handler if retry fails
        // We need to pass it as DioException
        if (e is DioException) {
          return handler.next(e);
        }
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.type == DioExceptionType.badResponse && 
            err.response?.statusCode != null && 
            err.response!.statusCode! >= 500);
  }
}
