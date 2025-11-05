class WaterRecord {
  final int id;
  final DateTime time;
  final String date;
  final int amount; // ml
  final int target; // ml

  WaterRecord({
    required this.id,
    required this.time,
    required this.date,
    required this.amount,
    required this.target,
  });

  factory WaterRecord.fromJson(Map<String, dynamic> json) {
    return WaterRecord(
      id: json['id'],
      time: DateTime.parse(json['time']),
      date: json['date'],
      amount: json['amount'],
      target: json['target'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'date': date,
      'amount': amount,
      'target': target,
    };
  }
}
