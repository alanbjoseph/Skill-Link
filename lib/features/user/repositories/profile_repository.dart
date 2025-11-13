import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:skill_link_new/core/providers/supabase_providers.dart';
import 'package:skill_link_new/features/user/models/profile.dart';

/// Repository for managing user profiles
abstract class ProfileRepository {
  /// Create a new profile
  Future<Profile> createProfile({
    required String userId,
    String? fullName,
    String? location,
  });

  /// Get profile by user ID
  Future<Profile?> getProfile(String userId);

  /// Update existing profile
  Future<Profile> updateProfile(Profile profile);

  /// Get current user's profile
  Future<Profile?> getCurrentUserProfile();
}

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository(this._client);

  @override
  Future<Profile> createProfile({
    required String userId,
    String? fullName,
    String? location,
  }) async {
    final data = await _client.from('profiles').insert({
      'id': userId,
      'full_name': fullName,
      'location': location,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    return Profile.fromJson(data);
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(data);
    } catch (e) {
      // Profile doesn't exist
      return null;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final data = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();

    return Profile.fromJson(data);
  }

  @override
  Future<Profile?> getCurrentUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    return getProfile(userId);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseProfileRepository(client);
});
