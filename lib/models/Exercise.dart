// File: lib/models/Exercise.dart

class Exercise {
  final int id;
  final String name;
  final String? category;
  final String? description;
  final double? caloriesPerMinute;
  final String? equipment;
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.caloriesPerMinute,
    this.equipment,
    this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      // Chuyển đổi an toàn từ num sang double
      caloriesPerMinute: (json['caloriesPerMinute'] as num?)?.toDouble(),
      equipment: json['equipment'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }
}

// DTO dùng cho việc tạo (POST) hoặc cập nhật (PUT) Exercise
class CreateExerciseDto {
  final String name;
  final String? category;
  final String? description;
  final double caloriesPerMinute;
  final String? equipment;
  final String? videoUrl;

  CreateExerciseDto({
    required this.name,
    this.category,
    this.description,
    required this.caloriesPerMinute,
    this.equipment,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'caloriesPerMinute': caloriesPerMinute,
      'equipment': equipment,
      'videoUrl': videoUrl,
    };
  }
}
