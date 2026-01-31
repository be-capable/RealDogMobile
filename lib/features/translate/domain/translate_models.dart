enum TranslateMode {
  dogToHuman,
  humanToDog,
}

enum TranslateStatus {
  idle,
  recording,
  uploading,
  processing,
  done,
  error,
}

class TranslateResult {
  final int eventId;
  final String inputAudioUrl;
  final String? outputAudioUrl;
  final String? meaningText;
  final double? confidence;

  const TranslateResult({
    required this.eventId,
    required this.inputAudioUrl,
    this.outputAudioUrl,
    this.meaningText,
    this.confidence,
  });
}

class TranslateState {
  final TranslateMode mode;
  final TranslateStatus status;
  final String? localAudioPath;
  final TranslateResult? result;
  final String? errorMessage;
  final String? contextText;
  final String? style;

  const TranslateState({
    required this.mode,
    required this.status,
    required this.localAudioPath,
    required this.result,
    required this.errorMessage,
    required this.contextText,
    required this.style,
  });

  factory TranslateState.initial() => const TranslateState(
        mode: TranslateMode.dogToHuman,
        status: TranslateStatus.idle,
        localAudioPath: null,
        result: null,
        errorMessage: null,
        contextText: null,
        style: null,
      );

  TranslateState copyWith({
    TranslateMode? mode,
    TranslateStatus? status,
    String? localAudioPath,
    TranslateResult? result,
    String? errorMessage,
    String? contextText,
    String? style,
  }) {
    return TranslateState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      result: result ?? this.result,
      errorMessage: errorMessage,
      contextText: contextText ?? this.contextText,
      style: style ?? this.style,
    );
  }
}

