// File: lib/controller/ExerciseController.dart

import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/services/ExerciseService.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ExerciseController extends GetxController {
  // Trạng thái loading
  var isLoading = true.obs;
  // Danh sách toàn bộ bài tập trong database
  var exerciseRecords = <Exercise>[].obs;

  late final ExerciseService _exerciseService;

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    // Giả định HttpRequest tồn tại
    _exerciseService = ExerciseService(client);
    fetchExercises(); // Tải dữ liệu khi Controller được khởi tạo
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU
  // ===============================================
  Future<void> fetchExercises() async {
    try {
      isLoading(true);
      final response = await _exerciseService.fetchAllExercises();
      exerciseRecords.assignAll(response);
      // Sắp xếp theo tên
      exerciseRecords.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      Get.snackbar(
        "Lỗi tải dữ liệu",
        "Không thể tải danh sách bài tập: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // ===============================================
  // HÀM TẠO DỮ LIỆU (Được gọi từ AddExercisePage)
  // ===============================================
  Future<void> createExercise(CreateExerciseDto dto) async {
    try {
      final newExercise = await _exerciseService.createExercise(dto);

      // Thêm vào danh sách local và sắp xếp
      exerciseRecords.add(newExercise);
      exerciseRecords.sort((a, b) => a.name.compareTo(b.name));

      Get.snackbar(
        "Thành công",
        "Đã thêm bài tập '${newExercise.name}' vào thư viện.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể tạo bài tập mới: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow; // Ném lỗi để AddController xử lý quay lại trang
    }
  }

  // ===============================================
  // HÀM XÓA DỮ LIỆU
  // ===============================================
  Future<void> deleteExercise(int id) async {
    try {
      await _exerciseService.deleteExercise(id);
      // Cập nhật local list
      exerciseRecords.removeWhere((exercise) => exercise.id == id);

      Get.snackbar(
        "Thành công",
        "Đã xóa bài tập khỏi thư viện.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi xóa",
        "Không thể xóa bài tập: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Nếu xóa thất bại, có thể cần tải lại để đảm bảo đồng bộ
      fetchExercises();
    }
  }
}
