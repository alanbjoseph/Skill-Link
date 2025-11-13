class Task {
  final String id;
  final String posterId;
  final String title;
  final String description;
  final double budget;
  final String status;
  final String? location;
  final bool isRemote;
  final DateTime createdAt;
  final List<String>? photoUrls;
  final String? category;
  final DateTime? deadline;
  final String? assignedWorkerId;

  Task({
    required this.id,
    required this.posterId,
    required this.title,
    required this.description,
    required this.budget,
    required this.status,
    this.location,
    this.isRemote = false,
    required this.createdAt,
    this.photoUrls,
    this.category,
    this.deadline,
    this.assignedWorkerId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      posterId: json['poster_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      budget: (json['budget'] as num).toDouble(),
      status: json['status'] as String,
      location: json['location'] as String?,
      isRemote: json['is_remote'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      photoUrls: json['photo_urls'] != null 
          ? List<String>.from(json['photo_urls'] as List)
          : null,
      category: json['category'] as String?,
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String)
          : null,
      assignedWorkerId: json['assigned_worker_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poster_id': posterId,
      'title': title,
      'description': description,
      'budget': budget,
      'status': status,
      'location': location,
      'is_remote': isRemote,
      'created_at': createdAt.toIso8601String(),
      'photo_urls': photoUrls,
      'category': category,
      'deadline': deadline?.toIso8601String(),
      'assigned_worker_id': assignedWorkerId,
    };
  }

  Task copyWith({
    String? id,
    String? posterId,
    String? title,
    String? description,
    double? budget,
    String? status,
    String? location,
    bool? isRemote,
    DateTime? createdAt,
    List<String>? photoUrls,
    String? category,
    DateTime? deadline,
    String? assignedWorkerId,
  }) {
    return Task(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      location: location ?? this.location,
      isRemote: isRemote ?? this.isRemote,
      createdAt: createdAt ?? this.createdAt,
      photoUrls: photoUrls ?? this.photoUrls,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
    );
  }
}
