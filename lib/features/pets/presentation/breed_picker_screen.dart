import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../data/breeds_repository.dart';
import '../domain/breed_model.dart';

final breedsProvider = FutureProvider.autoDispose.family<List<DogBreed>, String?>((ref, q) async {
  return ref.read(breedsRepositoryProvider).listBreeds(q: q);
});

class BreedPickerScreen extends HookConsumerWidget {
  final String? initialBreedId;
  const BreedPickerScreen({super.key, this.initialBreedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState('');
    final debouncedQuery = useState('');

    useEffect(() {
      final t = Timer(const Duration(milliseconds: 250), () {
        debouncedQuery.value = query.value;
      });
      return t.cancel;
    }, [query.value]);

    final breedsAsync = ref.watch(breedsProvider(debouncedQuery.value));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => query.value = v.trim(),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              Expanded(
                child: breedsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (breeds) {
                    if (breeds.isEmpty) {
                      return ClayContainer(
                        borderRadius: 28,
                        color: Colors.white,
                        child: Text(
                          'No results. Try another keyword.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: breeds.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spaceMD),
                      itemBuilder: (context, index) {
                        final b = breeds[index];
                        final selected = b.id == initialBreedId;
                        return ClayContainer(
                          onTap: () => Navigator.of(context).pop(b),
                          borderRadius: 28,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.displayName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      b.id,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.text.withValues(alpha: 0.55),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected) const Icon(Icons.check, color: AppTheme.primary),
                              if (!selected) const Icon(Icons.chevron_right, color: AppTheme.cta),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
