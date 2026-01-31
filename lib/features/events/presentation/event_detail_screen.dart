import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/app_back_button.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../data/events_repository.dart';
import '../domain/dog_event_model.dart';

final eventDetailProvider = FutureProvider.autoDispose.family<DogEvent, int>((ref, id) async {
  return ref.read(eventsRepositoryProvider).getEvent(id);
});

class EventDetailScreen extends ConsumerWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            eventAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (e) {
                final time =
                    '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')} '
                    '${e.createdAt.hour.toString().padLeft(2, '0')}:${e.createdAt.minute.toString().padLeft(2, '0')}';
                return ListView(
                  padding: const EdgeInsets.all(AppTheme.spaceLG),
                  children: [
                    const SizedBox(height: 44),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.ios_share),
                        onPressed: () async {
                          await showModalBottomSheet<void>(
                            context: context,
                            builder: (ctx) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const ListTile(title: Text('Share (MVP)')),
                                    ListTile(
                                      leading: const Icon(Icons.copy),
                                      title: const Text('Copy summary'),
                                      onTap: () async {
                                        final current = ref.read(eventDetailProvider(eventId)).maybeWhen(
                                              data: (v) => v,
                                              orElse: () => null,
                                            );
                                        final text = current == null
                                            ? 'RealDog Event #$eventId'
                                            : 'RealDog · ${current.eventType} · petId=${current.petId} · ${current.createdAt.toIso8601String()}';
                                        await Clipboard.setData(ClipboardData(text: text));
                                        if (!ctx.mounted) return;
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Copied')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    (reduceMotion
                            ? _EventCard(time: time, e: e)
                            : _EventCard(time: time, e: e)
                                .animate()
                                .fadeIn(duration: 220.ms)
                                .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic)),
                  ],
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

class _EventCard extends StatelessWidget {
  final String time;
  final DogEvent e;
  const _EventCard({required this.time, required this.e});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      borderRadius: 28,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClayContainer(
                width: 52,
                height: 52,
                borderRadius: 26,
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
                      e.pet?.name ?? 'Pet #${e.petId}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.text.withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(e.eventType),
                backgroundColor: AppTheme.primary.withValues(alpha: 0.10),
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.25)),
              ),
              if (e.contextType != null)
                Chip(
                  label: Text(e.contextType!),
                  backgroundColor: AppTheme.cta.withValues(alpha: 0.10),
                  side: BorderSide(color: AppTheme.cta.withValues(alpha: 0.25)),
                ),
              if (e.stateType != null)
                Chip(
                  label: Text(e.stateType!),
                  backgroundColor: AppTheme.text.withValues(alpha: 0.06),
                  side: BorderSide(color: AppTheme.text.withValues(alpha: 0.12)),
                ),
            ],
          ),
          if (e.confidence != null) ...[
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              'Confidence: ${(e.confidence! * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.text.withValues(alpha: 0.8),
                  ),
            ),
          ],
          const SizedBox(height: AppTheme.spaceLG),
          Text(
            'Interpretation (MVP)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            'This is a fun interpretation placeholder. Later we will generate a richer explanation from audio + context.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.text.withValues(alpha: 0.75),
                ),
          ),
        ],
      ),
    );
  }
}
