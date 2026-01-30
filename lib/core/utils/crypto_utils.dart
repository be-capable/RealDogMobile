import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  /// Generates MD5 signature for parameters
  /// [params] includes query params, body params, and common headers
  /// [salt] is the secret key shared with backend
  static String generateSignature(Map<String, dynamic> params, String salt) {
    // 1. Filter out null or empty values
    final validParams = Map<String, dynamic>.from(params)
      ..removeWhere((key, value) => value == null || value.toString().isEmpty);

    // 2. Sort keys ASCII
    final sortedKeys = validParams.keys.toList()..sort();

    // 3. Concat key=value&key=value
    final buffer = StringBuffer();
    for (var i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = validParams[key];
      
      // Handle nested maps/lists if necessary, for now assume flat or toString
      buffer.write('$key=$value');
      if (i < sortedKeys.length - 1) {
        buffer.write('&');
      }
    }

    // 4. Append salt
    buffer.write(salt);

    // 5. MD5
    final bytes = utf8.encode(buffer.toString());
    final digest = md5.convert(bytes);

    return digest.toString();
  }
}
