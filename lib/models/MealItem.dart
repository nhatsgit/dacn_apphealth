class MealItem {
  final int id;
  final int foodId;
  final String foodName;
  final double quantity;
  final String unit;
  final double calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  MealItem({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      foodId: json['foodId'] is int
          ? json['foodId']
          : int.parse(json['foodId'].toString()),
      foodName: json['foodName'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
