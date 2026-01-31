import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _selectedPetIdKey = 'selected_pet_id';
  static const _selectedPetNameKey = 'selected_pet_name';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _storage.write(key: _hasSeenOnboardingKey, value: value ? '1' : '0');
  }

  Future<bool> getHasSeenOnboarding() async {
    final raw = await _storage.read(key: _hasSeenOnboardingKey);
    return raw == '1';
  }

  Future<void> setSelectedPet({
    required int id,
    required String name,
  }) async {
    await _storage.write(key: _selectedPetIdKey, value: id.toString());
    await _storage.write(key: _selectedPetNameKey, value: name);
  }

  Future<int?> getSelectedPetId() async {
    final raw = await _storage.read(key: _selectedPetIdKey);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<String?> getSelectedPetName() async {
    final raw = await _storage.read(key: _selectedPetNameKey);
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  Future<void> clearSelectedPet() async {
    await _storage.delete(key: _selectedPetIdKey);
    await _storage.delete(key: _selectedPetNameKey);
  }
}
