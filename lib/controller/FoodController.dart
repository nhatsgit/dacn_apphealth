import 'package:dacn_app/models/Food.dart';
import 'package:dacn_app/services/FoodService.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FoodController extends GetxController {
  // Trạng thái loading
  var isLoading = true.obs;
  // Danh sách toàn bộ thực phẩm trong database
  var foodRecords = <Food>[].obs;

  late final FoodService _foodService;

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _foodService = FoodService(client);
    fetchFoods(); // Tải dữ liệu khi Controller được khởi tạo
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU
  // ===============================================
  Future<void> fetchFoods() async {
    try {
      isLoading(true);
      final response = await _foodService.fetchAllFoods();
      foodRecords.assignAll(response);
    } catch (e) {
      Get.snackbar(
        "Lỗi tải dữ liệu",
        "Không thể tải danh sách thực phẩm: $e",
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
  Future<void> deleteFood(int id) async {
    try {
      await _foodService.deleteFood(id);

      // Xóa khỏi danh sách local và thông báo thành công
      foodRecords.removeWhere((food) => food.id == id);

      Get.snackbar(
        "Thành công",
        "Đã xóa thực phẩm khỏi danh sách.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi xóa",
        "Không thể xóa thực phẩm: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Nếu xóa thất bại, có thể cần tải lại để đảm bảo đồng bộ
      fetchFoods();
    }
  }

  // ===============================================
  // HÀM TẠO DỮ LIỆU (Được gọi từ AddFoodPage)
  // ===============================================
  Future<void> createFood(CreateFoodDto dto) async {
    try {
      final newFood = await _foodService.createFood(dto);

      // Thêm vào danh sách local và tải lại
      foodRecords.add(newFood);
      foodRecords.sort((a, b) => a.name.compareTo(b.name));

      Get.snackbar(
        "Thành công",
        "Đã thêm món ăn '${newFood.name}' vào cơ sở dữ liệu.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi lưu",
        "Không thể thêm thực phẩm mới: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw e; // Ném lỗi để AddFoodPage xử lý logic loading/navigating
    }
  }
}
