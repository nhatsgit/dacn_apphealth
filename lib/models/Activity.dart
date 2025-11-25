// File: lib/models/Activity.dart

import 'dart:convert';

// --- 1. Model cho Hồ sơ Hoạt động (Tương ứng với ActivityRecordDto) ---
class ActivityRecord {
  final int id;
  final String date; // Định dạng 'yyyy-MM-dd'
  final String activityType;
  final int? duration; // Đơn vị: Phút
  final double? caloriesOut;
  final int? steps;
  final double? distance; // Đơn vị: Km

  ActivityRecord({
    required this.id,
    required this.date,
    required this.activityType,
    this.duration,
    this.caloriesOut,
    this.steps,
    this.distance,
  });

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as int,
      date: json['date'] as String,
      activityType: json['activityType'] as String,
      duration: json['duration'] as int?,
      caloriesOut: (json['caloriesOut'] as num?)?.toDouble(),
      steps: json['steps'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}

// --- 2. DTO cho việc tạo/cập nhật Hồ sơ Hoạt động (Tương ứng với CreateActivityRecordDto) ---
class CreateActivityRecordDto {
  final String date; // Định dạng 'yyyy-MM-dd'
  final String activityType;
  final int? duration;
  final double? caloriesOut;
  final int? steps;
  final double? distance;

  CreateActivityRecordDto({
    required this.date,
    required this.activityType,
    this.duration,
    this.caloriesOut,
    this.steps,
    this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'activityType': activityType,
      // API C# chấp nhận null cho các trường tùy chọn, nên ta chỉ đưa vào nếu có giá trị
      if (duration != null) 'duration': duration,
      if (caloriesOut != null) 'caloriesOut': caloriesOut,
      if (steps != null) 'steps': steps,
      if (distance != null) 'distance': distance,
    };
  }
}
