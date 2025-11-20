import 'package:dacn_app/models/Meal.dart';
import 'package:dacn_app/services/HttpRequest.dart';

import 'package:dacn_app/services/MealServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MealController extends GetxController {
  // Trạng thái loading
  var isLoading = true.obs;
  // Ngày được chọn để xem
  var selectedDate = DateTime.now().obs;
  // Danh sách hồ sơ bữa ăn trong ngày được chọn
  var mealRecords = <MealRecord>[].obs;
  // Tổng calo đã ăn trong ngày
  var totalCaloriesToday = 0.0.obs;

  late final MealService _mealService;

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _mealService = MealService(client);
    // Tải dữ liệu cho ngày hiện tại khi Controller khởi tạo
    fetchMealsForSelectedDate(selectedDate.value);
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU VÀ TÍNH TOÁN STATS
  // ===============================================
  Future<void> fetchMealsForSelectedDate(DateTime date) async {
    selectedDate.value = date;
    try {
      isLoading(true);

      final response = await _mealService.fetchMeals(date: date);
      mealRecords.assignAll(response);

      // Tính toán tổng Calo
      _calculateTotalCalories();
    } catch (e) {
      Get.snackbar(
        "Lỗi tải dữ liệu",
        "Không thể tải hồ sơ bữa ăn: $e",
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
  Future<void> deleteMealRecord(int id) async {
    try {
      await _mealService.deleteMeal(id);
      // Cập nhật local list và stats
      mealRecords.removeWhere((meal) => meal.id == id);
      _calculateTotalCalories();

      Get.snackbar(
        "Thành công",
        "Đã xóa hồ sơ bữa ăn.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi xóa",
        "Không thể xóa hồ sơ bữa ăn: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Tải lại nếu xóa thất bại để đồng bộ hóa
      fetchMealsForSelectedDate(selectedDate.value);
    }
  }

  // ===============================================
  // HÀM NỘI BỘ: TÍNH TỔNG CALO
  // ===============================================
  void _calculateTotalCalories() {
    double total =
        mealRecords.fold(0.0, (sum, meal) => sum + meal.totalCalories);
    totalCaloriesToday.value = total;
  }
}
