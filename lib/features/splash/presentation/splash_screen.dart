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
    context.go(hasSeenOnboarding ? '/translate' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClayContainer(
                width: 128,
                height: 128,
                borderRadius: 32,
                color: AppTheme.white,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/images/app_icon_512.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              Text(
                'RealDog',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                'Speak their language',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.text.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
