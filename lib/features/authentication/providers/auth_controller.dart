import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

/// AsyncNotifier that exposes the current authenticated [User?] and
/// provides convenience methods to sign in / sign up / sign out / reset
/// password while delegating actual work to [AuthRepository].
class AuthController extends AsyncNotifier<User?> {
  late final AuthRepository _repo;
  StreamSubscription<Session?>? _sub;

  @override
  FutureOr<User?> build() async {
    _repo = ref.read(authRepositoryProvider);

    // Initialize state with currently signed-in user (if any)
    final current = _repo.currentUser;

    // Subscribe to auth state changes and update state accordingly
    _sub = _repo.authStateChanges().listen((session) {
      // Update notifier state when auth changes
      state = AsyncValue.data(session?.user);
    });

    // Ensure the subscription is cancelled when the notifier/provider is disposed
    ref.onDispose(() {
      _sub?.cancel();
    });

    return current;
  }

  Future<User?> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signIn(email: email, password: password);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<User?> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signUp(email: email, password: password);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repo.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    // Do not change global auth state for password reset, but reflect any errors
    try {
      await _repo.sendPasswordReset(email: email);
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider that exposes [AuthController] as an AsyncNotifier of [User?].
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);
