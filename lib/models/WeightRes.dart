import 'package:dacn_app/models/Weight.dart';

class PagedWeightResponse {
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final String? filterDate;
  final List<WeightRecord> data;

  PagedWeightResponse({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    this.filterDate,
    required this.data,
  });

  factory PagedWeightResponse.fromJson(Map<String, dynamic> json) {
    return PagedWeightResponse(
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      filterDate: json['filterDate'],
      data: (json['data'] as List<dynamic>)
          .map((e) => WeightRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

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
