import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../application/pets_controller.dart';
import '../application/selected_pet_controller.dart';
import '../domain/pet_model.dart';

class PetListScreen extends ConsumerWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsControllerProvider);
    final selectedPet = ref.watch(selectedPetControllerProvider).value;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pets/create'),
        label: Text('Add Pet', style: Theme.of(context).textTheme.labelLarge),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.cta,
        elevation: 4,
      ),
      body: SafeArea(
        child: petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClayContainer(
                      borderRadius: 80,
                      color: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/gifs/dog_wag_128.gif',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('No pets yet', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Add your furry friend to get started!', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ).animate().fadeIn(),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              itemCount: pets.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spaceMD),
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isSelected = selectedPet?.id == pet.id;
                return _PetCard(
                  pet: pet,
                  selected: isSelected,
                  onTap: () async {
                    await ref.read(selectedPetControllerProvider.notifier).setSelectedPet(
                          SelectedPetSelection(id: pet.id, name: pet.name),
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected ${pet.name}'),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(AppTheme.spaceLG),
                      ),
                    );
                    context.go('/translate');
                  },
                ).animate().fadeIn(delay: (100 * index).ms).slideX();
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  final bool selected;
  final VoidCallback onTap;
  const _PetCard({
    required this.pet,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      onTap: onTap,
      color: Colors.white,
      borderRadius: 28,
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Row(
        children: [
          ClayContainer(
            width: 60,
            height: 60,
            borderRadius: 30,
            padding: EdgeInsets.zero,
            color: AppTheme.primary.withValues(alpha: 0.1),
            child: const Center(
              child: Icon(Icons.pets, color: AppTheme.primary, size: 30),
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.text,
                      ),
                ),
                Text(
                  '${pet.breedId} • ${pet.sex.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.text.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check_circle, color: AppTheme.primary),
          if (!selected) const Icon(Icons.chevron_right, color: AppTheme.cta),
        ],
      ),
    );
  }
}
