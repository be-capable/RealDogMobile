import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/application/home_controller.dart';
import '../../pets/application/selected_pet_controller.dart';
import 'dialogue_screen.dart';

class TalkTabScreen extends ConsumerWidget {
  const TalkTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeControllerProvider);
    final selected = ref.watch(selectedPetControllerProvider).value;
    final pet = homeAsync.value?.currentPet;
    return DialogueScreen(
      petId: selected?.id ?? pet?.id,
      petName: selected?.name ?? pet?.name,
    );
  }
}
