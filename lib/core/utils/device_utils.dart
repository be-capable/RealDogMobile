import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _deviceId;
  static String? _appVersion;
  static String? _buildNumber;

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      _deviceId = androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor; // IDFV
    } else {
      _deviceId = const Uuid().v4(); // Fallback
    }
  }

  static String get deviceId => _deviceId ?? 'unknown';
  static String get appVersion => _appVersion ?? '1.0.0';
  static String get buildNumber => _buildNumber ?? '1';
  static String get platform => Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
}
