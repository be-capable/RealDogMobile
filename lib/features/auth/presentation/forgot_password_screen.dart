import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../application/auth_controller.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
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
        // Navigate to Reset Password Screen with email
        context.push('/reset-password', extra: emailController.text);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.primary),
      ),
      body: SafeArea(
        child: LayoutBuilder(
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
                  child: const Icon(Icons.lock_reset, size: 40, color: AppTheme.primary),
                ).animate().fadeIn().scale(),
                const SizedBox(height: AppTheme.spaceLG),
                Text(
                  'Forgot Password',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: AppTheme.spaceSM),
                Text(
                  'Enter your email address to receive a verification code.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
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
                  ).animate().fadeIn(delay: 300.ms).slideX(),
                  const SizedBox(height: AppTheme.spaceLG),
                  ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            if (emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please enter your email'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                              return;
                            }
                            ref.read(authControllerProvider.notifier).forgotPassword(
                                  emailController.text,
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
                        : const Text('Send Verification Code'),
                  ).animate().fadeIn(delay: 400.ms).scale(),
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight - AppTheme.spaceLG * 2 - 56), // Adjust for AppBar
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
