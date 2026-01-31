class DogEventPetRef {
  final int id;
  final String name;
  final String? avatarUrl;

  DogEventPetRef({required this.id, required this.name, this.avatarUrl});

  factory DogEventPetRef.fromJson(Map<String, dynamic> json) {
    final avatarMedia = json['avatarMedia'];
    final avatarUrl = avatarMedia is Map<String, dynamic> ? avatarMedia['objectKey'] as String? : null;
    return DogEventPetRef(
      id: json['id'],
      name: json['name'],
      avatarUrl: avatarUrl,
    );
  }
}

class DogEvent {
  final int id;
  final int petId;
  final String eventType;
  final String? stateType;
  final String? contextType;
  final double? confidence;
  final String? audioUrl;
  final DateTime createdAt;
  final DogEventPetRef? pet;

  DogEvent({
    required this.id,
    required this.petId,
    required this.eventType,
    required this.createdAt,
    this.stateType,
    this.contextType,
    this.confidence,
    this.audioUrl,
    this.pet,
  });

  factory DogEvent.fromJson(Map<String, dynamic> json) {
    return DogEvent(
      id: json['id'],
      petId: json['petId'],
      eventType: json['eventType'],
      stateType: json['stateType'],
      contextType: json['contextType'],
      confidence: (json['confidence'] as num?)?.toDouble(),
      audioUrl: json['audioUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      pet: json['pet'] is Map<String, dynamic> ? DogEventPetRef.fromJson(json['pet']) : null,
    );
  }
}

