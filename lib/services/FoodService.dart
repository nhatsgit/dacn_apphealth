// File: lib/services/FoodService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/models/Food.dart'; // Food, CreateFoodDto

class FoodService {
  final HttpRequest _request;

  FoodService(this._request);

  // ===============================================
  // 1. GET: Lấy toàn bộ danh sách thực phẩm
  // GET /api/food
  // ===============================================
  Future<List<Food>> fetchAllFoods() async {
    final response = await _request.get("food");

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Food.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch food list: ${response.body}");
    }
  }

  // ===============================================
  // 2. GET: Lấy thực phẩm theo ID
  // GET /api/food/{id}
  // ===============================================
  Future<Food> fetchFoodById(int id) async {
    final response = await _request.get("food/$id");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Food.fromJson(data);
    } else {
      throw Exception("Failed to fetch food by ID: ${response.body}");
    }
  }

  // ===============================================
  // 3. POST: Tạo thực phẩm mới
  // POST /api/food
  // ===============================================
  Future<Food> createFood(CreateFoodDto dto) async {
    final body = dto.toJson();

    final response = await _request.post("food", body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return Food.fromJson(data);
    } else {
      throw Exception("Failed to create food: ${response.body}");
    }
  }

  // ===============================================
  // 4. PUT: Cập nhật thực phẩm hiện có
  // PUT /api/food/{id}
  // ===============================================
  Future<void> updateFood(int id, CreateFoodDto dto) async {
    final body = dto.toJson();

    final response = await _request.put("food/$id", body);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to update food: ${response.body}");
    }
  }

  // ===============================================
  // 5. DELETE: Xóa thực phẩm
  // DELETE /api/food/{id}
  // ===============================================
  Future<void> deleteFood(int id) async {
    final response = await _request.delete("food/$id");

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Failed to delete food: ${response.body}");
    }
  }
}
