class Food {
  final int id;
  final String name;
  final String barcode;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  final String type;
  final String instructions;

  Food({
    required this.id,
    required this.name,
    required this.barcode,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.type,
    required this.instructions,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      barcode: json['barcode'] ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      servingSize: json['servingSize'] ?? '',
      type: json['type'] ?? '',
      instructions: json['instructions'] ?? '',
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

  Food copyWith({
    int? id,
    String? name,
    String? barcode,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? servingSize,
    String? type,
    String? instructions,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      servingSize: servingSize ?? this.servingSize,
      type: type ?? this.type,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  String toString() {
    return 'Food(id: $id, name: $name, calories: $calories kcal)';
  }
}
