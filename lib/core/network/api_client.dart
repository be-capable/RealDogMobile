import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/interceptors/api_log_interceptor.dart';
import '../auth/auth_session.dart';
import '../storage/storage_service.dart';
import '../api/interceptors/auth_interceptor.dart';
import '../api/interceptors/retry_interceptor.dart';
import '../api/interceptors/sign_interceptor.dart';

final apiClientProvider = Provider<Dio>((ref) {
  // Ensure DeviceUtils is initialized (Best done in main, but here lazily is ok if main calls it)
  // Ideally main.dart calls DeviceUtils.init()
  
  final dio = Dio();
  final storageService = ref.read(storageServiceProvider);

  // Handle platform specific localhost
  String baseUrl = 'http://localhost:3000/api';
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      baseUrl = 'http://localhost:3000/api';
    }
  }

  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add interceptors
  // Order: Auth (Inject Token) -> Sign (Inject Params & Sign) -> Retry -> Log
  dio.interceptors.add(
    AuthInterceptor(
      storageService,
      dio,
      () => ref.read(authSessionProvider.notifier).clear(),
    ),
  );
  dio.interceptors.add(SignInterceptor());
  dio.interceptors.add(RetryInterceptor(dio));

  // Add logging interceptor
  if (kDebugMode) {
    dio.interceptors.add(ApiLogInterceptor());
  }

  return dio;
});
