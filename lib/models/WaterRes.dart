import 'package:dacn_app/models/Water.dart';

class PagedWaterResponse {
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final String? filterDate;
  final List<WaterRecord> data;

  PagedWaterResponse({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    this.filterDate,
    required this.data,
  });

  factory PagedWaterResponse.fromJson(Map<String, dynamic> json) {
    return PagedWaterResponse(
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      filterDate: json['filterDate'],
      data: (json['data'] as List<dynamic>)
          .map((e) => WaterRecord.fromJson(e as Map<String, dynamic>))
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
