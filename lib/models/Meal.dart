// File: lib/models/Meal.dart

import 'package:intl/intl.dart';

// --- MEAL ITEM ---
class MealItem {
  final int id;
  final int? foodId;
  final String? foodName;
  final double quantity;
  final String? unit;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  MealItem({
    required this.id,
    this.foodId,
    this.foodName,
    required this.quantity,
    this.unit,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'] as int,
      foodId: json['foodId'] as int?,
      foodName: json['foodName'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }
}

// DTO dùng cho việc tạo/cập nhật Item
class CreateMealItemDto {
  final int? foodId;
  final double quantity;
  final String? unit;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  CreateMealItemDto({
    this.foodId,
    required this.quantity,
    this.unit,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

// --- MEAL RECORD ---
class MealRecord {
  final int id;
  final String date; // Dạng YYYY-MM-DD
  final String mealType; // Ví dụ: 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  final double totalCalories;
  final String? note;
  final List<MealItem> items;

  MealRecord({
    required this.id,
    required this.date,
    required this.mealType,
    required this.totalCalories,
    this.note,
    required this.items,
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List<dynamic>?;
    List<MealItem> items = itemsList
            ?.map((i) => MealItem.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    return MealRecord(
      id: json['id'] as int,
      date: json['date'] as String,
      mealType: json['mealType'] as String,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
      items: items,
    );
  }
}

// DTO dùng cho việc tạo/cập nhật Meal Record
class CreateMealRecordDto {
  final String date; // Dạng YYYY-MM-DD
  final String mealType;
  final String? note;
  final List<CreateMealItemDto> items;

  CreateMealRecordDto({
    required this.date,
    required this.mealType,
    this.note,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mealType': mealType,
      'note': note,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
