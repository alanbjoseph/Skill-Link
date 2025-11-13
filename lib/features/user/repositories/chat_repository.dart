import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:skill_link_new/core/providers/supabase_providers.dart';
import 'package:skill_link_new/features/user/models/chat.dart';

/// Repository for managing chats and messages
abstract class ChatRepository {
  /// Create a new chat
  Future<Chat> createChat(Chat chat);

  /// Get chat by ID
  Future<Chat?> getChatById(String chatId);

  /// Get chat by task ID
  Future<Chat?> getChatByTaskId(String taskId);

  /// Get all chats for a user (as poster or worker)
  Future<List<Chat>> getUserChats(String userId);

  /// Get chats where user is the poster
  Future<List<Chat>> getPostedChats(String userId);

  /// Get chats where user is the assigned worker
  Future<List<Chat>> getAssignedChats(String userId);

  /// Send a message in a chat
  Future<Message> sendMessage(Message message);

  /// Get all messages for a chat
  Future<List<Message>> getChatMessages(String chatId);

  /// Delete a chat
  Future<void> deleteChat(String chatId);
}

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;

  SupabaseChatRepository(this._client);

  @override
  Future<Chat> createChat(Chat chat) async {
    final data = await _client
        .from('chats')
        .insert(chat.toJson())
        .select()
        .single();

    return Chat.fromJson(data);
  }

  @override
  Future<Chat?> getChatById(String chatId) async {
    try {
      final data = await _client
          .from('chats')
          .select()
          .eq('id', chatId)
          .single();

      return Chat.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Chat?> getChatByTaskId(String taskId) async {
    try {
      final data = await _client
          .from('chats')
          .select()
          .eq('task_id', taskId)
          .single();

      return Chat.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Chat>> getUserChats(String userId) async {
    final data = await _client
        .from('chats')
        .select()
        .or('poster_id.eq.$userId,worker_id.eq.$userId')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((json) => Chat.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Chat>> getPostedChats(String userId) async {
    final data = await _client
        .from('chats')
        .select()
        .eq('poster_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((json) => Chat.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Chat>> getAssignedChats(String userId) async {
    final data = await _client
        .from('chats')
        .select()
        .eq('worker_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((json) => Chat.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Message> sendMessage(Message message) async {
    final data = await _client
        .from('messages')
        .insert(message.toJson())
        .select()
        .single();

    return Message.fromJson(data);
  }

  @override
  Future<List<Message>> getChatMessages(String chatId) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('sent_at', ascending: true);

    return (data as List<dynamic>)
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteChat(String chatId) async {
    // Delete all messages first
    await _client.from('messages').delete().eq('chat_id', chatId);
    
    // Then delete the chat
    await _client.from('chats').delete().eq('id', chatId);
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseChatRepository(client);
});
