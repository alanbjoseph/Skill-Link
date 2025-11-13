class PostForm {
  final String title;
  final String description;
  final double budget;
  final bool isRemote;
  final String? location;
  final String? category;
  final String? photoPath;
  final DateTime? deadline;

  const PostForm({
    this.title = '',
    this.description = '',
    this.budget = 0.0,
    this.isRemote = false,
    this.location,
    this.category,
    this.photoPath,
    this.deadline,
  });

  PostForm copyWith({
    String? title,
    String? description,
    double? budget,
    bool? isRemote,
    String? location,
    String? category,
    String? photoPath,
    DateTime? deadline,
  }) {
    return PostForm(
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      isRemote: isRemote ?? this.isRemote,
      location: location ?? this.location,
      category: category ?? this.category,
      photoPath: photoPath ?? this.photoPath,
      deadline: deadline ?? this.deadline,
    );
  }

  bool get isValid {
    return title.isNotEmpty && 
           description.isNotEmpty && 
           budget > 0 &&
           (isRemote || (location != null && location!.isNotEmpty));
  }
}
