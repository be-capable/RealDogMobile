import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../utils/device_utils.dart';
import '../../utils/crypto_utils.dart';

class SignInterceptor extends Interceptor {
  // Should be in .env or secure config
  static const String _appSecret = 'real_dog_secret_salt_2025'; 

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = const Uuid().v4().substring(0, 8); // Short nonce

    // 1. Add Common Headers
    options.headers['X-App-Version'] = DeviceUtils.appVersion;
    options.headers['X-App-Build'] = DeviceUtils.buildNumber;
    options.headers['X-App-Device-Id'] = DeviceUtils.deviceId;
    options.headers['X-App-Platform'] = DeviceUtils.platform;
    options.headers['X-App-Timestamp'] = timestamp;
    options.headers['X-App-Nonce'] = nonce;

    // 2. Collect all params for signing
    final Map<String, dynamic> signParams = {};
    
    // Add Query Params
    signParams.addAll(options.queryParameters);
    
    // Add Body Params (if Map)
    if (options.data is Map<String, dynamic>) {
      signParams.addAll(options.data);
    }

    // Add Header Params involved in sign
    signParams['timestamp'] = timestamp;
    signParams['nonce'] = nonce;

    // 3. Generate Sign
    final sign = CryptoUtils.generateSignature(signParams, _appSecret);
    options.headers['X-App-Sign'] = sign;

    super.onRequest(options, handler);
  }
}
