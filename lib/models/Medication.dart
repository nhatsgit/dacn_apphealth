import 'package:intl/intl.dart';

class MedicationReminder {
  final int id;
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String reminderTime; // Lưu dưới dạng chuỗi HH:mm:ss từ TimeOnly
  final String? note;
  final bool isActive;

  MedicationReminder({
    required this.id,
    required this.medicineName,
    this.dosage,
    this.frequency,
    required this.startDate,
    this.endDate,
    required this.reminderTime,
    this.note,
    required this.isActive,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    // API C# trả về DateOnly là chuỗi YYYY-MM-DD
    // API C# trả về TimeOnly là chuỗi HH:mm:ss
    return MedicationReminder(
      id: json['id'] as int,
      medicineName: json['medicineName'] as String,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      reminderTime: json['reminderTime'] as String,
      note: json['note'] as String?,
      isActive: json['isActive'] as bool,
    );
  }
}

class CreateMedicationReminderDto {
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String reminderTime; // Chuỗi HH:mm:ss
  final String? note;
  final bool? isActive;

  CreateMedicationReminderDto({
    required this.medicineName,
    this.dosage,
    this.frequency,
    required this.startDate,
    this.endDate,
    required this.reminderTime,
    this.note,
    this.isActive = true, // Mặc định là true như trong C# DTO
  });

  Map<String, dynamic> toJson() {
    // Định dạng DateOnly sang YYYY-MM-DD và TimeOnly sang HH:mm:ss
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedStartDate = formatter.format(startDate);
    final String? formattedEndDate =
        endDate != null ? formatter.format(endDate!) : null;

    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': formattedStartDate,
      'endDate': formattedEndDate,
      'reminderTime': reminderTime,
      'note': note,
      'isActive': isActive,
    };
  }
}

// Model cho response khi gọi GET /api/medications (có phân trang)
class MedicationPagingResult {
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final bool? activeFilter;
  final String? dateFilter; // Chuỗi YYYY-MM-DD
  final List<MedicationReminder> data;

  MedicationPagingResult({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    this.activeFilter,
    this.dateFilter,
    required this.data,
  });

  factory MedicationPagingResult.fromJson(Map<String, dynamic> json) {
    return MedicationPagingResult(
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      totalRecords: json['totalRecords'] as int,
      totalPages: json['totalPages'] as int,
      activeFilter: json['activeFilter'] as bool?,
      dateFilter: json['dateFilter'] as String?,
      data: (json['data'] as List)
          .map((i) => MedicationReminder.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
