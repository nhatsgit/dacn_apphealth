// File: lib/models/Water.dart

import 'package:intl/intl.dart';

class WaterRecord {
  final int id;
  final String date; // DateOnly từ backend
  final String? time; // DateTime? từ backend (chỉ lấy phần giờ/phút)
  final int amount; // Lượng nước (ml)
  final int? target; // Mục tiêu (ml)

  WaterRecord({
    required this.id,
    required this.date,
    this.time,
    required this.amount,
    this.target,
  });

  factory WaterRecord.fromJson(Map<String, dynamic> json) {
    String? formattedTime;
    if (json['time'] != null) {
      try {
        // API trả về DateTime, chúng ta chỉ cần TimeOfDay (hoặc String)
        final dateTime = DateTime.parse(json['time']);
        // Định dạng thành chuỗi HH:mm
        formattedTime = DateFormat('HH:mm').format(dateTime);
      } catch (e) {
        // Bỏ qua nếu không thể parse time
      }
    }

    return WaterRecord(
      id: json['id'] as int,
      date: json['date'] as String,
      time: formattedTime, // Lưu thời gian đã format
      amount: json['amount'] as int,
      target: json['target'] as int?,
    );
  }
  WaterRecord copyWith({
    int? id,
    String? date,
    String? time,
    int? amount,
    int? target,
  }) {
    return WaterRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'amount': amount,
      'target': target,
    };
  }
}
