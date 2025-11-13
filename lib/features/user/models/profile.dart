class Profile {
  final String id;
  final String? fullName;
  final String? location;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final bool isTasker;
  final bool isTaskerVerified;
  final String? bio;

  Profile({
    required this.id,
    this.fullName,
    this.location,
    this.profilePictureUrl,
    required this.createdAt,
    this.isTasker = false,
    this.isTaskerVerified = false,
    this.bio,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      location: json['location'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isTasker: json['is_tasker'] as bool? ?? false,
      isTaskerVerified: json['is_tasker_verified'] as bool? ?? false,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'location': location,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt.toIso8601String(),
      'is_tasker': isTasker,
      'is_tasker_verified': isTaskerVerified,
      'bio': bio,
    };
  }

  Profile copyWith({
    String? id,
    String? fullName,
    String? location,
    String? profilePictureUrl,
    DateTime? createdAt,
    bool? isTasker,
    bool? isTaskerVerified,
    String? bio,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      location: location ?? this.location,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      isTasker: isTasker ?? this.isTasker,
      isTaskerVerified: isTaskerVerified ?? this.isTaskerVerified,
      bio: bio ?? this.bio,
    );
  }
}
