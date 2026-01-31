import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pets_repository.dart';
import '../domain/pet_model.dart';
import 'selected_pet_controller.dart';

final petsControllerProvider = AsyncNotifierProvider<PetsController, List<Pet>>(PetsController.new);

class PetsController extends AsyncNotifier<List<Pet>> {
  @override
  Future<List<Pet>> build() async {
    final repository = ref.watch(petsRepositoryProvider);
    return repository.getPets();
  }

  Future<void> createPet({
    required String name,
    required PetSex sex,
    required DateTime birthDate,
    required String breedId,
    File? avatarImage,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(petsRepositoryProvider);
      
      // 1. Create Pet
      final pet = await repository.createPet({
        'name': name,
        'sex': sex.toJson(),
        'birthDate': birthDate.toIso8601String(),
        'breedId': breedId,
      });

      // 2. Upload Avatar if selected
      if (avatarImage != null) {
        await repository.uploadAvatar(pet.id, avatarImage);
      }

      // 3. Return updated list
      await ref.read(selectedPetControllerProvider.notifier).setSelectedPet(
            SelectedPetSelection(id: pet.id, name: pet.name),
          );
      return repository.getPets();
    });
  }

  Future<void> deletePet(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(petsRepositoryProvider);
      await repository.deletePet(id);
      final selected = ref.read(selectedPetControllerProvider).value;
      if (selected?.id == id) {
        await ref.read(selectedPetControllerProvider.notifier).clear();
      }
      return repository.getPets();
    });
  }
}
