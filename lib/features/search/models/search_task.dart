class SearchTask {
  final String id;
  final String title;
  final String description;
  final double budget;
  final String? location;
  final bool isRemote;
  final String? category;
  final String? posterPhotoUrl;

  SearchTask({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    this.location,
    this.isRemote = false,
    this.category,
    this.posterPhotoUrl,
  });
}
