// File: lib/controller/AddMealRecordController.dart

import 'package:dacn_app/controller/MealController.dart';
import 'package:dacn_app/models/Food.dart'; // Import model Food
import 'package:dacn_app/models/Meal.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/MealServices.dart';
import 'package:dacn_app/services/FoodService.dart'; // Import FoodService
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddMealRecordController extends GetxController {
  // Dữ liệu ban đầu
  final MealRecord? mealToEdit;
  final DateTime initialDate;

  AddMealRecordController({this.mealToEdit, required this.initialDate});

  // Trạng thái reactive
  var isLoading = false.obs;
  var isFoodLoading = false.obs; // NEW: Trạng thái tải Food
  var selectedDate = DateTime.now().obs;
  var selectedMealType = 'Breakfast'.obs; // Giá trị mặc định
  var mealItems = <CreateMealItemDto>[].obs;
  var foodList = <Food>[].obs; // NEW: Danh sách thực phẩm
  var noteController = TextEditingController();
  var totalCalories = 0.0.obs;

  final List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Other'
  ];

  // Dịch vụ
  late final MealService _mealService;
  late final FoodService _foodService; // NEW: Dịch vụ Food

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _mealService = MealService(client);
    _foodService = FoodService(client); // Khởi tạo FoodService

    // Khởi tạo trạng thái
    if (mealToEdit != null) {
      _loadMealForEditing(mealToEdit!);
    } else {
      selectedDate.value = initialDate;
    }

    // Lắng nghe thay đổi của danh sách món ăn để cập nhật tổng calo
    ever(mealItems, (_) => _calculateTotalCalories());
    // Tính toán calo lần đầu
    _calculateTotalCalories();
  }

  void _loadMealForEditing(MealRecord meal) {
    selectedDate.value = DateFormat('yyyy-MM-dd').parse(meal.date);
    selectedMealType.value = meal.mealType;
    noteController.text = meal.note ?? '';

    // Chuyển đổi MealItem sang CreateMealItemDto để chỉnh sửa
    mealItems.assignAll(meal.items.map((item) => CreateMealItemDto(
          foodId: item.foodId,
          quantity: item.quantity,
          unit: item.unit,
          calories: item.calories, // Calo/unit
          protein: item.protein,
          carbs: item.carbs,
          fat: item.fat,
        )));
  }

  // Tính tổng calo từ danh sách món ăn
  void _calculateTotalCalories() {
    // totalCalories = sum(item.calories * item.quantity)
    double total = mealItems.fold(
        0.0, (sum, item) => sum + (item.calories ?? 0.0) * item.quantity);
    totalCalories.value = total;
  }

  // ===============================================
  // HÀM TẢI DANH SÁCH THỰC PHẨM
  // ===============================================
  Future<void> fetchFoodList() async {
    if (foodList.isNotEmpty && !isFoodLoading.value) return; // Tránh tải lại

    try {
      isFoodLoading(true);
      final response = await _foodService.fetchAllFoods();
      foodList.assignAll(response);
    } catch (e) {
      Get.snackbar(
        "Lỗi tải thực phẩm",
        "Không thể tải danh sách thực phẩm: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isFoodLoading(false);
    }
  }

  // ===============================================
  // HÀM THÊM MÓN ĂN ĐÃ CHỌN TỪ DIALOG
  // ===============================================
  void addSelectedFoodItem(Food food, double quantity, String unit) {
    // Tạo DTO mới với thông tin Food đã chọn
    mealItems.add(CreateMealItemDto(
      foodId: food.id,
      quantity: quantity,
      unit: unit,
      name: food.name, // Tên món ăn
      // Lưu trữ giá trị dinh dưỡng cơ bản (calo/đơn vị)
      calories: food.calories, // Calo/ServingSize
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
    ));

    Get.snackbar("Thành công", "Đã thêm món ${food.name} vào bữa ăn.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

  // ===============================================
  // HÀM CHỌN NGÀY (giữ nguyên)
  // ===============================================
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50), // Màu xanh lá cây
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  void removeMealItem(int index) {
    mealItems.removeAt(index);
  }

  // ===============================================
  // HÀM LƯU HỒ SƠ BỮA ĂN (giữ nguyên)
  // ===============================================
  Future<void> saveMealRecord() async {
    if (mealItems.isEmpty) {
      Get.snackbar("Lỗi", "Bữa ăn phải có ít nhất một món.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isLoading(true);

    // Chuẩn bị DTO
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    final dto = CreateMealRecordDto(
      date: formattedDate,
      mealType: selectedMealType.value,
      note: noteController.text.isEmpty ? null : noteController.text,
      items: mealItems.toList(),
    );
    Get.back();
    try {
      if (mealToEdit != null) {
        // Cập nhật
        await _mealService.updateMeal(mealToEdit!.id, dto);
        Get.snackbar("Thành công", "Đã cập nhật hồ sơ bữa ăn.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        // Tạo mới
        await _mealService.createMeal(dto);
        Get.snackbar("Thành công", "Đã thêm hồ sơ bữa ăn mới.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      }

      // Sau khi lưu, quay lại trang trước và yêu cầu cập nhật danh sách
      final mealController = Get.find<MealController>();
      await mealController.fetchMealsForSelectedDate(selectedDate.value);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu hồ sơ bữa ăn: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
