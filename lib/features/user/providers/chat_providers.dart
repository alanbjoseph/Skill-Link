import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:skill_link_new/features/user/models/chat.dart';
import 'package:skill_link_new/features/user/repositories/chat_repository.dart';
import 'package:skill_link_new/core/providers/supabase_providers.dart';

/// State for managing chats list
class ChatsState {
  final List<Chat> chats;
  final bool isLoading;
  final String? error;
  final String filter;

  const ChatsState({
    this.chats = const [],
    this.isLoading = false,
    this.error,
    this.filter = 'all',
  });

  ChatsState copyWith({
    List<Chat>? chats,
    bool? isLoading,
    String? error,
    String? filter,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

/// Notifier for managing chats with filtering and refresh
class ChatsNotifier extends Notifier<ChatsState> {
  @override
  ChatsState build() {
    // Return initial state - loadChats will be called from initState
    return const ChatsState(isLoading: false, filter: 'all');
  }

  void setFilter(String filter) {
    if (state.filter != filter) {
      state = state.copyWith(filter: filter, isLoading: true, chats: []);
      loadChats();
    }
  }

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = state.copyWith(chats: [], isLoading: false);
        return;
      }

      List<Chat> chats;
      switch (state.filter) {
        case 'posted':
          chats = await chatRepo.getPostedChats(userId);
          break;
        case 'assigned':
          chats = await chatRepo.getAssignedChats(userId);
          break;
        default:
          chats = await chatRepo.getUserChats(userId);
      }

      state = state.copyWith(chats: chats, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadChats();
  }
}

final chatsProvider = NotifierProvider<ChatsNotifier, ChatsState>(
  ChatsNotifier.new,
);

/// Provider for a specific chat by ID
final chatProvider = FutureProvider.family<Chat?, String>((ref, chatId) async {
  final chatRepo = ref.read(chatRepositoryProvider);
  return await chatRepo.getChatById(chatId);
});

/// Provider for messages in a specific chat
final chatMessagesProvider = FutureProvider.family<List<Message>, String>((ref, chatId) async {
  final chatRepo = ref.read(chatRepositoryProvider);
  return await chatRepo.getChatMessages(chatId);
});
