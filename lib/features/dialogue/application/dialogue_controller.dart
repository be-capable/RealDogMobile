import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dialogue_repository.dart';
import '../domain/dialogue_models.dart';

class DialogueState {
  final DialogueMode mode;
  final List<DialogueMessage> messages;
  final bool isSending;
  final String? errorMessage;
  final DialogueMode? retryMode;
  final String? retryInputText;

  const DialogueState({
    required this.mode,
    required this.messages,
    required this.isSending,
    required this.errorMessage,
    required this.retryMode,
    required this.retryInputText,
  });

  factory DialogueState.initial() {
    return const DialogueState(
      mode: DialogueMode.humanToDog,
      messages: [],
      isSending: false,
      errorMessage: null,
      retryMode: null,
      retryInputText: null,
    );
  }

  DialogueState copyWith({
    DialogueMode? mode,
    List<DialogueMessage>? messages,
    bool? isSending,
    String? errorMessage,
    DialogueMode? retryMode,
    String? retryInputText,
  }) {
    return DialogueState(
      mode: mode ?? this.mode,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
      retryMode: retryMode,
      retryInputText: retryInputText,
    );
  }
}

final dialogueControllerProvider = AsyncNotifierProvider.autoDispose<DialogueController, DialogueState>(
  DialogueController.new,
);

class DialogueController extends AsyncNotifier<DialogueState> {
  String _errorText(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    if (raw.startsWith(prefix)) return raw.substring(prefix.length);
    return raw;
  }

  @override
  FutureOr<DialogueState> build() {
    return DialogueState.initial();
  }

  void setMode(DialogueMode mode) {
    final current = state.value ?? DialogueState.initial();
    state = AsyncValue.data(
      current.copyWith(
        mode: mode,
        messages: const [],
        isSending: false,
        errorMessage: null,
        retryMode: null,
        retryInputText: null,
      ),
    );
  }

  Future<void> send({
    required String text,
    int? petId,
    String? locale,
  }) async {
    final current = state.value ?? DialogueState.initial();
    if (current.isSending) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final userSpeaker = current.mode == DialogueMode.humanToDog ? DialogueSpeaker.human : DialogueSpeaker.dog;
    final assistantSpeaker = userSpeaker == DialogueSpeaker.human ? DialogueSpeaker.dog : DialogueSpeaker.human;

    final userMsg = DialogueMessage(
      id: 'u-${now.microsecondsSinceEpoch}',
      speaker: userSpeaker,
      text: trimmed,
      createdAt: now,
    );

    final optimisticMessages = [...current.messages, userMsg];

    final placeholder = DialogueMessage(
      id: 'a-${DateTime.now().microsecondsSinceEpoch}',
      speaker: assistantSpeaker,
      text: '',
      createdAt: DateTime.now(),
    );

    state = AsyncValue.data(
      current.copyWith(
        isSending: true,
        messages: [...optimisticMessages, placeholder],
        errorMessage: null,
        retryMode: null,
        retryInputText: null,
      ),
    );

    try {
      final repo = ref.read(dialogueRepositoryProvider);
      final result = await repo.turn(
        mode: current.mode,
        inputText: trimmed,
        petId: petId,
        locale: locale,
      );

      final doneState = state.value ?? current;
      final updated = [...doneState.messages];
      if (updated.isNotEmpty && updated.last.id == placeholder.id) {
        final txt = result.outputText.trim();
        updated[updated.length - 1] = DialogueMessage(
          id: updated.last.id,
          speaker: updated.last.speaker,
          text: txt.isEmpty ? '(empty)' : txt,
          createdAt: updated.last.createdAt,
        );
      }
      state = AsyncValue.data(
        doneState.copyWith(
          isSending: false,
          messages: updated,
          errorMessage: null,
          retryMode: null,
          retryInputText: null,
        ),
      );
    } catch (e) {
      final nowState = state.value ?? current;
      final msgs = [...nowState.messages];
      if (msgs.isNotEmpty && msgs.last.id == placeholder.id) {
        msgs.removeLast();
      }
      final after = (state.value ?? current).copyWith(
        isSending: false,
        messages: msgs.isEmpty ? optimisticMessages : msgs,
        errorMessage: _errorText(e),
        retryMode: current.mode,
        retryInputText: trimmed,
      );
      state = AsyncValue.data(after);
    }
  }

  void clear() {
    state = AsyncValue.data(DialogueState.initial());
  }

  void dismissError() {
    final current = state.value ?? DialogueState.initial();
    if (current.errorMessage == null) return;
    state = AsyncValue.data(
      current.copyWith(
        errorMessage: null,
      ),
    );
  }

  Future<void> retry({int? petId, String? locale}) async {
    final current = state.value ?? DialogueState.initial();
    final text = current.retryInputText;
    final mode = current.retryMode;
    if (text == null || mode == null) return;
    state = AsyncValue.data(
      current.copyWith(
        mode: mode,
        errorMessage: null,
        retryMode: null,
        retryInputText: null,
      ),
    );
    await send(text: text, petId: petId, locale: locale);
  }
}
