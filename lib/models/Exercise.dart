// models/exercise.dart
class Exercise {
  final int id;
  final String name;
  final String category;
  final String description;
  final int caloriesPerMinute;
  final String equipment;
  final String videoUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.caloriesPerMinute,
    required this.equipment,
    required this.videoUrl,
  });

  // Tạo từ Map (JSON)
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      caloriesPerMinute: json['caloriesPerMinute'] is int
          ? json['caloriesPerMinute'] as int
          : int.parse(json['caloriesPerMinute'].toString()),
      equipment: json['equipment'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }

  // Chuyển sang Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'caloriesPerMinute': caloriesPerMinute,
      'equipment': equipment,
      'videoUrl': videoUrl,
    };
  }

  // copyWith tiện dụng
  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    int? caloriesPerMinute,
    String? equipment,
    String? videoUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      caloriesPerMinute: caloriesPerMinute ?? this.caloriesPerMinute,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, category: $category)';
  }
}
