// File: lib/services/MealService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:intl/intl.dart';
// 💡 Cần tạo các Model tương ứng cho MealRecord và CreateMealRecord
import 'package:dacn_app/models/Meal.dart';

// Giả định: CreateMealItem là một class Dart
class CreateMealItem {
  final int? foodId;
  final double quantity;
  final String? unit;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  CreateMealItem({
    this.foodId,
    required this.quantity,
    this.unit,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  Map<String, dynamic> toJson() => {
        "foodId": foodId,
        "quantity": quantity,
        "unit": unit,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fat,
      };
}
