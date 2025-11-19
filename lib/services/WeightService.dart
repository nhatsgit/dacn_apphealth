// File: lib/services/WeightService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:intl/intl.dart';
import 'package:dacn_app/models/Weight.dart';
import 'package:dacn_app/models/WeightRes.dart';

class WeightService {
  final HttpRequest _request;

  WeightService(this._request);

  // ===============================================
  // 1. GET: Lấy danh sách hồ sơ cân nặng
  // GET /api/weights?date=&pageNumber=&pageSize=
  // ===============================================
  Future<PagedWeightResponse> fetchWeights({
    DateTime? date,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    // Định dạng ngày tháng
    String dateQuery = "";
    if (date != null) {
      // Sử dụng định dạng YYYY-MM-DD để truyền vào API
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      dateQuery = "date=$formattedDate&";
    }

    final endpoint =
        "weights?${dateQuery}pageNumber=$pageNumber&pageSize=$pageSize";
    final response = await _request.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PagedWeightResponse.fromJson(data);
    } else {
      throw Exception("Failed to load weight records: ${response.body}");
    }
  }

  // ===============================================
  // 2. POST: Thêm hồ sơ cân nặng mới
  // POST /api/weights
  // ===============================================
  Future<WeightRecord> createWeight({
    required double weight,
    String? date, // Dạng YYYY-MM-DD
    String? note,
  }) async {
    final body = {
      "weight": weight,
      // Nếu không truyền ngày, lấy ngày hiện tại
      "date": date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "note": note,
    };

    final response = await _request.post("weights", body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      // Giả định API trả về WeightRecord đã tạo
      return WeightRecord.fromJson(data);
    } else {
      throw Exception("Failed to create weight record: ${response.body}");
    }
  }

  // ===============================================
  // 3. PUT: Cập nhật hồ sơ cân nặng hiện có
  // PUT /api/weights/{id}
  // ===============================================
  Future<void> updateWeight({
    required int id,
    required double weight,
    required String date, // Dạng YYYY-MM-DD
    String? note,
  }) async {
    final body = {
      "weight": weight,
      "date": date,
      "note": note,
    };

    final response = await _request.put("weights/$id", body);

    if (response.statusCode != 204 && response.statusCode != 200) {
      // API C# thường trả về 204 No Content cho update thành công
      throw Exception("Failed to update weight record: ${response.body}");
    }
    // Thành công (200 hoặc 204) sẽ kết thúc hàm
  }

  // ===============================================
  // 4. DELETE: Xóa hồ sơ cân nặng
  // DELETE /api/weights/{id}
  // ===============================================
  Future<void> deleteWeight(int id) async {
    final response = await _request.delete("weights/$id");

    if (response.statusCode != 204) {
      // API C# trả về 204 No Content khi xóa thành công
      throw Exception("Failed to delete weight record: ${response.body}");
    }
  }
}
