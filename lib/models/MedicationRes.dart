import 'package:dacn_app/models/Medication.dart';

class MedicationResponse {
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final String? activeFilter;
  final String? dateFilter;
  final List<Medication> data;

  MedicationResponse({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    this.activeFilter,
    this.dateFilter,
    required this.data,
  });

  factory MedicationResponse.fromJson(Map<String, dynamic> json) {
    return MedicationResponse(
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      activeFilter: json['activeFilter'],
      dateFilter: json['dateFilter'],
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Medication.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
      'activeFilter': activeFilter,
      'dateFilter': dateFilter,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => 'MedicationResponse(totalRecords: $totalRecords)';
}
