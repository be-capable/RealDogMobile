import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';
import '../../../core/storage/storage_service.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
  ref.read(httpServiceProvider),
  ref.read(storageServiceProvider),
));

class AuthRepository {
  final HttpService _httpService;
  final StorageService _storageService;

  AuthRepository(this._httpService, this._storageService);

  Future<void> login(String email, String password) async {
    final response = await _httpService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response.data;
    if (data != null && data['accessToken'] != null && data['refreshToken'] != null) {
      await _storageService.saveAccessToken(data['accessToken']);
      await _storageService.saveRefreshToken(data['refreshToken']);
    }
  }

  Future<void> register(String email, String password) async {
    final response = await _httpService.post('/auth/register', data: {
      'email': email,
      'password': password,
    });

    final data = response.data;
    if (data != null && data['accessToken'] != null && data['refreshToken'] != null) {
      await _storageService.saveAccessToken(data['accessToken']);
      await _storageService.saveRefreshToken(data['refreshToken']);
    }
  }

  Future<void> logout() async {
    try {
      await _httpService.post('/auth/logout');
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _storageService.deleteAll();
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
