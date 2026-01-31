import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/storage_service.dart';

class SelectedPetSelection {
  final int id;
  final String name;
  const SelectedPetSelection({required this.id, required this.name});
}

final selectedPetControllerProvider =
    AsyncNotifierProvider<SelectedPetController, SelectedPetSelection?>(SelectedPetController.new);

class SelectedPetController extends AsyncNotifier<SelectedPetSelection?> {
  @override
  FutureOr<SelectedPetSelection?> build() async {
    final storage = ref.watch(storageServiceProvider);
    final id = await storage.getSelectedPetId();
    if (id == null) return null;
    final name = await storage.getSelectedPetName();
    return SelectedPetSelection(id: id, name: name ?? 'Pet #$id');
  }

  Future<void> setSelectedPet(SelectedPetSelection selection) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setSelectedPet(id: selection.id, name: selection.name);
    state = AsyncValue.data(selection);
  }

  Future<void> clear() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearSelectedPet();
    state = const AsyncValue.data(null);
  }
}

