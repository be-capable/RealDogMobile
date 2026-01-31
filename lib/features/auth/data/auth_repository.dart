import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.read(httpServiceProvider)),
);

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});
}

/// Repository dealing with authentication API calls.
class AuthRepository {
  final HttpService _httpService;

  AuthRepository(this._httpService);

  /// Log in with email and password.
  /// Returns [AuthTokens] containing access and refresh tokens.
  Future<AuthTokens> login(String email, String password) async {
    final response = await _httpService.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    final accessToken = data?['accessToken'];
    final refreshToken = data?['refreshToken'];
    if (accessToken is! String || refreshToken is! String)
      throw Exception('Login failed');
    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  /// Register a new user.
  /// Returns [AuthTokens] on successful registration.
  Future<AuthTokens> register(String email, String password) async {
    final response = await _httpService.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    final accessToken = data?['accessToken'];
    final refreshToken = data?['refreshToken'];
    if (accessToken is! String || refreshToken is! String)
      throw Exception('Register failed');
    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  /// Logs out the current user session on server.
  Future<void> logout() async {
    await _httpService.post('/auth/logout');
  }

  /// Triggers a password reset email (OTP).
  Future<void> forgotPassword(String email) async {
    await _httpService.post('/auth/forgot-password', data: {'email': email});
  }

  /// Verifies the OTP code.
  Future<void> verifyOtp(String email, String otp) async {
    await _httpService.post(
      '/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );
  }

  /// Resets password using valid OTP and new password.
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await _httpService.post(
      '/auth/reset-password',
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
  }
}
