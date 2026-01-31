import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    final storage = ref.read(storageServiceProvider);
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();
    if (!mounted) return;

    if (accessToken == null || refreshToken == null) {
      context.go('/login');
      return;
    }

    final hasSeenOnboarding = await storage.getHasSeenOnboarding();
    if (!mounted) return;
    context.go(hasSeenOnboarding ? '/pets' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ClayContainer(
            width: 120,
            height: 120,
            borderRadius: 60,
            color: AppTheme.white,
            child: const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
