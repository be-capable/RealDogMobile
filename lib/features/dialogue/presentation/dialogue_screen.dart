import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../application/dialogue_controller.dart';
import '../domain/dialogue_models.dart';

class DialogueScreen extends HookConsumerWidget {
  final int? petId;
  final String? petName;

  const DialogueScreen({super.key, this.petId, this.petName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(dialogueControllerProvider);
    final controller = ref.read(dialogueControllerProvider.notifier);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final inputController = useTextEditingController();
    final scrollController = useScrollController();

    final state = asyncState.value ?? DialogueState.initial();

    useEffect(() {
      if (state.messages.isEmpty) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
      return null;
    }, [state.messages.length]);

    Future<void> onSend() async {
      final text = inputController.text;
      inputController.clear();
      await controller.send(
        text: text,
        petId: petId,
        locale: Localizations.localeOf(context).toLanguageTag(),
      );
    }

    Widget messageList() {
      if (state.messages.isEmpty) {
        final empty = ClayContainer(
          borderRadius: 28,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Try a turn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppTheme.spaceSM),
              Text(
                state.mode == DialogueMode.humanToDog
                    ? 'Type a sentence and we will turn it into dog-speak.'
                    : 'Type dog sounds (or pick a quick chip) and we will translate it to human text.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.text.withValues(alpha: 0.75),
                    ),
              ),
            ],
          ),
        );
        return reduceMotion ? empty : empty.animate().fadeIn(duration: 220.ms).slideY(begin: 0.06, end: 0);
      }

      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: AppTheme.spaceXL),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final m = state.messages[index];
          final bubble = _MessageBubble(message: m);
          if (reduceMotion) return bubble;
          return bubble
              .animate()
              .fadeIn(duration: 180.ms, delay: (40 * index).ms)
              .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
        },
      );
    }

    Widget modeChips() {
      if (state.mode != DialogueMode.dogToHuman) return const SizedBox.shrink();
      const items = [
        ('BARK', 'Bark'),
        ('WHINE', 'Whine'),
        ('HOWL', 'Howl'),
        ('GROWL', 'Growl'),
      ];
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map(
                (it) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(it.$2),
                    onPressed: state.isSending
                        ? null
                        : () {
                            inputController.text = it.$1;
                            inputController.selection = TextSelection.fromPosition(
                              TextPosition(offset: inputController.text.length),
                            );
                          },
                  ),
                ),
              )
              .toList(),
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
            TextButton(
              onPressed: () => controller.retry(
                petId: petId,
                locale: Localizations.localeOf(context).toLanguageTag(),
              ),
              child: const Text('Retry'),
            ),
            IconButton(
              onPressed: () => controller.dismissError(),
              icon: const Icon(Icons.close),
              color: Colors.red.withValues(alpha: 0.7),
            ),
          ],
        ),
      );
      return reduceMotion ? banner : banner.animate().fadeIn(duration: 160.ms).slideY(begin: 0.08, end: 0);
    }

    Widget headerCard() {
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
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/gifs/dog_wag_128.gif',
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petName == null ? 'No pet selected' : 'Talking with $petName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MVP: text in ↔ text out (audio coming soon)',
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
              onPressed: () => controller.clear(),
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.text.withValues(alpha: 0.65),
            ),
          ],
        ),
      );
    }

    Widget composerPanel({required bool compact}) {
      return ClayContainer(
        borderRadius: 28,
        color: Colors.white,
        padding: const EdgeInsets.all(AppTheme.spaceSM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<DialogueMode>(
              segments: const [
                ButtonSegment(
                  value: DialogueMode.humanToDog,
                  label: Text('Human → Dog'),
                  icon: Icon(Icons.record_voice_over_outlined),
                ),
                ButtonSegment(
                  value: DialogueMode.dogToHuman,
                  label: Text('Dog → Human'),
                  icon: Icon(Icons.pets_outlined),
                ),
              ],
              selected: {state.mode},
              onSelectionChanged: state.isSending ? null : (s) => controller.setMode(s.first),
            ),
            if (state.mode == DialogueMode.dogToHuman) ...[
              SizedBox(height: compact ? 6 : AppTheme.spaceSM),
              modeChips(),
            ],
            SizedBox(height: compact ? 8 : AppTheme.spaceSM),
            errorBanner(),
            if (state.errorMessage != null) SizedBox(height: compact ? 8 : AppTheme.spaceSM),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice input coming soon')),
                    );
                  },
                  icon: const Icon(Icons.mic_none),
                ),
                Expanded(
                  child: TextField(
                    controller: inputController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => state.isSending ? null : onSend(),
                    decoration: InputDecoration(
                      hintText: state.mode == DialogueMode.humanToDog ? 'Say something…' : 'Paste dog sound (e.g. BARK)…',
                      isDense: compact,
                    ),
                    enabled: !state.isSending,
                    minLines: 1,
                    maxLines: compact ? 2 : 4,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: state.isSending ? null : onSend,
                  child: state.isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final horizontalPadding = isLandscape ? AppTheme.spaceMD : AppTheme.spaceLG;

            final listWidget = asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (_) => messageList(),
            );

            if (isLandscape) {
              return Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, AppTheme.spaceMD, horizontalPadding, AppTheme.spaceMD),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          headerCard(),
                          const SizedBox(height: AppTheme.spaceMD),
                          Expanded(child: listWidget),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: composerPanel(compact: true),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, AppTheme.spaceMD, horizontalPadding, 0),
                  child: headerCard(),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: listWidget,
                  ),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, AppTheme.spaceMD),
                    child: composerPanel(compact: false),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final DialogueMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isHuman = message.speaker == DialogueSpeaker.human;
    final align = isHuman ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final rowAlign = isHuman ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor = isHuman ? AppTheme.primary.withValues(alpha: 0.10) : Colors.white;
    final border = isHuman ? AppTheme.primary.withValues(alpha: 0.25) : AppTheme.text.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: Row(
        mainAxisAlignment: rowAlign,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () async {
                await Clipboard.setData(ClipboardData(text: message.text));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied'),
                    duration: const Duration(milliseconds: 900),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(AppTheme.spaceLG),
                  ),
                );
              },
              child: ClayContainer(
                borderRadius: 24,
                color: bubbleColor,
                child: Column(
                  crossAxisAlignment: align,
                  children: [
                    Text(
                      isHuman ? 'Human' : 'Dog',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.text.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border),
                      ),
                      padding: const EdgeInsets.all(AppTheme.spaceMD),
                      child: Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.text,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
