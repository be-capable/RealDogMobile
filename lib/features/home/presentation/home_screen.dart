import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../../auth/application/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  borderRadius: 50,
                  color: AppTheme.white,
                  child: const Icon(Icons.pets, size: 64, color: AppTheme.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to RealDog!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.primary),
                  textAlign: TextAlign.center,
                ),
              ],
            );
            final actionSection = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClayContainer(
                  onTap: () => context.push('/pets'),
                  color: AppTheme.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'My Pets',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                ClayContainer(
                  onTap: () {
                    () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go('/login');
                    }();
                  },
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final content = isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: headerSection),
                      const SizedBox(width: AppTheme.spaceXL),
                      Expanded(child: actionSection),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      headerSection,
                      const SizedBox(height: AppTheme.spaceXL),
                      actionSection,
                    ],
                  );
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
