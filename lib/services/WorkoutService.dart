// File: lib/services/WorkoutService.dart

import 'dart:convert';
import 'package:dacn_app/models/Workout.dart';
import 'package:dacn_app/services/HttpRequest.dart';
// Giả định các models sau tồn tại:

class WorkoutService {
  final HttpRequest _request;

  WorkoutService(this._request);

  // ===============================================
  // 1. GET: Lấy danh sách kế hoạch tập luyện của người dùng
  // GET /api/Workout
  // ===============================================
  Future<List<WorkoutPlan>> fetchAllWorkoutPlans() async {
    final response = await _request.get("Workout");

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => WorkoutPlan.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch workout plans: ${response.body}");
    }
  }

  // ===============================================
  // 2. GET: Lấy kế hoạch tập luyện theo ID
  // GET /api/Workout/{id}
  // ===============================================
  Future<WorkoutPlan> fetchWorkoutPlanById(int id) async {
    final response = await _request.get("Workout/$id");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WorkoutPlan.fromJson(data);
    } else {
      throw Exception(
          "Failed to fetch workout plan by ID (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 3. POST: Tạo kế hoạch tập luyện mới
  // POST /api/Workout
  // ===============================================
  Future<void> createWorkoutPlan(CreateWorkoutPlanDto dto) async {
    final body = dto.toJson();

    final response = await _request.post("Workout", body);

    // Dựa trên C# Controller (CreatedAtAction), API trả về 201 và đối tượng đã tạo
    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    } else {
      throw Exception(
          "Failed to create workout plan (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 4. PUT: Cập nhật kế hoạch tập luyện hiện có
  // PUT /api/Workout/{id}
  // ===============================================
  Future<void> updateWorkoutPlan(int id, CreateWorkoutPlanDto dto) async {
    final body = dto.toJson();

    final response = await _request.put("Workout/$id", body);

    // API C# thường trả về 204 No Content (hoặc 200) cho update thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw Exception(
          "Failed to update workout plan (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 5. DELETE: Xóa kế hoạch tập luyện
  // DELETE /api/Workout/{id}
  // ===============================================
  Future<void> deleteWorkoutPlan(int id) async {
    final response = await _request.delete("Workout/$id");

    // API C# thường trả về 204 No Content (hoặc 200) cho delete thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw Exception(
          "Failed to delete workout plan (Status: ${response.statusCode}): ${response.body}");
    }
  }
}
