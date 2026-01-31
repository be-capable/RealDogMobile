import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';
import '../domain/translate_models.dart';

final translateRepositoryProvider = Provider<TranslateRepository>((ref) {
  final http = ref.watch(httpServiceProvider);
  return TranslateRepository(http);
});

/// Repository for handling Dog Translation features.
///
/// This includes:
/// - Uploading dog audio to interpret (Dog -> Human).
/// - Uploading human audio to synthesize (Human -> Dog).
/// - Parsing responses and handling errors.
class TranslateRepository {
  final HttpService _http;
  TranslateRepository(this._http);

  String _filenameFromPath(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? 'audio.wav' : parts.last;
  }

  String _origin() {
    final base = _http.client.options.baseUrl;
    return base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  }

  /// Converts a relative backend path to a full absolute URL for playback.
  String absoluteUrl(String urlOrPath) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://'))
      return urlOrPath;
    return '${_origin()}$urlOrPath';
  }

  /// Sends dog audio to the AI backend for interpretation.
  ///
  /// [petId] - ID of the pet (for logging).
  /// [audioPath] - Local file path of the recording.
  /// [locale] - Target language locale (e.g. 'en-US', 'zh-CN').
  /// [contextText] - Optional context to help the AI.
  Future<TranslateResult> interpretDogAudio({
    required int petId,
    required String audioPath,
    required String locale,
    String? contextText,
  }) async {
    try {
      final data = FormData.fromMap({
        'petId': petId,
        'locale': locale,
        if (contextText != null && contextText.trim().isNotEmpty)
          'context': contextText.trim(),
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: _filenameFromPath(audioPath),
        ),
      });
      final res = await _http.post<Map<String, dynamic>>(
        '/ai/dog/interpret',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = Map<String, dynamic>.from(res.data ?? const {});
      return TranslateResult(
        eventId: (json['eventId'] as num).toInt(),
        inputAudioUrl: absoluteUrl(json['inputAudioUrl'] as String),
        meaningText: json['meaningText'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Sends human audio to the AI backend to synthesize a dog response.
  ///
  /// Currently uses the Synchronous endpoint.
  /// Warning: May timeout if generation takes > 15s.
  /// Future work: Use polling via `/ai/dog/synthesize-task`.
  Future<TranslateResult> synthesizeDogAudio({
    required int petId,
    required String audioPath,
    required String locale,
    String? style,
  }) async {
    try {
      final data = FormData.fromMap({
        'petId': petId,
        'locale': locale,
        if (style != null && style.trim().isNotEmpty) 'style': style.trim(),
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: _filenameFromPath(audioPath),
        ),
      });
      final res = await _http.post<Map<String, dynamic>>(
        '/ai/dog/synthesize',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = Map<String, dynamic>.from(res.data ?? const {});
      return TranslateResult(
        eventId: (json['eventId'] as num).toInt(),
        inputAudioUrl: absoluteUrl(json['inputAudioUrl'] as String),
        outputAudioUrl: absoluteUrl(json['outputAudioUrl'] as String),
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String)
      return data['message'] as String;
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return 'Request failed';
  }
}
