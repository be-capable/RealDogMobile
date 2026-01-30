import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.read(httpServiceProvider)));

class AuthRepository {
  final HttpService _httpService;

  AuthRepository(this._httpService);

  Future<void> login(String email, String password) async {
    await _httpService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<void> register(String email, String password) async {
    await _httpService.post('/auth/register', data: {
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() async {
    try {
      await _httpService.post('/auth/logout');
    } catch (e) {
      // Ignore logout errors
    }
  }

  Future<void> forgotPassword(String email) async {
    await _httpService.post('/auth/forgot-password', data: {
      'email': email,
    });
  }

  Future<void> verifyOtp(String email, String otp) async {
    await _httpService.post('/auth/verify-otp', data: {
      'email': email,
      'otp': otp,
    });
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    await _httpService.post('/auth/reset-password', data: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }
}
