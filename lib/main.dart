import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'core/utils/device_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceUtils.init();
  runApp(const ProviderScope(child: RealDogApp()));
}

class RealDogApp extends ConsumerWidget {
  const RealDogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RealDog',
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
