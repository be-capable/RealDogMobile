import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_session.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/dialogue/presentation/dialogue_screen.dart';
import '../features/events/presentation/event_detail_screen.dart';
import '../features/me/presentation/me_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/pets/presentation/pet_list_screen.dart';
import '../features/pets/presentation/create_pet_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/translate/presentation/translate_tab_screen.dart';
import '../shell/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();
  final refresh = ValueNotifier<int>(0);
  ref.listen(authSessionProvider, (prev, next) => refresh.value++);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authSessionProvider);
      final session = auth.asData?.value;
      final loc = state.matchedLocation;
      final isPublic = loc == '/splash' ||
          loc == '/login' ||
          loc == '/register' ||
          loc == '/forgot-password' ||
          loc == '/reset-password';

      if (auth.isLoading) return null;

      if (session == null && !isPublic) return '/login';
      if (session != null && (loc == '/login' || loc == '/register')) return '/translate';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.extra as String;
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/pets/create',
        builder: (context, state) => const CreatePetScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/events/:eventId',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['eventId']!);
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/dialogue',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            final petId = extra['petId'];
            final petName = extra['petName'];
            return DialogueScreen(
              petId: petId is int ? petId : null,
              petName: petName is String ? petName : null,
            );
          }
          return const DialogueScreen();
        },
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const TranslateTabScreen(),
          ),
          GoRoute(
            path: '/translate',
            builder: (context, state) => const TranslateTabScreen(),
          ),
          GoRoute(
            path: '/pets',
            builder: (context, state) => const PetListScreen(),
          ),
          GoRoute(
            path: '/me',
            builder: (context, state) => const MeScreen(),
          ),
          GoRoute(
            path: '/talk',
            redirect: (context, state) => '/translate',
          ),
        ],
      ),
    ],
  );
});
