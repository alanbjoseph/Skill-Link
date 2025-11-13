import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/post_form.dart';
import 'package:skill_link_new/features/tasks/models/task.dart';
import 'package:skill_link_new/features/tasks/repositories/task_repository.dart';
import 'package:skill_link_new/core/providers/supabase_providers.dart';
import 'package:skill_link_new/features/user/repositories/profile_repository.dart';

class PostFormNotifier extends Notifier<PostForm> {
  @override
  PostForm build() {
    return const PostForm();
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updateBudget(double value) {
    state = state.copyWith(budget: value);
  }

  void updateLocation(String value) {
    state = state.copyWith(location: value);
  }

  void updateCategory(String value) {
    state = state.copyWith(category: value);
  }

  void toggleRemote(bool value) {
    state = state.copyWith(isRemote: value);
  }

  void setPhotoPath(String? path) {
    state = state.copyWith(photoPath: path);
  }

  void setDeadline(DateTime? deadline) {
    state = state.copyWith(deadline: deadline);
  }

  void reset() {
    state = const PostForm();
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      return false;
    }

    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure a profile row exists for this user to satisfy FK tasks.poster_id -> profiles.id
      final profileRepo = ref.read(profileRepositoryProvider);
      final existingProfile = await profileRepo.getProfile(userId);
      if (existingProfile == null) {
        final email = supabase.auth.currentUser?.email;
        await profileRepo.createProfile(
          userId: userId,
          fullName: email != null ? email.split('@').first : null,
        );
      }

      final taskRepo = ref.read(taskRepositoryProvider);
      
      final task = Task(
        id: const Uuid().v4(),
        posterId: userId,
        title: state.title,
        description: state.description,
        budget: state.budget,
        status: 'open',
        location: state.location,
        isRemote: state.isRemote,
        category: state.category,
        deadline: state.deadline,
        createdAt: DateTime.now(),
      );

      await taskRepo.createTask(task);

      // Reset form on success
      state = const PostForm();
      return true;
    } catch (e) {
      // Surface the error to the caller so UI can show feedback
      rethrow;
    }
  }
}

final postFormProvider = NotifierProvider<PostFormNotifier, PostForm>(
  PostFormNotifier.new,
);
