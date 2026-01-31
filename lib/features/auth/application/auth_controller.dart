import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_session.dart';
import '../data/auth_repository.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is void (null)
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tokens = await ref.read(authRepositoryProvider).login(email, password);
      await ref.read(authSessionProvider.notifier).setTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
    });
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tokens = await ref.read(authRepositoryProvider).register(email, password);
      await ref.read(authSessionProvider.notifier).setTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(authRepositoryProvider).logout();
      } catch (_) {}
      await ref.read(authSessionProvider.notifier).clear();
    });
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).forgotPassword(email));
  }

  Future<void> verifyOtp(String email, String otp) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).verifyOtp(email, otp));
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).resetPassword(email, otp, newPassword));
  }
}
