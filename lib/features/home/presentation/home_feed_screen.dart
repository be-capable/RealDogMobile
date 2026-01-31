import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../application/home_controller.dart';
import '../../pets/application/selected_pet_controller.dart';

class HomeFeedScreen extends ConsumerWidget {
  const HomeFeedScreen({super.key});

  String _timeLabel(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day} $h:$m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeControllerProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final selected = ref.watch(selectedPetControllerProvider).value;

    Widget quickAction({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final dense = constraints.maxWidth < 110;
          final iconWidget = Icon(
            icon,
            color: AppTheme.text.withValues(alpha: 0.7),
            size: 18,
          );
          final textStyle = dense
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.text.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  )
              : Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.text.withValues(alpha: 0.8),
                  );
          final labelWidget = Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: textStyle,
          );

          final content = dense
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconWidget,
                    const SizedBox(height: 6),
                    labelWidget,
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconWidget,
                    const SizedBox(width: 8),
                    Flexible(child: labelWidget),
                  ],
                );

          return ClayContainer(
            onTap: onTap,
            borderRadius: 20,
            color: AppTheme.background,
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 10 : 12,
              vertical: dense ? 10 : 12,
            ),
            child: Center(child: content),
          );
        },
      );
    }

    Widget animateCard(Widget w, int i) {
      if (reduceMotion) return w;
      return w
          .animate()
          .fadeIn(duration: 220.ms, delay: (60 * i).ms)
          .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
    }

    return Scaffold(
      body: SafeArea(
        child: homeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (home) {
            final pet = home.currentPet;
            final activePetId = selected?.id ?? pet?.id;
            final activePetName = selected?.name ?? pet?.name;
            final activeBreedId = selected == null ? pet?.breedId : null;

            final petCard = animateCard(
              ClayContainer(
                borderRadius: 28,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ClayContainer(
                          width: 56,
                          height: 56,
                          borderRadius: 28,
                          padding: EdgeInsets.zero,
                          color: AppTheme.primary.withValues(alpha: 0.10),
                          child: const Center(
                            child: Icon(Icons.pets, color: AppTheme.primary, size: 26),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activePetName ?? 'Welcome',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activePetId == null
                                    ? 'Create a dog profile to get started'
                                    : (activeBreedId == null ? 'Selected pet' : 'Breed · $activeBreedId'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.text.withValues(alpha: 0.65),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/pets'),
                          child: Text(activePetId == null ? 'Create' : 'Switch'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    Row(
                      children: [
                        Expanded(
                          child: quickAction(
                            icon: Icons.folder_open,
                            label: 'Profiles',
                            onTap: () => context.go('/pets'),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSM),
                        Expanded(
                          child: quickAction(
                            icon: Icons.chat_bubble_outline,
                            label: 'Talk',
                            onTap: () {
                              if (activePetId == null) {
                                context.push('/pets/create');
                                return;
                              }
                              context.go('/talk');
                            },
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSM),
                        Expanded(
                          child: quickAction(
                            icon: Icons.person_outline,
                            label: 'Me',
                            onTap: () => context.go('/me'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              0,
            );

            final recordCard = animateCard(
              ClayContainer(
                onTap: () async {
                  if (activePetId == null) {
                    context.push('/pets/create');
                    return;
                  }
                  final type = await showModalBottomSheet<String>(
                    context: context,
                    builder: (ctx) {
                      final items = const [
                        ('BARK', 'Bark'),
                        ('WHINE', 'Whine'),
                        ('HOWL', 'Howl'),
                        ('GROWL', 'Growl'),
                      ];
                      return SafeArea(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            const ListTile(title: Text('Quick event')),
                            ...items.map(
                              (it) => ListTile(
                                title: Text(it.$2),
                                onTap: () => Navigator.of(ctx).pop(it.$1),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  if (type == null) return;
                  await ref.read(homeControllerProvider.notifier).createQuickEvent(
                        petId: activePetId,
                        eventType: type,
                      );
                },
                color: AppTheme.primary,
                borderRadius: 28,
                child: Row(
                  children: [
                    ClayContainer(
                      width: 44,
                      height: 44,
                      borderRadius: 22,
                      padding: EdgeInsets.zero,
                      color: Colors.white.withValues(alpha: 0.18),
                      child: const Center(
                        child: Icon(Icons.graphic_eq, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activePetId == null ? 'Create Pet Profile' : 'Record a moment',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activePetId == null
                                ? 'Add your first dog to unlock the feed'
                                : 'Tap to add a quick event (MVP)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
              1,
            );

            final weeklyCard = animateCard(
              ClayContainer(
                borderRadius: 28,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Weekly summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.text),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            '${home.weeklySummary.rangeDays}d',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    Text(
                      '${home.weeklySummary.total} events in last ${home.weeklySummary.rangeDays} days',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.text.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (home.weeklySummary.byEventType.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .take(6)
                          .map(
                            (e) => Chip(
                              label: Text('${e.key} · ${e.value}'),
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                              side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              2,
            );

            final recentCard = home.recentEvents.isEmpty
                ? animateCard(
                    ClayContainer(
                      borderRadius: 28,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Recent events',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.text),
                          ),
                          const SizedBox(height: AppTheme.spaceSM),
                          Text(
                            'No events yet. Tap “Record a moment” to create your first one.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    3,
                  )
                : animateCard(
                    ClayContainer(
                      borderRadius: 28,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Recent events',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.text),
                          ),
                          const SizedBox(height: AppTheme.spaceSM),
                          ...home.recentEvents.map((e) {
                            final petName = e.pet?.name ?? 'Pet #${e.petId}';
                            final row = Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
                              child: ClayContainer(
                                onTap: () => context.push('/events/${e.id}'),
                                borderRadius: 22,
                                color: AppTheme.background,
                                child: Row(
                                  children: [
                                    ClayContainer(
                                      width: 44,
                                      height: 44,
                                      borderRadius: 22,
                                      padding: EdgeInsets.zero,
                                      color: AppTheme.cta.withValues(alpha: 0.12),
                                      child: const Center(
                                        child: Icon(Icons.record_voice_over, color: AppTheme.cta),
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spaceMD),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${e.eventType} · $petName',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _timeLabel(e.createdAt),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.text.withValues(alpha: 0.6),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppTheme.cta),
                                  ],
                                ),
                              ),
                            );
                            return reduceMotion
                                ? row
                                : row.animate().fadeIn(duration: 180.ms).slideX(begin: 0.02, end: 0);
                          }),
                        ],
                      ),
                    ),
                    3,
                  );

            return LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final scrollable = isLandscape
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppTheme.spaceLG),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  petCard,
                                  const SizedBox(height: AppTheme.spaceLG),
                                  recordCard,
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceLG),
                            Expanded(
                              child: Column(
                                children: [
                                  weeklyCard,
                                  const SizedBox(height: AppTheme.spaceLG),
                                  recentCard,
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppTheme.spaceLG),
                        children: [
                          petCard,
                          const SizedBox(height: AppTheme.spaceLG),
                          recordCard,
                          const SizedBox(height: AppTheme.spaceLG),
                          weeklyCard,
                          const SizedBox(height: AppTheme.spaceLG),
                          recentCard,
                        ],
                      );

                return RefreshIndicator(
                  onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
                  child: scrollable,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
