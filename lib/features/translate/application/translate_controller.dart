import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../data/translate_repository.dart';
import '../domain/translate_models.dart';

final translateControllerProvider = NotifierProvider<TranslateController, TranslateState>(
  TranslateController.new,
);

class TranslateController extends Notifier<TranslateState> {
  final _recorder = AudioRecorder();

  @override
  TranslateState build() {
    ref.onDispose(() {
      _recorder.dispose();
    });
    return TranslateState.initial();
  }

  void setMode(TranslateMode mode) {
    state = TranslateState.initial().copyWith(mode: mode);
  }

  void setContextText(String? v) {
    state = state.copyWith(contextText: v);
  }

  void setStyle(String? v) {
    state = state.copyWith(style: v);
  }

  Future<void> startRecording() async {
    if (state.status == TranslateStatus.recording) return;
    final ok = await _recorder.hasPermission();
    if (!ok) {
      state = state.copyWith(status: TranslateStatus.error, errorMessage: 'Microphone permission denied');
      return;
    }

    final dir = await getTemporaryDirectory();
    final id = const Uuid().v4();
    final path = '${dir.path}/rd_$id.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    state = state.copyWith(status: TranslateStatus.recording, localAudioPath: path, errorMessage: null, result: null);
  }

  Future<void> stopRecordingAndSend({
    required int petId,
    required String locale,
  }) async {
    if (state.status != TranslateStatus.recording) return;

    final path = await _recorder.stop();
    final audioPath = path ?? state.localAudioPath;
    if (audioPath == null) {
      state = state.copyWith(status: TranslateStatus.error, errorMessage: 'Recording failed');
      return;
    }

    state = state.copyWith(status: TranslateStatus.uploading, localAudioPath: audioPath, errorMessage: null, result: null);

    try {
      final repo = ref.read(translateRepositoryProvider);
      state = state.copyWith(status: TranslateStatus.processing);
      final result = state.mode == TranslateMode.dogToHuman
          ? await repo.interpretDogAudio(
              petId: petId,
              audioPath: audioPath,
              locale: locale,
              contextText: state.contextText,
            )
          : await repo.synthesizeDogAudio(
              petId: petId,
              audioPath: audioPath,
              locale: locale,
              style: state.style,
            );

      state = state.copyWith(status: TranslateStatus.done, result: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: TranslateStatus.error, errorMessage: _errorText(e));
    }
  }

  Future<void> retry({
    required int petId,
    required String locale,
  }) async {
    final audioPath = state.localAudioPath;
    if (audioPath == null) return;
    state = state.copyWith(status: TranslateStatus.uploading, errorMessage: null, result: null);
    try {
      final repo = ref.read(translateRepositoryProvider);
      state = state.copyWith(status: TranslateStatus.processing);
      final result = state.mode == TranslateMode.dogToHuman
          ? await repo.interpretDogAudio(
              petId: petId,
              audioPath: audioPath,
              locale: locale,
              contextText: state.contextText,
            )
          : await repo.synthesizeDogAudio(
              petId: petId,
              audioPath: audioPath,
              locale: locale,
              style: state.style,
            );
      state = state.copyWith(status: TranslateStatus.done, result: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: TranslateStatus.error, errorMessage: _errorText(e));
    }
  }

  Future<void> cancelRecording() async {
    if (state.status != TranslateStatus.recording) return;
    await _recorder.cancel();
    state = state.copyWith(status: TranslateStatus.idle, errorMessage: null);
  }

  void clearResult() {
    state = state.copyWith(status: TranslateStatus.idle, result: null, errorMessage: null);
  }

  String _errorText(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    if (raw.startsWith(prefix)) return raw.substring(prefix.length);
    return raw;
  }
}
