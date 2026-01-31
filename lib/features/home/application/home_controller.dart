import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../events/data/events_repository.dart';
import '../data/home_repository.dart';
import '../domain/home_feed_model.dart';

final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeFeed>(HomeController.new);

class HomeController extends AsyncNotifier<HomeFeed> {
  @override
  Future<HomeFeed> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    return repo.getHome();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(homeRepositoryProvider).getHome());
  }

  Future<void> createQuickEvent({
    required int petId,
    required String eventType,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(eventsRepositoryProvider).createEvent(petId: petId, eventType: eventType);
      return ref.read(homeRepositoryProvider).getHome();
    });
  }
}

