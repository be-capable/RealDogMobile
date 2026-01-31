enum DialogueMode {
  dogToHuman,
  humanToDog,
}

String dialogueModeToApi(DialogueMode mode) {
  switch (mode) {
    case DialogueMode.dogToHuman:
      return 'DOG_TO_HUMAN';
    case DialogueMode.humanToDog:
      return 'HUMAN_TO_DOG';
  }
}

enum DialogueSpeaker {
  human,
  dog,
}

class DialogueMessage {
  final String id;
  final DialogueSpeaker speaker;
  final String text;
  final DateTime createdAt;

  DialogueMessage({
    required this.id,
    required this.speaker,
    required this.text,
    required this.createdAt,
  });
}

class DialogueTurnResult {
  final DialogueMode mode;
  final String inputText;
  final String outputText;
  final String? dogEventType;
  final double? confidence;

  DialogueTurnResult({
    required this.mode,
    required this.inputText,
    required this.outputText,
    this.dogEventType,
    this.confidence,
  });

  factory DialogueTurnResult.fromJson(Map<String, dynamic> json) {
    final modeStr = (json['mode'] as String?) ?? 'DOG_TO_HUMAN';
    final mode = modeStr == 'HUMAN_TO_DOG' ? DialogueMode.humanToDog : DialogueMode.dogToHuman;
    return DialogueTurnResult(
      mode: mode,
      inputText: json['inputText'] ?? '',
      outputText: json['outputText'] ?? '',
      dogEventType: json['dogEventType'],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

