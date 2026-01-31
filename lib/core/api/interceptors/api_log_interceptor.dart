import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLogInterceptor extends Interceptor {
  final int maxBodyChars;
  final int maxResponseChars;

  ApiLogInterceptor({
    this.maxBodyChars = 4000,
    this.maxResponseChars = 8000,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final traceId = _traceId();
    options.extra['rd_trace_id'] = traceId;
    options.extra['rd_start_ms'] = DateTime.now().millisecondsSinceEpoch;

    _logBlock([
      '>>  [$traceId] ${options.method} ${options.baseUrl}${options.path}',
      if (options.queryParameters.isNotEmpty) 'query: ${_pretty(options.queryParameters, maxChars: maxBodyChars)}',
      if (options.headers.isNotEmpty) 'headers: ${_pretty(_redactHeaders(options.headers), maxChars: maxBodyChars)}',
      if (options.data != null) 'body: ${_pretty(_normalizeBody(options.data), maxChars: maxBodyChars)}',
    ]);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final traceId = (options.extra['rd_trace_id'] as String?) ?? '------';
    final ms = _elapsedMs(options);

    _logBlock([
      '<<  [$traceId] ${options.method} ${options.baseUrl}${options.path}  ${response.statusCode}  ${ms}ms',
      if (response.headers.map.isNotEmpty) 'headers: ${_pretty(response.headers.map, maxChars: maxBodyChars)}',
      if (response.data != null) 'data: ${_pretty(response.data, maxChars: maxResponseChars)}',
    ]);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final traceId = (options.extra['rd_trace_id'] as String?) ?? '------';
    final ms = _elapsedMs(options);

    final status = err.response?.statusCode;
    final serverData = err.response?.data;

    _logBlock([
      '!!  [$traceId] ${options.method} ${options.baseUrl}${options.path}  ${status ?? '-'}  ${ms}ms',
      'type: ${err.type}',
      if (err.message != null) 'message: ${err.message}',
      if (options.queryParameters.isNotEmpty) 'query: ${_pretty(options.queryParameters, maxChars: maxBodyChars)}',
      if (options.headers.isNotEmpty) 'headers: ${_pretty(_redactHeaders(options.headers), maxChars: maxBodyChars)}',
      if (options.data != null) 'body: ${_pretty(_normalizeBody(options.data), maxChars: maxBodyChars)}',
      if (serverData != null) 'server: ${_pretty(serverData, maxChars: maxResponseChars)}',
    ]);
    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final out = <String, dynamic>{};
    for (final entry in headers.entries) {
      final k = entry.key.toLowerCase();
      if (k == 'authorization' || k == 'cookie' || k == 'set-cookie') {
        out[entry.key] = '<redacted>';
      } else {
        out[entry.key] = entry.value;
      }
    }
    return out;
  }

  Object? _normalizeBody(Object? body) {
    if (body == null) return null;
    if (body is FormData) {
      return {
        'fields': body.fields.map((e) => {'name': e.key, 'value': _limitString(e.value, maxBodyChars)}).toList(),
        'files': body.files
            .map((e) => {
                  'name': e.key,
                  'filename': e.value.filename,
                  'contentType': e.value.contentType?.toString(),
                  'length': e.value.length,
                })
            .toList(),
      };
    }
    return body;
  }

  String _traceId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final r = (now ^ (now << 13)) & 0xffffffff;
    return r.toRadixString(16).padLeft(8, '0');
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra['rd_start_ms'];
    if (start is! int) return -1;
    return DateTime.now().millisecondsSinceEpoch - start;
  }

  String _pretty(Object? v, {required int maxChars}) {
    if (v == null) return 'null';
    try {
      final s = const JsonEncoder.withIndent('  ').convert(v);
      return _limitString(s, maxChars);
    } catch (_) {
      return _limitString(v.toString(), maxChars);
    }
  }

  String _limitString(String s, int maxChars) {
    if (s.length <= maxChars) return s;
    return '${s.substring(0, maxChars)}…(${s.length - maxChars} more chars)';
  }

  void _logBlock(List<String> lines) {
    if (!kDebugMode) return;
    final text = lines.where((e) => e.trim().isNotEmpty).join('\n');
    debugPrint(text);
  }
}
