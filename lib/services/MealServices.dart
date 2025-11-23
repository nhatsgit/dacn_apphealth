// File: lib/services/MealService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/models/Meal.dart'; // MealRecord, CreateMealRecordDto
import 'package:intl/intl.dart';

class MealService {
  final HttpRequest _request;

  MealService(this._request);

  // ===============================================
  // 1. GET: Lấy danh sách hồ sơ bữa ăn theo ngày
  // GET /api/meal?date=2025-10-16
  // ===============================================
  Future<List<MealRecord>> fetchMeals({
    DateTime? date,
  }) async {
    String dateQuery = "";
    if (date != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      dateQuery = "date=$formattedDate";
    }

    final endpoint = "meal?$dateQuery";
    final response = await _request.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => MealRecord.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch meal records: ${response.body}");
    }
  }

  // ===============================================
  // 2. POST: Tạo hồ sơ bữa ăn mới
  // POST /api/meal
  // ===============================================
  Future<void> createMeal(CreateMealRecordDto dto) async {
    final body = dto.toJson();

    // 💡 GIẢI PHÁP TỐT HƠN: Luôn bao gồm thông tin lỗi chi tiết từ server
    final response = await _request.post("meal", body);

    // Kiểm tra mã trạng thái 201 (Created) hoặc 200 (OK)
    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    } else {
      // Thất bại, ném ra ngoại lệ với chi tiết từ phản hồi của server
      throw Exception("Failed to create meal record: ${response.body}");
    }
  }

  // ===============================================
  // 3. PUT: Cập nhật hồ sơ bữa ăn hiện có
  // PUT /api/meal/{id}
  // ===============================================
  Future<void> updateMeal(int id, CreateMealRecordDto dto) async {
    final body = dto.toJson();

    final response = await _request.put("meal/$id", body);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to update meal record: ${response.body}");
    }
  }

  // ===============================================
  // 4. DELETE: Xóa hồ sơ bữa ăn
  // DELETE /api/meal/{id}
  // ===============================================
  Future<void> deleteMeal(int id) async {
    final response = await _request.delete("meal/$id");

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to delete meal record: ${response.body}");
    }
  }
}
