import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:skill_link_new/core/providers/supabase_providers.dart';
import 'package:skill_link_new/features/tasks/models/task.dart';
import 'package:skill_link_new/features/tasks/models/bid.dart';
import 'package:skill_link_new/features/user/models/chat.dart';

/// Repository for managing tasks and bids
abstract class TaskRepository {
  /// Create a new task
  Future<Task> createTask(Task task);

  /// Get task by ID
  Future<Task?> getTaskById(String taskId);

  /// Fetch all tasks with optional filters
  Future<List<Task>> fetchTasks({
    String? status,
    String? category,
    int limit = 20,
    int offset = 0,
  });

  /// Fetch tasks posted by a specific user
  Future<List<Task>> fetchUserTasks(String userId);

  /// Fetch tasks where user has placed bids
  Future<List<Task>> fetchTasksWithUserBids(String userId);

  /// Update a task
  Future<Task> updateTask(Task task);

  /// Delete a task
  Future<void> deleteTask(String taskId);

  /// Create a bid on a task
  Future<Bid> createBid(Bid bid);

  /// Get all bids for a task
  Future<List<Bid>> getBidsForTask(String taskId);

  /// Get a specific bid
  Future<Bid?> getBidById(String bidId);

  /// Update bid status
  Future<Bid> updateBid(Bid bid);

  /// Accept a bid (assign task to worker)
  Future<void> acceptBid(String bidId, String taskId);
}

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client;

  SupabaseTaskRepository(this._client);

  @override
  Future<Task> createTask(Task task) async {
    final data = await _client
        .from('tasks')
        .insert(task.toJson())
        .select()
        .single();

    return Task.fromJson(data);
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    try {
      final data = await _client
          .from('tasks')
          .select()
          .eq('id', taskId)
          .single();

      return Task.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Task>> fetchTasks({
    String? status,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client.from('tasks').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    if (category != null) {
      query = query.eq('category', category);
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List<dynamic>)
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Task>> fetchUserTasks(String userId) async {
    final data = await _client
        .from('tasks')
        .select()
        .eq('poster_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Task>> fetchTasksWithUserBids(String userId) async {
    // First get all task IDs where user has placed bids
    final bidsData = await _client
        .from('bids')
        .select('task_id')
        .eq('worker_id', userId);

    final taskIds = (bidsData as List<dynamic>)
        .map((b) => b['task_id'] as String)
        .toList();

    if (taskIds.isEmpty) return [];

    // Then fetch those tasks
    final tasksData = await _client
        .from('tasks')
        .select()
        .inFilter('id', taskIds)
        .order('created_at', ascending: false);

    return (tasksData as List<dynamic>)
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Task> updateTask(Task task) async {
    final data = await _client
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id)
        .select()
        .single();

    return Task.fromJson(data);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  @override
  Future<Bid> createBid(Bid bid) async {
    final data = await _client
        .from('bids')
        .insert(bid.toJson())
        .select()
        .single();

    return Bid.fromJson(data);
  }

  @override
  Future<List<Bid>> getBidsForTask(String taskId) async {
    final data = await _client
        .from('bids')
        .select()
        .eq('task_id', taskId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((json) => Bid.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Bid?> getBidById(String bidId) async {
    try {
      final data = await _client
          .from('bids')
          .select()
          .eq('id', bidId)
          .single();

      return Bid.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Bid> updateBid(Bid bid) async {
    final data = await _client
        .from('bids')
        .update(bid.toJson())
        .eq('id', bid.id)
        .select()
        .single();

    return Bid.fromJson(data);
  }

  @override
  Future<void> acceptBid(String bidId, String taskId) async {
    try {
      // Get the bid to find the worker ID
      final bidData = await _client
          .from('bids')
          .select()
          .eq('id', bidId)
          .single();

      final workerId = bidData['worker_id'] as String;

      // Get the task to find the poster ID
      final taskData = await _client
          .from('tasks')
          .select('poster_id')
          .eq('id', taskId)
          .single();

      final posterId = taskData['poster_id'] as String;

      // Update task to assign worker and change status
      await _client.from('tasks').update({
        'assigned_worker_id': workerId,
        'status': 'assigned',
      }).eq('id', taskId);

      // Update bid status to accepted
      await _client.from('bids').update({
        'status': 'accepted',
      }).eq('id', bidId);

      // Reject all other bids for this task
      await _client
          .from('bids')
          .update({'status': 'rejected'})
          .eq('task_id', taskId)
          .neq('id', bidId);

      // Create a chat between poster and worker
      final chatExists = await _client
          .from('chats')
          .select()
          .eq('task_id', taskId)
          .maybeSingle();

      if (chatExists == null) {
        // Create new chat using Chat model
        final chat = Chat(
          id: const Uuid().v4(),
          taskId: taskId,
          posterId: posterId,
          workerId: workerId,
          createdAt: DateTime.now(),
        );

        await _client.from('chats').insert(chat.toJson());
      }
    } catch (e) {
      // Log error and rethrow
      print('Error accepting bid: $e');
      rethrow;
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseTaskRepository(client);
});
