// File: lib/services/WaterService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:intl/intl.dart';
import 'package:dacn_app/models/Water.dart'; // Import model WaterRecord
import 'package:dacn_app/models/WaterRes.dart'; // Import model PagedWaterResponse

class WaterService {
  final HttpRequest _request;

  WaterService(this._request);

  // ===============================================
  // 1. GET: Lấy danh sách hồ sơ lượng nước
  // GET /api/water?date=&pageNumber=&pageSize=
  // ===============================================
  Future<PagedWaterResponse> fetchWaterRecords({
    DateTime? date,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    // Định dạng ngày tháng
    String dateQuery = "";
    if (date != null) {
      // Sử dụng định dạng YYYY-MM-DD để truyền vào API (dựa trên DateOnly trong C#)
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      dateQuery = "date=$formattedDate&";
    }

    final endpoint =
        "water?${dateQuery}pageNumber=$pageNumber&pageSize=$pageSize";
    final response = await _request.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PagedWaterResponse.fromJson(data);
    } else {
      throw Exception("Failed to load water records: ${response.body}");
    }
  }

  Future<WaterRecord> getOrCreateTodayWaterRecord() async {
    const endpoint = "water/today";
    final response = await _request.get(endpoint);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Backend trả về 200 OK nếu đã có, hoặc 201 Created nếu tạo mới
      final data = json.decode(response.body);
      return WaterRecord.fromJson(data);
    } else {
      throw Exception(
          "Failed to get or create today's water record: ${response.body}");
    }
  }

  // ===============================================
  // 2. POST: Tạo hồ sơ lượng nước mới
  // POST /api/water
  // ===============================================
  Future<WaterRecord> createWaterRecord({
    required int amount,
    required String date, // Dạng YYYY-MM-DD
    String? time, // Dạng HH:mm:ss hoặc null
    int? target,
  }) async {
    // 💡 Chuyển đổi TimeOfDay (HH:mm) hoặc chuỗi HH:mm thành DateTime
    // Dựa trên WaterController.cs, backend nhận Time là DateTime?
    // Ta giả định backend có thể tự nhận dạng nếu ta gửi Time với Date là ngày hôm đó.
    String? apiTime;
    if (time != null) {
      // time là HH:mm (ví dụ: "14:30")
      final now = DateTime.now();
      final timeParts = time.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? now.hour;
        final minute = int.tryParse(timeParts[1]) ?? now.minute;
        final combinedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        // Định dạng theo chuẩn ISO 8601 (có thể cần thiết cho API C#)
        apiTime = combinedDateTime.toIso8601String();
      }
    }

    final body = {
      "date": date,
      "amount": amount,
      "target": target,
      "time": apiTime, // Gửi null nếu không có thời gian
    };

    // Loại bỏ các giá trị null khỏi body
    final Map<String, dynamic> filteredBody = body.entries
        .where((e) => e.value != null)
        .fold({}, (map, e) => map..[e.key] = e.value);

    final response = await _request.post("water", filteredBody);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return WaterRecord.fromJson(data);
    } else {
      throw Exception("Failed to create water record: ${response.body}");
    }
  }

  // ===============================================
  // 3. PUT: Cập nhật hồ sơ lượng nước hiện có
  // PUT /api/water/{id}
  // ===============================================
  Future<void> updateWaterRecord({
    required int id,
    required int amount,
    required String date, // Dạng YYYY-MM-DD
    String? time, // Dạng HH:mm:ss hoặc null
    int? target,
  }) async {
    // 💡 Chuyển đổi TimeOfDay (HH:mm) hoặc chuỗi HH:mm thành DateTime
    String? apiTime;
    if (time != null) {
      final now = DateTime.now();
      final timeParts = time.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? now.hour;
        final minute = int.tryParse(timeParts[1]) ?? now.minute;
        final combinedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        apiTime = combinedDateTime.toIso8601String();
      }
    }

    final body = {
      "date": date,
      "amount": amount,
      "target": target,
      "time": apiTime,
    };

    // Loại bỏ các giá trị null khỏi body
    final Map<String, dynamic> filteredBody = body.entries
        .where((e) => e.value != null)
        .fold({}, (map, e) => map..[e.key] = e.value);

    final response = await _request.put("water/$id", filteredBody);

    if (response.statusCode != 204 && response.statusCode != 200) {
      // API C# thường trả về 204 No Content cho update thành công
      throw Exception("Failed to update water record: ${response.body}");
    }
  }

  // ===============================================
  // 4. DELETE: Xóa hồ sơ lượng nước
  // DELETE /api/water/{id}
  // ===============================================
  Future<void> deleteWaterRecord(int id) async {
    final response = await _request.delete("water/$id");

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to delete water record: ${response.body}");
    }
  }
}
