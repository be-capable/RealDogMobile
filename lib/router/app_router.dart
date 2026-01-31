import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/pets/presentation/pet_list_screen.dart';
import '../features/pets/presentation/create_pet_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
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
        path: '/home',
        builder: (context, state) => const PetListScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/pets',
        builder: (context, state) => const PetListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreatePetScreen(),
          ),
        ],
      ),
    ],
  );
});
