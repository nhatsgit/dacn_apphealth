class SleepRecord {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String sleepQuality;
  final String sleepType;
  final String? notes;

  SleepRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.sleepQuality,
    required this.sleepType,
    this.notes,
  });

  // ✅ Factory để tạo từ JSON
  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationMinutes: json['durationMinutes'],
      sleepQuality: json['sleepQuality'],
      sleepType: json['sleepType'],
      notes: json['notes'],
    );
  }

  // ✅ Hàm chuyển về JSON (để gửi API hoặc lưu local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'sleepQuality': sleepQuality,
      'sleepType': sleepType,
      'notes': notes,
    };
  }
}
