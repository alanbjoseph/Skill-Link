import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:skill_link_new/core/providers/supabase_providers.dart';

/// Abstraction for authentication operations used by the UI and controllers.
abstract class AuthRepository {
	/// Create a new user using email/password. Returns the created [User]
	/// or `null` if creation succeeded but no user object was returned.
	Future<User?> signUp({required String email, required String password});

	/// Sign in an existing user using email/password. Returns the signed-in [User]
	/// or `null` if sign-in succeeded but no user object was returned.
	Future<User?> signIn({required String email, required String password});

	/// Sign out the current user.
	Future<void> signOut();

	/// Send a password reset email to [email].
	Future<void> sendPasswordReset({required String email});

	/// Current logged in user (if any).
	User? get currentUser;

	/// Emits the current [Session] and subsequent auth state changes.
	Stream<Session?> authStateChanges();
}

/// Supabase implementation of [AuthRepository].
class SupabaseAuthRepository implements AuthRepository {
	final SupabaseClient _client;

	SupabaseAuthRepository(this._client);

	@override
	Future<User?> signUp({required String email, required String password}) async {
		final res = await _client.auth.signUp(email: email, password: password);
		
		// Profile will be automatically created by the database trigger
		// If you didn't set up the trigger, you can manually create the profile here:
		// if (res.user != null) {
		//   await _client.from('profiles').insert({
		//     'id': res.user!.id,
		//     'full_name': email.split('@')[0],
		//     'created_at': DateTime.now().toIso8601String(),
		//   });
		// }
		
		return res.user;
	}

	@override
	Future<User?> signIn({required String email, required String password}) async {
		final res = await _client.auth.signInWithPassword(email: email, password: password);
		return res.user;
	}

	@override
	Future<void> signOut() async {
		await _client.auth.signOut();
	}

	@override
	Future<void> sendPasswordReset({required String email}) async {
		// Use Supabase's reset password flow. If your Supabase SDK version
		// exposes a different helper, adjust this call accordingly.
		await _client.auth.resetPasswordForEmail(email);
	}

	@override
	User? get currentUser => _client.auth.currentUser;

	@override
	Stream<Session?> authStateChanges() {
		return _client.auth.onAuthStateChange.map((event) => event.session);
	}
}

/// Riverpod provider that exposes an [AuthRepository] backed by Supabase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
	final client = ref.read(supabaseClientProvider);
	return SupabaseAuthRepository(client);
});

