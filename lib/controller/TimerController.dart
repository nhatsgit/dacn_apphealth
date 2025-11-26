// File: lib/controller/ExerciseTimerController.dart

import 'package:dacn_app/models/Activity.dart'; // Chứa CreateActivityRecordDto
import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/services/ActivityService.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/models/Workout.dart'; // Chứa CreateWorkoutExerciseDto
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ExerciseTimerController extends GetxController {
  final Exercise exercise;
  final CreateWorkoutExerciseDto workoutExerciseDto;

  ExerciseTimerController({
    required this.exercise,
    required this.workoutExerciseDto,
  });

  // Services
  late final ActivityService _activityService;

  // Trạng thái (Giả lập trạng thái của Timer và Calo)
  var isLoading = false.obs;
  // Các biến này sẽ được cập nhật từ Page (AddActivityPage.dart)
  var elapsedTimeInMinutes = 0.0.obs; // Tổng thời gian chạy (tính bằng phút)
  var caloriesBurned = 0.0.obs; // Tổng calo đốt được

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _activityService = ActivityService(client);
  }

  // ===============================================
  // HÀM LƯU HỒ SƠ HOẠT ĐỘNG
  // POST /api/Activity
  // ===============================================
  Future<void> saveActivityRecord() async {
    if (elapsedTimeInMinutes.value <= 0) {
      Get.snackbar(
        "Lỗi",
        "Hoạt động phải có thời lượng lớn hơn 0.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 1. Chuẩn bị DTO
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dto = CreateActivityRecordDto(
      date: formattedDate,
      // Sử dụng tên bài tập làm loại hoạt động
      activityType: exercise.name,
      // Duration trong DTO là int? (phút). Lấy tổng thời gian đã chạy (làm tròn)
      duration: elapsedTimeInMinutes.value.round(),
      caloriesOut: caloriesBurned.value,
      // Không có thông tin Steps/Distance trong bối cảnh này, đặt null
      steps: null,
      distance: null,
    );

    // 2. Gọi Service và xử lý kết quả
    isLoading(true);
    try {
      await _activityService.createActivityRecord(dto);

      Get.snackbar(
        "Thành công",
        "Đã lưu hồ sơ hoạt động **${exercise.name}**.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Quay lại trang trước sau khi lưu thành công
      Get.back();
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể lưu hồ sơ hoạt động: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Hàm này dùng để liên kết dữ liệu tính toán từ Page sang Controller
  void updateStats(double durationMinutes, double calories) {
    elapsedTimeInMinutes.value = durationMinutes;
    caloriesBurned.value = calories;
  }
}
