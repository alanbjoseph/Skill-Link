import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skill_link_new/features/user/models/chat.dart';
import 'package:skill_link_new/features/user/providers/chat_providers.dart';
import 'package:skill_link_new/features/tasks/repositories/task_repository.dart';
import 'package:skill_link_new/features/user/repositories/profile_repository.dart';
import 'package:skill_link_new/core/providers/supabase_providers.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  void initState() {
    super.initState();
    // Load chats after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatsProvider.notifier).loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    final chatsState = ref.watch(chatsProvider);
    final chatsNotifier = ref.read(chatsProvider.notifier);

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Chats'),
                  selected: chatsState.filter == 'all',
                  onSelected: (selected) {
                    if (selected) {
                      chatsNotifier.setFilter('all');
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Posted'),
                  selected: chatsState.filter == 'posted',
                  onSelected: (selected) {
                    if (selected) {
                      chatsNotifier.setFilter('posted');
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Assigned'),
                  selected: chatsState.filter == 'assigned',
                  onSelected: (selected) {
                    if (selected) {
                      chatsNotifier.setFilter('assigned');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        
        // Chat list with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await chatsNotifier.refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chats refreshed! ${chatsState.chats.length} chat(s) found.'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: chatsState.isLoading && chatsState.chats.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chatsState.error != null
                    ? _buildErrorState(chatsState.error!)
                    : chatsState.chats.isEmpty
                        ? _buildEmptyState(chatsState.filter)
                        : ListView.builder(
                            itemCount: chatsState.chats.length,
                            itemBuilder: (context, index) {
                              final chat = chatsState.chats[index];
                              return _ChatListItem(
                                chat: chat,
                                currentUserId: currentUserId,
                              );
                            },
                          ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    IconData icon;

    switch (filter) {
      case 'posted':
        message = 'No chats for tasks you\'ve posted yet';
        icon = Icons.post_add_outlined;
        break;
      case 'assigned':
        message = 'No chats for tasks assigned to you yet';
        icon = Icons.work_outline;
        break;
      default:
        message = 'No chats yet\nStart by posting or bidding on a task';
        icon = Icons.chat_bubble_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading chats',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pull down to retry',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListItem extends ConsumerWidget {
  final Chat chat;
  final String? currentUserId;

  const _ChatListItem({
    required this.chat,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskRepositoryProvider).getTaskById(chat.taskId);
    final isUserPoster = chat.posterId == currentUserId;
    final otherUserId = isUserPoster ? chat.workerId : chat.posterId;

    return FutureBuilder(
      future: Future.wait([
        taskAsync,
        ref.read(profileRepositoryProvider).getProfile(otherUserId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        final data = snapshot.data!;
        final task = data[0] as dynamic;
        final otherUserProfile = data[1] as dynamic;
        final otherUserName = otherUserProfile?.fullName ?? 'Unknown User';
        final taskTitle = task?.title ?? 'Task not found';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            otherUserName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                taskTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isUserPoster ? 'You posted this task' : 'Assigned to you',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/chat/${chat.id}');
          },
        );
      },
    );
  }
}
