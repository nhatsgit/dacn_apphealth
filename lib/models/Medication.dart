class Medication {
  final int id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String
      reminderTime; // giữ nguyên dạng "HH:mm:ss" (có thể đổi sang TimeOfDay nếu cần)
  final String? note;
  final bool isActive;

  Medication({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.reminderTime,
    this.note,
    required this.isActive,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? 0,
      medicineName: json['medicineName'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      reminderTime: json['reminderTime'] ?? '',
      note: json['note'],
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderTime': reminderTime,
      'note': note,
      'isActive': isActive,
    };
  }

  Medication copyWith({
    int? id,
    String? medicineName,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? reminderTime,
    String? note,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTime: reminderTime ?? this.reminderTime,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Medication(id: $id, name: $medicineName, active: $isActive)';
  }
}
