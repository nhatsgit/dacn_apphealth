class UserOverview {
  final double? latestWeight;
  final int waterToday;
  final double caloriesInToday;
  final double caloriesOutToday;
  final double sleepHoursToday;

  UserOverview({
    this.latestWeight,
    required this.waterToday,
    required this.caloriesInToday,
    required this.caloriesOutToday,
    required this.sleepHoursToday,
  });

  factory UserOverview.fromJson(Map<String, dynamic> json) {
    return UserOverview(
      latestWeight: (json['latestWeight'] as num?)?.toDouble(),
      waterToday: json['waterToday'] ?? 0,
      caloriesInToday: (json['caloriesInToday'] as num?)?.toDouble() ?? 0.0,
      caloriesOutToday: (json['caloriesOutToday'] as num?)?.toDouble() ?? 0.0,
      sleepHoursToday: (json['sleepHoursToday'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
