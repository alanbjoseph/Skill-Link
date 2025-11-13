class Chat {
  final String id;
  final String taskId;
  final String posterId;
  final String workerId;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.taskId,
    required this.posterId,
    required this.workerId,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      posterId: json['poster_id'] as String,
      workerId: json['worker_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'poster_id': posterId,
      'worker_id': workerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}
