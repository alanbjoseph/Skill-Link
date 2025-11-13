import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:skill_link_new/features/user/repositories/profile_repository.dart';

/// Returns true if the current user must complete onboarding (profile missing
/// or required fields empty). Returns false if profile is complete.
/// While loading or on error, the provider yields an error/loading state; callers
/// should decide how to handle that transient state.
final onboardingRequiredProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final profile = await repo.getCurrentUserProfile();
  if (profile == null) return true;
  final hasName = (profile.fullName != null && profile.fullName!.trim().isNotEmpty);
  final hasLocation = (profile.location != null && profile.location!.trim().isNotEmpty);
  return !(hasName && hasLocation);
});
