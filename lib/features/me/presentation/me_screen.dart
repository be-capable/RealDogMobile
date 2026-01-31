import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../../auth/application/auth_controller.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            final disclaimer = ClayContainer(
              borderRadius: 28,
              color: Colors.white,
              child: Row(
                children: [
                  ClayContainer(
                    width: 44,
                    height: 44,
                    borderRadius: 22,
                    padding: EdgeInsets.zero,
                    color: AppTheme.primary.withValues(alpha: 0.10),
                    child: const Center(
                      child: Icon(Icons.info_outline, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disclaimer',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'RealDog is for entertainment purposes only.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.text.withValues(alpha: 0.75),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final settings = ClayContainer(
              borderRadius: 28,
              color: Colors.white,
              child: Column(
                children: [
                  _MeTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'Auto (en-US fallback)',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _MeTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Subscription',
                    subtitle: 'Not enabled in MVP',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _MeTile(
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    title: 'Logout',
                    titleColor: Colors.red,
                    subtitle: 'Sign out from this device',
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go('/login');
                    },
                  ),
                ],
              ),
            );

            final content = isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            disclaimer,
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceLG),
                      Expanded(
                        child: Column(
                          children: [
                            settings,
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      disclaimer,
                      const SizedBox(height: AppTheme.spaceLG),
                      settings,
                    ],
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _MeTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final VoidCallback onTap;

  const _MeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Row(
          children: [
            ClayContainer(
              width: 44,
              height: 44,
              borderRadius: 22,
              padding: EdgeInsets.zero,
              color: (iconColor ?? AppTheme.cta).withValues(alpha: 0.10),
              child: Center(
                child: Icon(icon, color: iconColor ?? AppTheme.cta),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: titleColor ?? AppTheme.text,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.text.withValues(alpha: 0.65),
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.text.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
