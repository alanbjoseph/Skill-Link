import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_link_new/features/tasks/models/task.dart';
import 'package:skill_link_new/core/providers/supabase_providers.dart';

final posterTasksProvider = FutureProvider<List<Task>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('User is not logged in');
  }

  final rawData = await supabase
      .from('tasks')
      .select()
      .eq('poster_id', userId); // This returns List<dynamic>

  // Convert to strongly typed Task list
  return (rawData as List<dynamic>)
      .map((json) => Task.fromJson(json as Map<String, dynamic>))
      .toList();
});
