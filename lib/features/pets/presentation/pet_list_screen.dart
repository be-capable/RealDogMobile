import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../../auth/application/auth_controller.dart';
import '../application/pets_controller.dart';
import '../domain/pet_model.dart';

class PetListScreen extends ConsumerWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Pets', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primary)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pets/create'),
        label: Text('Add Pet', style: Theme.of(context).textTheme.labelLarge),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.cta,
        elevation: 4,
      ),
      body: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClayContainer(
                    borderRadius: 80,
                    color: Colors.white,
                    child: Icon(Icons.pets, size: 80, color: Colors.grey[300]),
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
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            itemCount: pets.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spaceMD),
            itemBuilder: (context, index) {
              final pet = pets[index];
              return _PetCard(pet: pet).animate().fadeIn(delay: (100 * index).ms).slideX();
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      color: Colors.white,
      borderRadius: 24,
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
                Text(pet.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.text)),
                Text('${pet.breedId} • ${pet.sex.name.toUpperCase()}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.text.withValues(alpha: 0.6))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.cta),
        ],
      ),
    );
  }
}
