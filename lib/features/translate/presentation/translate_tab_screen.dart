import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_session.dart';
import '../../home/application/home_controller.dart';
import '../../pets/application/selected_pet_controller.dart';
import 'translate_screen.dart';

class TranslateTabScreen extends ConsumerWidget {
  const TranslateTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).asData?.value;
    final selected = ref.watch(selectedPetControllerProvider).value;
    final homeAsync = session == null ? null : ref.watch(homeControllerProvider);
    final pet = homeAsync?.value?.currentPet;
    return TranslateScreen(
      petId: selected?.id ?? pet?.id,
      petName: selected?.name ?? pet?.name,
    );
  }
}
