// File: lib/services/SleepService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:intl/intl.dart';
// 💡 Cần tạo các Model tương ứng cho SleepRecord và PagedSleepResponse
import 'package:dacn_app/models/Sleep.dart';
import 'package:dacn_app/models/SleepRes.dart';

class SleepService {
  final HttpRequest _request;

  SleepService(this._request);

  // ===============================================
  // 1. GET: Lấy danh sách hồ sơ giấc ngủ
  // GET /api/sleep?date=&pageNumber=&pageSize=
  // ===============================================
  Future<PagedSleepResponse> fetchSleepRecords({
    DateTime? date,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    // Định dạng ngày tháng
    String dateQuery = "";
    if (date != null) {
      // API C# sử dụng DateOnly, nên ta định dạng YYYY-MM-DD
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      dateQuery = "date=$formattedDate&";
    }

    final endpoint =
        "sleep?${dateQuery}pageNumber=$pageNumber&pageSize=$pageSize";
    final response = await _request.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Giả định PagedSleepResponse.fromJson đã được định nghĩa
      return PagedSleepResponse.fromJson(data);
    } else {
      throw Exception("Failed to fetch sleep records: ${response.body}");
    }
  }

  // ===============================================
  // 2. POST: Tạo hồ sơ giấc ngủ mới
  // POST /api/sleep
  // ===============================================
  Future<SleepRecord> createSleepRecord({
    required DateTime startTime,
    required DateTime endTime,
    String? sleepQuality, // Giả định SleepQuality là String
    String? sleepType,
    String? notes,
  }) async {
    // Body gửi lên API (dùng CreateSleepRecordDto trong C#)
    final body = {
      "startTime": startTime.toIso8601String(), // Cần gửi ISO 8601
      "endTime": endTime.toIso8601String(), // Cần gửi ISO 8601
      "sleepQuality": sleepQuality,
      "sleepType": sleepType,
      "notes": notes,
    };

    final response = await _request.post("sleep", body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      // Giả định API trả về SleepRecord đã tạo (cần SleepRecord.fromJson)
      return SleepRecord.fromJson(data);
    } else {
      throw Exception("Failed to create sleep record: ${response.body}");
    }
  }

  // ===============================================
  // 3. PUT: Cập nhật hồ sơ giấc ngủ hiện có
  // PUT /api/sleep/{id}
  // ===============================================
  Future<void> updateSleepRecord({
    required int id,
    required DateTime startTime,
    required DateTime endTime,
    String? sleepQuality,
    String? sleepType,
    String? notes,
  }) async {
    // Body gửi lên API (dùng CreateSleepRecordDto trong C#)
    final body = {
      "startTime": startTime.toIso8601String(), // Cần gửi ISO 8601
      "endTime": endTime.toIso8601String(), // Cần gửi ISO 8601
      "sleepQuality": sleepQuality,
      "sleepType": sleepType,
      "notes": notes,
    };

    final response = await _request.put("sleep/$id", body);

    // API C# thường trả về 204 No Content cho update thành công
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to update sleep record: ${response.body}");
    }
    // Thành công (200 hoặc 204) sẽ kết thúc hàm
  }

  // ===============================================
  // 4. DELETE: Xóa hồ sơ giấc ngủ
  // DELETE /api/sleep/{id}
  // ===============================================
  Future<void> deleteSleepRecord(int id) async {
    final response = await _request.delete("sleep/$id");

    // API C# thường trả về 204 No Content cho delete thành công
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to delete sleep record: ${response.body}");
    }
  }
}
