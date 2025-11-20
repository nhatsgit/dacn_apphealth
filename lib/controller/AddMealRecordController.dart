import 'package:dacn_app/controller/FoodController.dart';
import 'package:dacn_app/controller/MealController.dart';
// Cần để lấy danh sách Food
import 'package:dacn_app/models/Food.dart'; // Giả sử có model Food và FoodDto
import 'package:dacn_app/models/Meal.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/MealServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddMealRecordController extends GetxController {
  // Trạng thái Loading và Lưu
  var isSaving = false.obs;

  // Dữ liệu cho Edit
  final MealRecord? mealToEdit;
  final DateTime initialDate;
  var isEditing = false.obs;

  // Các trường nhập liệu cơ bản
  var selectedMealType = 'Breakfast'.obs;
  final TextEditingController noteController = TextEditingController();

  // Danh sách các món ăn trong bữa ăn
  var mealItems = <MealItem>[].obs;

  // Thống kê calo (tính toán)
  var totalCalories = 0.0.obs;

  // Dịch vụ và Controller liên quan
  late final MealService _mealService;
  final MealController _mealController = Get.find<MealController>();
  // 💡 Nếu AddMealRecordPage cho phép chọn Food từ DB, ta cần FoodController.
  final FoodController _foodController = Get.find<FoodController>();

  // Danh sách loại bữa ăn
  final List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Other'
  ];

  AddMealRecordController({required this.initialDate, this.mealToEdit}) {
    final client = HttpRequest(http.Client());
    _mealService = MealService(client);

    // Nếu là chế độ chỉnh sửa
    if (mealToEdit != null) {
      isEditing(true);
      selectedMealType.value = mealToEdit!.mealType;
      noteController.text = mealToEdit!.note ?? '';
      mealItems.assignAll(mealToEdit!.items);
    }
    _calculateTotals();
  }

  // ===============================================
  // LOGIC ITEM (Thêm/Sửa Item trong bữa ăn)
  // ===============================================

  // Hộp thoại Thêm/Sửa một món ăn
  void showAddEditItemDialog({MealItem? itemToEdit, int? index}) {
    final TextEditingController quantityController = TextEditingController(
        text: itemToEdit?.quantity.toStringAsFixed(1) ?? '100.0');
    var selectedFood = (itemToEdit != null)
        ? _foodController.foodRecords
            .firstWhereOrNull((f) => f.id == itemToEdit.foodId)
        : null.obs;
    final formKey = GlobalKey<FormState>();

    Get.defaultDialog(
        title: itemToEdit != null ? "Chỉnh sửa món ăn" : "Thêm món ăn",
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Chọn món ăn từ DB (ComboBox)
                // Obx(() => DropdownButtonFormField<Food>(
                //       decoration:
                //           const InputDecoration(labelText: "Chọn món ăn"),
                //       value: selectedFood?.value,
                //       items: _foodController.foodRecords.map((food) {
                //         return DropdownMenuItem<Food>(
                //           value: food,
                //           child:
                //               Text(food.name, overflow: TextOverflow.ellipsis),
                //         );
                //       }).toList(),
                //       onChanged: (Food? newValue) {
                //         selectedFood?.value = newValue;
                //       },
                //       validator: (value) =>
                //           value == null ? 'Vui lòng chọn một món ăn' : null,
                //     )),
                const SizedBox(height: 10),
                // Nhập số lượng
                // TextFormField(
                //   controller: quantityController,
                //   keyboardType:
                //       const TextInputType.numberWithOptions(decimal: true),
                //   decoration: InputDecoration(
                //     labelText:
                //         "Số lượng (${selectedFood.value?.servingSize ?? 'g'})",
                //   ),
                //   validator: (value) {
                //     if (value == null || double.tryParse(value) == null)
                //       return 'Phải là số hợp lệ';
                //     if (double.parse(value) <= 0)
                //       return 'Số lượng phải lớn hơn 0';
                //     return null;
                //   },
                // ),
              ],
            ),
          ),
        ),
        textConfirm: itemToEdit != null ? "Cập nhật" : "Thêm",
        textCancel: "Hủy",
        onConfirm: () {
          // if (formKey.currentState!.validate()) {
          //   _addUpdateItem(itemToEdit, index, selectedFood!.value!,
          //       double.parse(quantityController.text));
          //   Get.back();
          // }
        });
  }

  // Logic Thêm/Sửa Item
  void _addUpdateItem(
      MealItem? originalItem, int? index, Food selectedFood, double quantity) {
    // Tính toán lại dinh dưỡng dựa trên servingSize (giả sử servingSize là 100g)
    // Nếu servingSize không phải 100g, logic này cần phức tạp hơn.
    // Ví dụ: Food.calories là Calo/100g
    final double factor = quantity / 100.0;

    final newItem = MealItem(
      id: originalItem?.id ??
          0, // Id sẽ được API cấp khi lưu/update toàn bộ MealRecord
      foodId: selectedFood.id,
      foodName: selectedFood.name,
      quantity: quantity,
      unit: selectedFood
          .servingSize, // Tạm thời dùng ServingSize của Food làm Unit
      calories: (selectedFood.calories * factor).toPrecision(1),
      protein: (selectedFood.protein ?? 0.0) * factor.toPrecision(1),
      carbs: (selectedFood.carbs ?? 0.0) * factor.toPrecision(1),
      fat: (selectedFood.fat ?? 0.0) * factor.toPrecision(1),
    );

    if (index != null) {
      mealItems[index] = newItem; // Cập nhật
    } else {
      mealItems.add(newItem); // Thêm mới
    }

    _calculateTotals();
  }

  void removeItem(int index) {
    mealItems.removeAt(index);
    _calculateTotals();
  }

  // Tính toán lại tổng Calo mỗi khi Item thay đổi
  void _calculateTotals() {
    totalCalories.value =
        mealItems.fold(0.0, (sum, item) => sum + (item.calories ?? 0.0));
  }

  // ===============================================
  // LOGIC LƯU DỮ LIỆU
  // ===============================================
  Future<void> saveMealRecord() async {
    if (mealItems.isEmpty) {
      Get.snackbar("Lỗi", "Bữa ăn phải có ít nhất một món ăn.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving(true);

    // 1. Chuyển MealItem thành CreateMealItemDto
    final List<CreateMealItemDto> itemDtos = mealItems
        .map((item) => CreateMealItemDto(
              foodId: item.foodId,
              quantity: item.quantity,
              unit: item.unit,
              calories: item.calories,
              protein: item.protein,
              carbs: item.carbs,
              fat: item.fat,
            ))
        .toList();

    // 2. Tạo DTO tổng thể
    final CreateMealRecordDto dto = CreateMealRecordDto(
      date: DateFormat('yyyy-MM-dd').format(initialDate),
      mealType: selectedMealType.value,
      note: noteController.text.isEmpty ? null : noteController.text,
      items: itemDtos,
    );

    try {
      if (isEditing.value && mealToEdit != null) {
        // Cập nhật
        await _mealService.updateMeal(mealToEdit!.id, dto);
        Get.snackbar("Thành công", "Đã cập nhật bữa ăn.",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      } else {
        // Tạo mới
        await _mealService.createMeal(dto);
        Get.snackbar("Thành công", "Đã tạo hồ sơ bữa ăn mới.",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      }

      // 3. Tải lại danh sách trên MealController và thoát trang
      await _mealController
          .fetchMealsForSelectedDate(_mealController.selectedDate.value);
      Get.back();
    } catch (e) {
      Get.snackbar("Lỗi lưu dữ liệu", "Không thể lưu hồ sơ bữa ăn: $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      isSaving(false);
    }
  }
}
