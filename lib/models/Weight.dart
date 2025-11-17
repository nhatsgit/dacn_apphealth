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
    return WeightRecord(
      id: json['id'],
      date: json['date'],
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      idealWeight: (json['idealWeight'] as num).toDouble(),
      note: json['note'],
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
