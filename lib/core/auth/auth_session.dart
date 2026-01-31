import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
  });
}

final authSessionProvider = AsyncNotifierProvider<AuthSessionController, AuthSession?>(
  AuthSessionController.new,
);

class AuthSessionController extends AsyncNotifier<AuthSession?> {
  StorageService get _storage => ref.read(storageServiceProvider);

  @override
  Future<AuthSession?> build() async {
    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();
    if (accessToken == null || refreshToken == null) return null;
    return AuthSession(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    state = const AsyncValue.loading();
    await _storage.saveAccessToken(accessToken);
    await _storage.saveRefreshToken(refreshToken);
    state = AsyncValue.data(AuthSession(accessToken: accessToken, refreshToken: refreshToken));
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    await _storage.deleteAll();
    state = const AsyncValue.data(null);
  }
}

