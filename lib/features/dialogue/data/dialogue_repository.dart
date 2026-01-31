import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';
import '../domain/dialogue_models.dart';

final dialogueRepositoryProvider = Provider<DialogueRepository>((ref) {
  final http = ref.watch(httpServiceProvider);
  return DialogueRepository(http);
});

class DialogueRepository {
  final HttpService _http;
  DialogueRepository(this._http);

  Future<DialogueTurnResult> turn({
    required DialogueMode mode,
    required String inputText,
    int? petId,
    String? locale,
  }) async {
    try {
      final res = await _http.post(
        '/ai/dialogue/turn',
        data: {
          'mode': dialogueModeToApi(mode),
          'inputText': inputText,
          'petId': petId,
          'locale': locale,
        },
      );
      return DialogueTurnResult.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Send failed. Check network or try again.';
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      } else if (data is String && data.trim().isNotEmpty) {
        message = data.trim();
      }
      throw Exception(message);
    }
  }
}
