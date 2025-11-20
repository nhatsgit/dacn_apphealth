import 'package:dacn_app/controller/FoodController.dart';
import 'package:dacn_app/models/Food.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFoodController extends GetxController {
  // Trạng thái loading
  var isSaving = false.obs;

  // Controllers cho các trường nhập liệu
  final foodNameController = TextEditingController();
  final barcodeController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final servingSizeController = TextEditingController(text: "100 g");
  final instructionsController = TextEditingController();

  // Các trường Dropdown
  final List<String> foodTypes = ['Homemade', 'Packaged', 'Restaurant'];
  var selectedType = 'Homemade'.obs;

  // Tham chiếu đến FoodController để cập nhật danh sách sau khi lưu
  final FoodController _foodController = Get.find<FoodController>();

  // ===============================================
  // LOGIC LƯU DỮ LIỆU
  // ===============================================
  Future<void> saveFood() async {
    // 1. Validation cơ bản
    if (foodNameController.text.isEmpty || caloriesController.text.isEmpty) {
      Get.snackbar(
        "Lỗi",
        "Tên món ăn và Calo là bắt buộc.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Kiểm tra và chuyển đổi Calo (bắt buộc)
    final calories =
        double.tryParse(caloriesController.text.replaceAll(',', '.')) ?? 0.0;
    if (calories <= 0) {
      Get.snackbar(
        "Lỗi",
        "Calo phải là số lớn hơn 0.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Thiết lập trạng thái Loading
    isSaving(true);

    try {
      // 3. Tạo DTO
      final CreateFoodDto dto = CreateFoodDto(
        name: foodNameController.text,
        barcode:
            barcodeController.text.isNotEmpty ? barcodeController.text : null,
        calories: calories,
        protein: double.tryParse(proteinController.text.replaceAll(',', '.')),
        carbs: double.tryParse(carbsController.text.replaceAll(',', '.')),
        fat: double.tryParse(fatController.text.replaceAll(',', '.')),
        servingSize: servingSizeController.text.isNotEmpty
            ? servingSizeController.text
            : null,
        type: selectedType.value,
        instructions: instructionsController.text.isNotEmpty
            ? instructionsController.text
            : null,
      );

      // 4. Gọi hàm tạo từ FoodController (nó sẽ gọi Service và cập nhật danh sách)
      await _foodController.createFood(dto);

      // 5. Thành công: Quay lại trang danh sách
      Get.back();
    } catch (e) {
      // Lỗi đã được FoodController.createFood xử lý và hiển thị Snackbar
    } finally {
      isSaving(false);
    }
  }
}
