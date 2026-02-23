class PostModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? date;
  final String? imageUrl;
  final String type; // 'upcoming' or 'recent'
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    this.description,
    this.date,
    this.imageUrl,
    required this.type,
    required this.createdAt,
  });

  bool get isUpcoming => type == 'upcoming';

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : null,
      imageUrl: map['image_url'] as String?,
      type: map['type'] as String? ?? 'upcoming',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date?.toIso8601String().split('T')[0],
      'image_url': imageUrl,
      'type': type,
    };
  }
}
