import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final pageIndex = useState<int>(0);
    final steps = [
      (
        icon: Icons.pets,
        title: 'Welcome to RealDog',
        subtitle: 'Understand what your dog is trying to say.',
      ),
      (
        icon: Icons.add_circle_outline,
        title: 'Create a profile',
        subtitle: 'Add your dog and personalize the experience.',
      ),
      (
        icon: Icons.graphic_eq,
        title: 'Track moments',
        subtitle: 'Log events and learn patterns over time.',
      ),
    ];

    Future<void> finish() async {
      final storage = ref.read(storageServiceProvider);
      await storage.setHasSeenOnboarding(true);
      if (!context.mounted) return;
      context.go('/pets');
    }

    final isLast = pageIndex.value == steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: finish,
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceLG),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: steps.length,
                  onPageChanged: (index) => pageIndex.value = index,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return Center(
                      child: ClayContainer(
                        borderRadius: 32,
                        padding: const EdgeInsets.all(AppTheme.spaceXL),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClayContainer(
                              width: 96,
                              height: 96,
                              borderRadius: 48,
                              color: AppTheme.white,
                              child: Icon(step.icon, size: 48, color: AppTheme.primary),
                            ),
                            const SizedBox(height: AppTheme.spaceLG),
                            Text(
                              step.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.primary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            Text(
                              step.subtitle,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.text.withValues(alpha: 0.75),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: i == pageIndex.value ? 24 : 8,
                    decoration: BoxDecoration(
                      color: i == pageIndex.value ? AppTheme.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              ElevatedButton(
                onPressed: () async {
                  if (isLast) {
                    await finish();
                    return;
                  }
                  await pageController.nextPage(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                  );
                },
                child: Text(isLast ? 'Get Started' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
