import 'package:dacn_app/models/Sleep.dart';

class PagedSleepResponse {
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final String? filterDate;
  final List<SleepRecord> data;

  PagedSleepResponse({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    this.filterDate,
    required this.data,
  });

  // ✅ Parse từ JSON (factory)
  factory PagedSleepResponse.fromJson(Map<String, dynamic> json) {
    return PagedSleepResponse(
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      filterDate: json['filterDate'],
      data: (json['data'] as List<dynamic>)
          .map((e) => SleepRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ✅ Chuyển ngược về JSON
  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
      'filterDate': filterDate,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
