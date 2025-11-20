// File: lib/models/Food.dart

import 'dart:convert';

class Food {
  final int id;
  final String name;
  final String? barcode;
  final double calories; // Calo / ServingSize
  final double? protein;
  final double? carbs;
  final double? fat;
  final String? servingSize;
  final String? type;
  final String? instructions;

  Food({
    required this.id,
    required this.name,
    this.barcode,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.servingSize,
    this.type,
    this.instructions,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as int,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      // Chuyển đổi an toàn từ num sang double
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      servingSize: json['servingSize'] as String?,
      type: json['type'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servingSize': servingSize,
      'type': type,
      'instructions': instructions,
    };
  }
}

// DTO dùng cho việc tạo (POST) hoặc cập nhật (PUT) Food
class CreateFoodDto {
  final String name;
  final String? barcode;
  final double calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final String? servingSize;
  final String? type;
  final String? instructions;

  CreateFoodDto({
    required this.name,
    this.barcode,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.servingSize,
    this.type,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'barcode': barcode,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servingSize': servingSize,
      'type': type,
      'instructions': instructions,
    };
  }
}
