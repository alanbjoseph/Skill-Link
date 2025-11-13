import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:skill_link_new/features/authentication/screens/login_screen.dart';
import 'package:skill_link_new/features/authentication/screens/signup_screen.dart';
import 'package:skill_link_new/features/authentication/screens/onboarding_screen.dart';
import 'package:skill_link_new/features/authentication/screens/password_reset_screen.dart';
import 'package:skill_link_new/features/user/screens/home_screen.dart';
import 'package:skill_link_new/features/tasks/screens/task_detail_screen.dart';
import 'package:skill_link_new/features/user/screens/chat_screen.dart';
import 'package:skill_link_new/features/authentication/providers/auth_controller.dart';
import 'package:skill_link_new/features/user/providers/profile_providers.dart';

/// Router provider which watches [authControllerProvider] and performs simple
/// route guarding: unauthenticated users are redirected to `/login`, and
/// authenticated users are redirected away from auth screens to `/home`.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  String? redirectLogic(BuildContext context, GoRouterState state) {
    // Paths considered part of the unauthenticated flow (login/signup/reset)
    const authPaths = ['/login', '/signup', '/password_reset'];
    // Onboarding is accessible to authenticated users
    const onboardingPath = '/onboarding';

      // While auth state is loading, don't redirect — allow splash or current route
      if (authState.isLoading) return null;

      // If there is no authenticated user, send them to the login flow.
      final user = authState.asData?.value;

  // Determine current path from the GoRouterState. Use the state's URI which
  // is available during redirect handling.
      final currentPath = state.uri.path;
      final isAuthPath = authPaths.any((p) => currentPath == p || currentPath.startsWith('$p/'));
      final isOnboarding = currentPath == onboardingPath;

      if (user == null) {
        // Not signed in: ensure user is on an auth path (not onboarding)
        return (isAuthPath || isOnboarding) && !isOnboarding ? null : '/login';
      }

      // If profile is incomplete, force onboarding from anywhere except onboarding itself
      final onboardingAsync = ref.read(onboardingRequiredProvider);
      final needsOnboarding = onboardingAsync.maybeWhen(data: (v) => v, orElse: () => null);
      if (needsOnboarding == true && !isOnboarding) {
        return '/onboarding';
      }

      // Signed-in users: allow onboarding route itself, and allow staying on signup to finish redirect
      if (isOnboarding) return null;
      if (currentPath == '/signup') return null;
      
      // Signed-in users should not visit auth screens — redirect them to /home
      return isAuthPath ? '/home' : null;
  }

  return GoRouter(
    // Start at login; redirects will move user appropriately
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/password_reset', builder: (_, __) => const PasswordResetScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/task/:id',
        builder: (_, state) {
          final taskId = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) {
          final chatId = state.pathParameters['id']!;
          return ChatScreen(chatId: chatId);
        },
      ),
      // add later: payments, etc.
    ],
    redirect: redirectLogic,
  );
});
