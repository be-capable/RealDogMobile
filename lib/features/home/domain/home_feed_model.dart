import '../../events/domain/dog_event_model.dart';
import '../../pets/domain/pet_model.dart';

class WeeklySummary {
  final int rangeDays;
  final int total;
  final Map<String, int> byEventType;

  WeeklySummary({required this.rangeDays, required this.total, required this.byEventType});

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    final raw = json['byEventType'] as Map<String, dynamic>? ?? {};
    return WeeklySummary(
      rangeDays: json['rangeDays'] ?? 7,
      total: json['total'] ?? 0,
      byEventType: raw.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}

class HomeFeed {
  final Pet? currentPet;
  final List<DogEvent> recentEvents;
  final WeeklySummary weeklySummary;

  HomeFeed({required this.currentPet, required this.recentEvents, required this.weeklySummary});

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    final currentPetJson = json['currentPet'];
    final recentEventsJson = (json['recentEvents'] as List? ?? []).cast<Map<String, dynamic>>();
    final weeklySummaryJson = (json['weeklySummary'] as Map<String, dynamic>? ?? {});

    return HomeFeed(
      currentPet: currentPetJson is Map<String, dynamic> ? Pet.fromJson(currentPetJson) : null,
      recentEvents: recentEventsJson.map(DogEvent.fromJson).toList(),
      weeklySummary: WeeklySummary.fromJson(weeklySummaryJson),
    );
  }
}

