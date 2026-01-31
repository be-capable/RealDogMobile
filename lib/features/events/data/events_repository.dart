import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';
import '../domain/dog_event_model.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final http = ref.watch(httpServiceProvider);
  return EventsRepository(http);
});

class EventsRepository {
  final HttpService _http;
  EventsRepository(this._http);

  Future<DogEvent> createEvent({
    required int petId,
    required String eventType,
    String? stateType,
    String? contextType,
    double? confidence,
    String? audioUrl,
  }) async {
    final res = await _http.post(
      '/pets/$petId/events',
      data: {
        'eventType': eventType,
        'stateType': stateType,
        'contextType': contextType,
        'confidence': confidence,
        'audioUrl': audioUrl,
      },
    );
    return DogEvent.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<DogEvent> getEvent(int eventId) async {
    final res = await _http.get('/events/$eventId');
    return DogEvent.fromJson(Map<String, dynamic>.from(res.data));
  }
}

