import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skill_link_new/features/tasks/models/task.dart';
import 'package:skill_link_new/features/tasks/repositories/task_repository.dart';
import 'package:skill_link_new/core/providers/supabase_providers.dart';

/// Provider for all tasks (posted + assigned to user)
final myAllTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  
  if (userId == null) return [];
  
  // Get both posted and assigned tasks
  final posted = await repo.fetchUserTasks(userId);
  final assigned = await repo.fetchTasks();
  final assignedToMe = assigned.where((t) => t.assignedWorkerId == userId).toList();
  
  // Combine and remove duplicates
  final allTasks = {...posted, ...assignedToMe}.toList();
  allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  return allTasks;
});

/// Provider for tasks posted by current user
final myPostedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  
  if (userId == null) return [];
  
  return repo.fetchUserTasks(userId);
});

/// Provider for tasks assigned to current user as worker
final myAssignedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  
  if (userId == null) return [];
  
  final tasks = await repo.fetchTasks();
  return tasks.where((t) => 
    t.assignedWorkerId == userId && 
    (t.status == 'assigned' || t.status == 'in_progress')
  ).toList();
});

/// Provider for tasks where user has placed bids (offered)
final myOfferedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  
  if (userId == null) return [];
  
  return repo.fetchTasksWithUserBids(userId);
});

/// Provider for completed tasks posted by user
final myFinishedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  
  if (userId == null) return [];
  
  final tasks = await repo.fetchUserTasks(userId);
  return tasks.where((t) => t.status == 'completed').toList();
});

/// Provider for completed tasks where user was the worker
final myCompletedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  
  if (userId == null) return [];
  
  final tasks = await repo.fetchTasks();
  return tasks.where((t) => 
    t.assignedWorkerId == userId && 
    t.status == 'completed'
  ).toList();
});

class MyTasksPage extends ConsumerStatefulWidget {
  const MyTasksPage({super.key});

  @override
  ConsumerState<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends ConsumerState<MyTasksPage> {
  int _selectedFilter = 0; // 0=All, 1=Posted, 2=Assigned, 3=Offered, 4=Finished, 5=Completed

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ChoiceChips for filtering
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All Tasks'),
                selected: _selectedFilter == 0,
                onSelected: (selected) {
                  setState(() => _selectedFilter = 0);
                },
              ),
              ChoiceChip(
                label: const Text('Posted'),
                selected: _selectedFilter == 1,
                onSelected: (selected) {
                  setState(() => _selectedFilter = 1);
                },
              ),
              ChoiceChip(
                label: const Text('Assigned'),
                selected: _selectedFilter == 2,
                onSelected: (selected) {
                  setState(() => _selectedFilter = 2);
                },
              ),
              ChoiceChip(
                label: const Text('Offered'),
                selected: _selectedFilter == 3,
                onSelected: (selected) {
                  setState(() => _selectedFilter = 3);
                },
              ),
              ChoiceChip(
                label: const Text('Finished'),
                selected: _selectedFilter == 4,
                onSelected: (selected) {
                  setState(() => _selectedFilter = 4);
                },
              ),
              ChoiceChip(
                label: const Text('Completed'),
                selected: _selectedFilter == 5,
                onSelected: (selected) {
                  setState(() => _selectedFilter = 5);
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Content based on selected filter
        Expanded(
          child: _buildFilteredContent(),
        ),
      ],
    );
  }

  Widget _buildFilteredContent() {
    switch (_selectedFilter) {
      case 0:
        return _buildAllTasks();
      case 1:
        return _buildPostedTasks();
      case 2:
        return _buildAssignedTasks();
      case 3:
        return _buildOfferedTasks();
      case 4:
        return _buildFinishedTasks();
      case 5:
        return _buildCompletedTasks();
      default:
        return _buildAllTasks();
    }
  }

  Widget _buildAllTasks() {
    final tasksAsync = ref.watch(myAllTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No tasks yet',
            subtitle: 'Your posted and assigned tasks will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myAllTasksProvider);
          },
          child: _buildTaskList(tasks, myAllTasksProvider),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, myAllTasksProvider),
    );
  }

  Widget _buildPostedTasks() {
    final tasksAsync = ref.watch(myPostedTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.post_add_outlined,
            title: 'No tasks posted yet',
            subtitle: 'Tap the Post tab to create your first task',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myPostedTasksProvider);
          },
          child: _buildTaskList(tasks, myPostedTasksProvider),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, myPostedTasksProvider),
    );
  }

  Widget _buildAssignedTasks() {
    final tasksAsync = ref.watch(myAssignedTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No assigned tasks',
            subtitle: 'Tasks assigned to you will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myAssignedTasksProvider);
          },
          child: _buildTaskList(tasks, myAssignedTasksProvider),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, myAssignedTasksProvider),
    );
  }

  Widget _buildOfferedTasks() {
    final tasksAsync = ref.watch(myOfferedTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.local_offer_outlined,
            title: 'No offers made yet',
            subtitle: 'Browse tasks in the Search tab to start bidding',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myOfferedTasksProvider);
          },
          child: _buildTaskList(tasks, myOfferedTasksProvider),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, myOfferedTasksProvider),
    );
  }

  Widget _buildFinishedTasks() {
    final tasksAsync = ref.watch(myFinishedTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'No finished tasks',
            subtitle: 'Completed tasks you posted will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myFinishedTasksProvider);
          },
          child: _buildTaskList(tasks, myFinishedTasksProvider),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, myFinishedTasksProvider),
    );
  }

  Widget _buildCompletedTasks() {
    final tasksAsync = ref.watch(myCompletedTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.done_all_outlined,
            title: 'No completed tasks',
            subtitle: 'Tasks you completed as a worker will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myCompletedTasksProvider);
          },
          child: _buildTaskList(tasks, myCompletedTasksProvider),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, myCompletedTasksProvider),
    );
  }

  // Helper widgets
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, FutureProvider<List<Task>> provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(provider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, FutureProvider<List<Task>> provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/task/${task.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(task.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '₹${task.budget.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    task.isRemote ? Icons.laptop_outlined : Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.isRemote ? 'Remote' : task.location ?? 'TBD',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(task.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    MaterialColor color;
    String label;

    switch (status) {
      case 'open':
        color = Colors.blue;
        label = 'Open';
        break;
      case 'assigned':
        color = Colors.orange;
        label = 'Assigned';
        break;
      case 'in_progress':
        color = Colors.purple;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
