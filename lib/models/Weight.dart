// File: lib/models/Weight.dart

class WeightRecord {
  final int id;
  final String date;
  final double weight;
  final double bmi;
  final double idealWeight;
  final String? note;

  WeightRecord({
    required this.id,
    required this.date,
    required this.weight,
    required this.bmi,
    required this.idealWeight,
    this.note,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    // 💡 ĐÃ SỬA: Dùng (json['key'] as num?)?.toDouble() ?? 0.0
    // để chuyển đổi an toàn từ num (có thể là null) sang double.
    return WeightRecord(
      id: json['id'] as int,
      date: json['date'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      idealWeight: (json['idealWeight'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'weight': weight,
      'bmi': bmi,
      'idealWeight': idealWeight,
      'note': note,
    };
  }
}
