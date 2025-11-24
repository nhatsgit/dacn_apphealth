// File: lib/services/ExerciseService.dart

import 'dart:convert';
import 'package:dacn_app/services/HttpRequest.dart';
// Giả định các models sau tồn tại:
import 'package:dacn_app/models/Exercise.dart'; // Chứa class Exercise (tương ứng với ExerciseDto)

class ExerciseService {
  final HttpRequest _request;

  ExerciseService(this._request);

  // ===============================================
  // 1. GET: Lấy toàn bộ danh sách bài tập (Library)
  // GET /api/Exercise
  // ===============================================
  Future<List<Exercise>> fetchAllExercises() async {
    final response = await _request.get("Exercise");

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch exercise list: ${response.body}");
    }
  }

  // ===============================================
  // 2. GET: Lấy bài tập theo ID
  // GET /api/Exercise/{id}
  // ===============================================
  Future<Exercise> fetchExerciseById(int id) async {
    final response = await _request.get("Exercise/$id");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Exercise.fromJson(data);
    } else {
      throw Exception(
          "Failed to fetch exercise by ID (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 3. POST: Tạo bài tập mới
  // POST /api/Exercise
  // ===============================================
  Future<Exercise> createExercise(CreateExerciseDto dto) async {
    final body = dto.toJson();

    final response = await _request.post("Exercise", body);

    // Dựa trên C# Controller (CreatedAtAction), API trả về 201 và đối tượng đã tạo
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return Exercise.fromJson(data);
    } else {
      throw Exception(
          "Failed to create exercise (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 4. PUT: Cập nhật bài tập hiện có
  // PUT /api/Exercise/{id}
  // ===============================================
  Future<void> updateExercise(int id, CreateExerciseDto dto) async {
    final body = dto.toJson();

    final response = await _request.put("Exercise/$id", body);

    // API C# thường trả về 204 No Content (hoặc 200) cho update thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw Exception(
          "Failed to update exercise (Status: ${response.statusCode}): ${response.body}");
    }
  }

  // ===============================================
  // 5. DELETE: Xóa bài tập
  // DELETE /api/Exercise/{id}
  // ===============================================
  Future<void> deleteExercise(int id) async {
    final response = await _request.delete("Exercise/$id");

    // API C# thường trả về 204 No Content (hoặc 200) cho delete thành công
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw Exception(
          "Failed to delete exercise (Status: ${response.statusCode}): ${response.body}");
    }
  }
}
