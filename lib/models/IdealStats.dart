class IdealStats {
  final double idealWeight;
  final double idealWaterMl;
  final double idealCaloriesIn;
  final double idealCaloriesOut;

  IdealStats({
    required this.idealWeight,
    required this.idealWaterMl,
    required this.idealCaloriesIn,
    required this.idealCaloriesOut,
  });

  factory IdealStats.fromJson(Map<String, dynamic> json) {
    return IdealStats(
      idealWeight: (json['idealWeight'] as num).toDouble(),
      idealWaterMl: (json['idealWaterMl'] as num).toDouble(),
      idealCaloriesIn: (json['idealCaloriesIn'] as num).toDouble(),
      idealCaloriesOut: (json['idealCaloriesOut'] as num).toDouble(),
    );
  }
}
