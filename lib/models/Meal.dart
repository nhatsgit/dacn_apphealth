import 'package:dacn_app/models/MealItem.dart';

class Meal {
  final int id;
  final DateTime date;
  final String mealType;
  final double totalCalories;
  final String note;
  final List<MealItem> items;

  Meal({
    required this.id,
    required this.date,
    required this.mealType,
    required this.totalCalories,
    required this.note,
    required this.items,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      date: DateTime.parse(json['date']),
      mealType: json['mealType'] ?? '',
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MealItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'totalCalories': totalCalories,
      'note': note,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
