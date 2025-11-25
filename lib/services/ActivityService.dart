// File: lib/services/ActivityService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/models/Activity.dart';
import 'package:intl/intl.dart';
// Giả định ActivityRecord và CreateActivityRecordDto nằm trong Activity.dart

class ActivityService {
  final HttpRequest _request;

  ActivityService(this._request);

  // ===============================================
  // 1. GET: Lấy danh sách hồ sơ hoạt động (Có thể lọc theo ngày)
  // GET /api/Activity?date=yyyy-MM-dd
  // ===============================================
  Future<List<ActivityRecord>> fetchActivityRecords({DateTime? date}) async {
    String endpoint = "Activity";
    if (date != null) {
      // Định dạng ngày tháng theo chuẩn YYYY-MM-DD (giống UserServices.dart)
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      endpoint += "?date=$formattedDate";
    }

    final response = await _request.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => ActivityRecord.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch activity records: ${response.body}");
    }
  }

  // ===============================================
  // 2. GET: Lấy hồ sơ hoạt động theo ID
  // GET /api/Activity/{id}
  // ===============================================
  Future<ActivityRecord> fetchActivityRecordById(int id) async {
    final response = await _request.get("Activity/$id");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ActivityRecord.fromJson(data);
    } else {
      throw Exception(
          "Failed to fetch activity record by ID: ${response.body}");
    }
  }

  // ===============================================
  // 3. POST: Tạo hồ sơ hoạt động mới
  // POST /api/Activity
  // ===============================================
  Future<ActivityRecord> createActivityRecord(
      CreateActivityRecordDto dto) async {
    final body = dto.toJson();

    final response = await _request.post("Activity", body);

    // API C# trả về 201 Created hoặc 200 OK
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return ActivityRecord.fromJson(data);
    } else {
      throw Exception(
          "Failed to create activity record (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 4. PUT: Cập nhật hồ sơ hoạt động hiện có
  // PUT /api/Activity/{id}
  // ===============================================
  Future<void> updateActivityRecord(int id, CreateActivityRecordDto dto) async {
    final body = dto.toJson();

    final response = await _request.put("Activity/$id", body);

    // API C# thường trả về 204 No Content (hoặc 200) cho update thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw Exception(
          "Failed to update activity record (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 5. DELETE: Xóa hồ sơ hoạt động
  // DELETE /api/Activity/{id}
  // ===============================================
  Future<void> deleteActivityRecord(int id) async {
    final response = await _request.delete("Activity/$id");

    // API C# thường trả về 204 No Content (hoặc 200) cho delete thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw Exception(
          "Failed to delete activity record (Status: ${response.statusCode}): ${response.body}");
    }
  }
}
