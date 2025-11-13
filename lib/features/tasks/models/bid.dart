class Bid {
  final String id;
  final String taskId;
  final String workerId;
  final double amount;
  final String status;
  final String? message;
  final DateTime createdAt;

  Bid({
    required this.id,
    required this.taskId,
    required this.workerId,
    required this.amount,
    required this.status,
    this.message,
    required this.createdAt,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      workerId: json['worker_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'worker_id': workerId,
      'amount': amount,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Bid copyWith({
    String? id,
    String? taskId,
    String? workerId,
    double? amount,
    String? status,
    String? message,
    DateTime? createdAt,
  }) {
    return Bid(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      workerId: workerId ?? this.workerId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
