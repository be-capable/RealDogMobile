import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../application/translate_controller.dart';
import '../domain/translate_models.dart';

class TranslateScreen extends HookConsumerWidget {
  final int? petId;
  final String? petName;

  const TranslateScreen({super.key, this.petId, this.petName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final state = ref.watch(translateControllerProvider);
    final controller = ref.read(translateControllerProvider.notifier);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final inputPlayer = useMemoized(() => AudioPlayer());
    final outputPlayer = useMemoized(() => AudioPlayer());

    useEffect(() {
      return () {
        inputPlayer.dispose();
        outputPlayer.dispose();
      };
    }, const []);

    useEffect(() {
      final url = state.result?.inputAudioUrl;
      if (url == null) return null;
      inputPlayer.stop();
      inputPlayer.setUrl(url);
      return null;
    }, [state.result?.inputAudioUrl]);

    useEffect(() {
      final url = state.result?.outputAudioUrl;
      if (url == null) return null;
      outputPlayer.stop();
      outputPlayer.setUrl(url);
      return null;
    }, [state.result?.outputAudioUrl]);

    Widget header() {
      return ClayContainer(
        borderRadius: 28,
        color: Colors.white,
        child: Row(
          children: [
            ClayContainer(
              width: 48,
              height: 48,
              borderRadius: 24,
              padding: EdgeInsets.zero,
              color: AppTheme.primary.withValues(alpha: 0.10),
              child: const Center(
                child: Icon(Icons.pets_outlined, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petName == null ? 'Select a pet' : 'Translating for $petName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.mode == TranslateMode.dogToHuman ? 'Dog audio → Human text' : 'Human audio → Dog audio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.text.withValues(alpha: 0.65),
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push('/pets'),
              icon: const Icon(Icons.folder_open_outlined),
              color: AppTheme.text.withValues(alpha: 0.65),
              tooltip: 'Profiles',
            ),
          ],
        ),
      );
    }

    Widget modePicker() {
      return ClayContainer(
        borderRadius: 28,
        color: Colors.white,
        padding: const EdgeInsets.all(AppTheme.spaceSM),
        child: SegmentedButton<TranslateMode>(
          segments: const [
            ButtonSegment(
              value: TranslateMode.dogToHuman,
              label: Text('Dog → Human'),
              icon: Icon(Icons.record_voice_over_outlined),
            ),
            ButtonSegment(
              value: TranslateMode.humanToDog,
              label: Text('Human → Dog'),
              icon: Icon(Icons.volume_up_outlined),
            ),
          ],
          selected: {state.mode},
          onSelectionChanged: (s) => controller.setMode(s.first),
        ),
      );
    }

    Widget options() {
      if (state.mode == TranslateMode.dogToHuman) {
        return ClayContainer(
          borderRadius: 28,
          color: Colors.white,
          child: TextField(
            onChanged: controller.setContextText,
            decoration: const InputDecoration(
              labelText: 'Context (optional)',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            maxLines: 2,
          ),
        );
      }

      const styles = [
        ('playful', 'Playful'),
        ('alert', 'Alert'),
        ('anxious', 'Anxious'),
      ];
      return ClayContainer(
        borderRadius: 28,
        color: Colors.white,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in styles)
              ChoiceChip(
                label: Text(s.$2),
                selected: state.style == s.$1,
                onSelected: (_) => controller.setStyle(s.$1),
              ),
          ],
        ),
      );
    }

    Widget recordPanel() {
      final isRecording = state.status == TranslateStatus.recording;
      final busy = state.status == TranslateStatus.uploading || state.status == TranslateStatus.processing;
      final icon = isRecording ? Icons.stop_circle_outlined : Icons.mic_none;
      final label = isRecording ? 'Stop & Send' : 'Record';
      final sub = busy
          ? (state.status == TranslateStatus.uploading ? 'Uploading…' : 'Processing…')
          : (state.mode == TranslateMode.dogToHuman ? 'Record your dog' : 'Record yourself');

      return ClayContainer(
        borderRadius: 28,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              sub,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.text.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      final id = petId;
                      if (id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a pet first')),
                        );
                        return;
                      }
                      if (isRecording) {
                        await controller.stopRecordingAndSend(petId: id, locale: locale);
                      } else {
                        await controller.startRecording();
                      }
                    },
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : AppTheme.cta,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (isRecording) ...[
              const SizedBox(height: AppTheme.spaceSM),
              TextButton(
                onPressed: () async => controller.cancelRecording(),
                child: const Text('Cancel'),
              ),
            ],
            if (busy) ...[
              const SizedBox(height: AppTheme.spaceMD),
              const Center(
                child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ],
          ],
        ),
      );
    }

    Widget errorBanner() {
      if (state.errorMessage == null) return const SizedBox.shrink();
      final banner = ClayContainer(
        borderRadius: 20,
        color: Colors.red.withValues(alpha: 0.06),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.withValues(alpha: 0.8)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (petId != null)
              TextButton(
                onPressed: () => controller.retry(petId: petId!, locale: locale),
                child: const Text('Retry'),
              ),
            IconButton(
              onPressed: () => controller.clearResult(),
              icon: const Icon(Icons.close),
              color: Colors.red.withValues(alpha: 0.7),
            ),
          ],
        ),
      );
      return reduceMotion ? banner : banner.animate().fadeIn(duration: 160.ms).slideY(begin: 0.08, end: 0);
    }

    Widget resultPanel() {
      final r = state.result;
      if (r == null) return const SizedBox.shrink();

      final children = <Widget>[
        _AudioTile(
          title: 'Input audio',
          player: inputPlayer,
        ),
      ];

      if (state.mode == TranslateMode.dogToHuman) {
        children.addAll([
          const SizedBox(height: AppTheme.spaceMD),
          Text(
            'Meaning',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            r.meaningText ?? '(empty)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (r.confidence != null) ...[
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              'Confidence ${(r.confidence! * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.text.withValues(alpha: 0.7)),
            ),
          ],
        ]);
      } else {
        children.addAll([
          const SizedBox(height: AppTheme.spaceMD),
          _AudioTile(
            title: 'Dog audio',
            player: outputPlayer,
          ),
        ]);
      }

      final card = ClayContainer(
        borderRadius: 28,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
      return reduceMotion ? card : card.animate().fadeIn(duration: 220.ms).slideY(begin: 0.04, end: 0);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          children: [
            header(),
            const SizedBox(height: AppTheme.spaceMD),
            modePicker(),
            const SizedBox(height: AppTheme.spaceMD),
            options(),
            const SizedBox(height: AppTheme.spaceMD),
            errorBanner(),
            if (state.errorMessage != null) const SizedBox(height: AppTheme.spaceMD),
            resultPanel(),
            if (state.result != null) const SizedBox(height: AppTheme.spaceMD),
            recordPanel(),
          ],
        ),
      ),
    );
  }
}

class _AudioTile extends StatelessWidget {
  final String title;
  final AudioPlayer player;

  const _AudioTile({
    required this.title,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snap) {
        final state = snap.data;
        final playing = state?.playing ?? false;
        final processing = state?.processingState == ProcessingState.loading ||
            state?.processingState == ProcessingState.buffering;

        return ClayContainer(
          borderRadius: 22,
          color: AppTheme.background,
          child: Row(
            children: [
              IconButton(
                onPressed: processing
                    ? null
                    : () async {
                        if (playing) {
                          await player.pause();
                        } else {
                          await player.play();
                        }
                      },
                icon: Icon(playing ? Icons.pause_circle_outline : Icons.play_circle_outline),
              ),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.text.withValues(alpha: 0.8),
                      ),
                ),
              ),
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, posSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final m = pos.inMinutes.toString().padLeft(2, '0');
                  final s = (pos.inSeconds % 60).toString().padLeft(2, '0');
                  return Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spaceMD),
                    child: Text(
                      '$m:$s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.text.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
