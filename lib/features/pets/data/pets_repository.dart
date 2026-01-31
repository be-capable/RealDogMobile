import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';
import '../domain/pet_model.dart';

final petsRepositoryProvider = Provider<PetsRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return PetsRepository(httpService);
});

class PetsRepository {
  final HttpService _httpService;

  PetsRepository(this._httpService);

  Future<List<Pet>> getPets() async {
    final response = await _httpService.get('/pets');
    return (response.data as List).map((e) => Pet.fromJson(e)).toList();
  }

  Future<Pet> createPet(Map<String, dynamic> data) async {
    final response = await _httpService.post('/pets', data: data);
    return Pet.fromJson(response.data);
  }

  Future<void> uploadAvatar(int petId, File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
    });
    
    await _httpService.post(
      '/pets/$petId/avatar',
      data: formData,
    );
  }

  Future<void> deletePet(int id) async {
    await _httpService.delete('/pets/$id');
  }
}
