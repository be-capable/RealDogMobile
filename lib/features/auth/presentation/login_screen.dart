import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../../../core/storage/storage_service.dart';
import '../application/auth_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authState = ref.watch(authControllerProvider);

    // Listen for errors or success
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
      if (previous?.isLoading == true && !next.isLoading && !next.hasError) {
        () async {
          final storage = ref.read(storageServiceProvider);
          final hasSeenOnboarding = await storage.getHasSeenOnboarding();
          if (!context.mounted) return;
          context.go(hasSeenOnboarding ? '/translate' : '/onboarding');
        }();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final headerSection = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClayContainer(
                  width: 100,
                  height: 100,
                  borderRadius: 50,
                  color: AppTheme.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/app_icon_512.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: AppTheme.spaceLG),
                Text(
                  'RealDog',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  'Speak their language',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.text.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
              ],
            );
            
            final formSection = ClayContainer(
              borderRadius: 32,
              padding: const EdgeInsets.all(AppTheme.spaceXL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceLG),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: AppTheme.spaceMD),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: AppTheme.spaceMD),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: AppTheme.spaceLG),
                  ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref.read(authControllerProvider.notifier).login(
                                  emailController.text,
                                  passwordController.text,
                                );
                          },
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ).animate().fadeIn(delay: 700.ms).scale(),
                  const SizedBox(height: AppTheme.spaceLG),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New here?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('Create Account'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            );

            final content = isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: headerSection),
                      const SizedBox(width: AppTheme.spaceXL),
                      Expanded(child: Center(child: formSection)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      headerSection,
                      const SizedBox(height: AppTheme.spaceXL),
                      formSection,
                    ],
                  );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - AppTheme.spaceLG * 2),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
