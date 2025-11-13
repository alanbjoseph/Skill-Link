import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skill_link_new/utils/my_elevated_button.dart';
import 'package:skill_link_new/utils/my_text_form_field.dart';
import 'package:skill_link_new/features/user/repositories/profile_repository.dart';
import 'package:skill_link_new/features/user/providers/profile_providers.dart';
import 'package:skill_link_new/core/providers/supabase_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isLoading = false;
  String? _profilePictureUrl;

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user found');
      }

      // Upsert profile: if exists, update; else create new
      final existing = await ref.read(profileRepositoryProvider).getProfile(userId);
      if (existing == null) {
        await ref.read(profileRepositoryProvider).createProfile(
          userId: userId,
          fullName: _fullNameController.text.trim(),
          location: _locationController.text.trim(),
        );
      } else {
        await ref.read(profileRepositoryProvider).updateProfile(
          existing.copyWith(
            fullName: _fullNameController.text.trim(),
            location: _locationController.text.trim(),
          ),
        );
      }

      // Update optional fields if provided
      if (_bioController.text.trim().isNotEmpty || _profilePictureUrl != null) {
        final profile = await ref.read(profileRepositoryProvider).getProfile(userId);
        if (profile != null) {
          await ref.read(profileRepositoryProvider).updateProfile(
            profile.copyWith(
              bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
              profilePictureUrl: _profilePictureUrl,
            ),
          );
        }
      }

      if (!mounted) return;
      // Ensure router re-evaluates onboarding requirement with fresh data
      ref.invalidate(onboardingRequiredProvider);
      context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Skip option removed: onboarding is mandatory.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome! 👋',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s set up your profile to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Profile Picture Placeholder
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _profilePictureUrl != null
                            ? NetworkImage(_profilePictureUrl!)
                            : null,
                        child: _profilePictureUrl == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile picture upload coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Add Profile Picture (Optional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Full Name (Required)
                MyTextFormField(
                  controller: _fullNameController,
                  labelText: 'Full Name *',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location (Required)
                MyTextFormField(
                  controller: _locationController,
                  labelText: 'Location *',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bio (Optional) - Using standard TextFormField for multiline
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: 'Bio (Optional)',
                    hintText: 'Tell others a bit about yourself',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 24),

                // Complete Button
                MyElevatedButton(
                  text: _isLoading ? 'Setting up...' : 'Complete Setup',
                  onPressed: () {
                    if (!_isLoading) {
                      _completeOnboarding();
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
