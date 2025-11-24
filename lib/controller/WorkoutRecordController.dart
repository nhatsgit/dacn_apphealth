// File: lib/controller/WorkoutController.dart

import 'package:dacn_app/models/Workout.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/WorkoutService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WorkoutController extends GetxController {
  // Trạng thái loading
  var isLoading = true.obs;
  // Danh sách kế hoạch tập luyện
  var workoutPlans = <WorkoutPlan>[].obs;
  // Tổng số kế hoạch
  var totalPlans = 0.obs;

  late final WorkoutService _workoutService;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo Service (giả định HttpRequest có sẵn)
    final client = HttpRequest(http.Client());
    _workoutService = WorkoutService(client);
    // Tải dữ liệu khi Controller khởi tạo
    fetchWorkoutPlans();
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU
  // ===============================================
  Future<void> fetchWorkoutPlans() async {
    try {
      isLoading(true);

      final fetchedPlans = await _workoutService.fetchAllWorkoutPlans();
      workoutPlans.value = fetchedPlans;
      totalPlans.value = fetchedPlans.length;
    } catch (e) {
      Get.snackbar(
        "Lỗi tải dữ liệu",
        "Không thể tải kế hoạch tập luyện: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // ===============================================
  // HÀM XÓA DỮ LIỆU
  // ===============================================
  Future<void> deleteWorkoutPlan(int id) async {
    try {
      await _workoutService.deleteWorkoutPlan(id);
      // Cập nhật local list
      workoutPlans.removeWhere((plan) => plan.id == id);
      totalPlans.value = workoutPlans.length;

      Get.snackbar(
        "Thành công",
        "Đã xóa kế hoạch tập luyện.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi xóa",
        "Không thể xóa kế hoạch tập luyện: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Tải lại nếu xóa thất bại để đồng bộ hóa
      fetchWorkoutPlans();
    }
  }

  // Hàm refresh dữ liệu đơn giản
  Future<void> refreshData() => fetchWorkoutPlans();
}
