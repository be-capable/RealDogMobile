import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/app_back_button.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../../../core/storage/storage_service.dart';
import '../application/auth_controller.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final authState = ref.watch(authControllerProvider);

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
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final headerSection = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClayContainer(
                      width: 80,
                      height: 80,
                      borderRadius: 40,
                      color: AppTheme.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/app_icon_512.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: AppTheme.spaceLG),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                    const SizedBox(height: AppTheme.spaceSM),
                    Text(
                      'Join us to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 100.ms),
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
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ).animate().fadeIn(delay: 200.ms).slideX(),
                      const SizedBox(height: AppTheme.spaceMD),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ).animate().fadeIn(delay: 300.ms).slideX(),
                      const SizedBox(height: AppTheme.spaceMD),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ).animate().fadeIn(delay: 400.ms).slideX(),
                      const SizedBox(height: AppTheme.spaceLG),
                      ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                if (passwordController.text != confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Passwords do not match'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  );
                                  return;
                                }
                                ref.read(authControllerProvider.notifier).register(
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
                            : const Text('Sign Up'),
                      ).animate().fadeIn(delay: 500.ms).scale(),
                      const SizedBox(height: AppTheme.spaceLG),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Login'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
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
            Positioned(
              left: AppTheme.spaceLG,
              top: AppTheme.spaceMD,
              child: const AppBackButton(),
            ),
          ],
        ),
      ),
    );
  }
}
