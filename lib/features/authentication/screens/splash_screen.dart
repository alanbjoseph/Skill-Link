import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skill_link_new/features/authentication/providers/auth_controller.dart';
import 'package:skill_link_new/features/user/repositories/profile_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasSetListener = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen must be used inside build; ensure we only register the
    // listener once to avoid multiple registrations across rebuilds.
    if (!_hasSetListener) {
      _hasSetListener = true;
      // Listen to auth state and immediately react to the current value.
      void handleAuthState(AsyncValue next) async {
        final user = next.asData?.value;
        // Schedule navigation after this frame to avoid calling
        // context.go during the widget build (which causes setState errors).
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          try {
            if (user != null) {
              // Check if user has completed their profile (require both name and location)
              final profile = await ref.read(profileRepositoryProvider).getCurrentUserProfile();

              if (!mounted) return;

              final needsOnboarding = profile == null ||
                  (profile.fullName == null || profile.fullName!.trim().isEmpty) ||
                  (profile.location == null || profile.location!.trim().isEmpty);

              if (needsOnboarding) {
                // Profile not complete, redirect to onboarding
                context.go('/onboarding');
              } else {
                // Profile complete, redirect to home
                context.go('/home');
              }
            } else {
              context.go('/login');
            }
          } catch (e) {
            // Navigation may still fail if router isn't ready; swallow and let
            // future auth events retry navigation.
          }
        });
      }

      ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
        handleAuthState(next);
      });

      // Also run the handler immediately with the current value so we react
      // to the provider's state without relying on an unavailable parameter.
      handleAuthState(ref.read(authControllerProvider));
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
