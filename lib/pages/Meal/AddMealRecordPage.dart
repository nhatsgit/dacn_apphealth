// File: lib/pages/Meal/AddMealRecordPage.dart

import 'package:dacn_app/controller/AddMealRecordController.dart';
import 'package:dacn_app/models/Food.dart'; // Import Food model
import 'package:dacn_app/models/Meal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddMealRecordPage extends StatelessWidget {
  final DateTime? date;
  final MealRecord? mealToEdit;

  const AddMealRecordPage({super.key, this.date, this.mealToEdit})
      : assert(date != null || mealToEdit != null);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AddMealRecordController(
        mealToEdit: mealToEdit,
        initialDate: date ?? DateTime.now(),
      ),
    );

    final isEditing = mealToEdit != null;
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: Text(
          isEditing ? 'Chỉnh Sửa Bữa Ăn' : 'Thêm Bữa Ăn Mới',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context, controller, formatter),
                  const SizedBox(height: 16),
                  _buildTotalCaloriesCard(controller),
                  const SizedBox(height: 16),
                  // Gọi dialog chọn món ăn
                  _buildMealItemsSection(context, controller),
                  const SizedBox(height: 16),
                  _buildNoteField(controller),
                  const SizedBox(height: 32),
                  _buildSaveButton(controller, isEditing),
                ],
              ),
            )),
    );
  }

  Widget _buildNoteField(AddMealRecordController controller) {
    return TextField(
      controller: controller.noteController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Ghi chú (Tùy chọn)',
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        prefixIcon: const Icon(Icons.notes, color: Color(0xFF4CAF50)),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildSaveButton(AddMealRecordController controller, bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.saveMealRecord,
        icon: Icon(isEditing ? Icons.save : Icons.add_circle,
            color: Colors.white),
        label: Text(
          isEditing ? 'LƯU CHỈNH SỬA' : 'THÊM BỮA ĂN',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCaloriesCard(AddMealRecordController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tổng Calo:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Obx(
              () => Text(
                "${controller.totalCalories.value.toStringAsFixed(0)} kcal",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ===============================================
  // WIDGETS CON
  // ===============================================

  // ... (Các widget _buildHeaderSection, _buildTotalCaloriesCard, _buildNoteField, _buildSaveButton giữ nguyên) ...
  Widget _buildHeaderSection(BuildContext context,
      AddMealRecordController controller, DateFormat formatter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
              title: const Text('Ngày',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Obx(() => Text(
                    formatter.format(controller.selectedDate.value),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  )),
              onTap: () => controller.pickDate(context),
            ),
            const Divider(),
            // Meal Type Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restaurant, color: Color(0xFF4CAF50)),
              title: const Text('Loại Bữa Ăn',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Obx(() => DropdownButton<String>(
                    value: controller.selectedMealType.value,
                    items: controller.mealTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(_mapMealTypeToVietnamese(type)),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedMealType.value = newValue;
                      }
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItemsSection(
      BuildContext context, AddMealRecordController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Danh sách Món Ăn:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  // SỬA: Thay thế hàm placeholder bằng hàm mở dialog
                  onPressed: () =>
                      _showFoodSelectionDialog(context, controller),
                  icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
                  label: const Text("Thêm Món",
                      style: TextStyle(color: Color(0xFF4CAF50))),
                ),
              ],
            ),
            const Divider(),
            Obx(() {
              if (controller.mealItems.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("Bữa ăn chưa có món nào. Hãy thêm món!",
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey)),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.mealItems.length,
                itemBuilder: (context, index) {
                  final item = controller.mealItems[index];
                  final itemCalories = (item.calories ?? 0.0) * item.quantity;
                  return Dismissible(
                    key: Key(index.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => controller.removeMealItem(index),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      // Tên món ăn cần được lấy từ Food ID nếu có
                      title: Text(item.foodId != null
                          ? "Món:${item.name ?? item.foodId}" // Thay bằng tên món ăn thật
                          : "Món ăn tự nhập"),
                      subtitle: Text(
                          "x${item.quantity.toStringAsFixed(0)} ${item.unit ?? 'đơn vị'}"),
                      trailing: Text("${itemCalories.toStringAsFixed(0)} kcal",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      onTap: () {
                        // TODO: Mở trang/dialog chỉnh sửa Item
                      },
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // NEW: Hàm hiển thị Dialog chọn món ăn
  Future<void> _showFoodSelectionDialog(
      BuildContext context, AddMealRecordController controller) async {
    // Tải danh sách thực phẩm (chỉ tải lần đầu)
    await controller.fetchFoodList();

    // Hiển thị dialog/modal
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: FoodSelectionDialog(controller: controller),
      ),
      barrierDismissible: true,
    );
  }

  // Hàm mapping type sang tiếng Việt và các hàm helper khác giữ nguyên

  String _mapMealTypeToVietnamese(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return 'Bữa Sáng';
      case 'Lunch':
        return 'Bữa Trưa';
      case 'Dinner':
        return 'Bữa Tối';
      case 'Snack':
        return 'Ăn Nhẹ';
      default:
        return 'Khác';
    }
  }

  // ... (Các widget _buildHeaderSection, _buildTotalCaloriesCard, _buildNoteField, _buildSaveButton - copy từ file trước nếu cần)

  // (Tôi giả định các hàm widget này đã được định nghĩa trong AddMealRecordPage.dart)
  // ...
  // Các hàm helper widget đã được định nghĩa trong file trước đó...
  // ...
}

// ===============================================
// WIDGET MỚI: FoodSelectionDialog
// ===============================================

class FoodSelectionDialog extends StatelessWidget {
  final AddMealRecordController controller;
  // Sử dụng RxString để theo dõi thay đổi của ô tìm kiếm và lọc danh sách
  final RxString searchTerm = ''.obs;
  final TextEditingController searchController = TextEditingController();

  FoodSelectionDialog({super.key, required this.controller});

  // Hàm hiển thị Dialog nhập số lượng sau khi chọn món
  void _showQuantityDialog(BuildContext context, Food food) {
    final quantityController = TextEditingController(text: '1.0');
    // Sử dụng servingSize từ Food model làm đơn vị
    final unit = food.servingSize ?? 'đơn vị';
    final caloriesPerUnit = food.calories ?? 0.0;

    Get.back(); // Đóng dialog tìm kiếm trước

    Get.defaultDialog(
      title: "Nhập Số Lượng",
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          double currentQuantity =
              double.tryParse(quantityController.text) ?? 1.0;
          double estimatedCalories = caloriesPerUnit * currentQuantity;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Món ăn: ${food.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  "Calo cơ bản: ${caloriesPerUnit.toStringAsFixed(1)} kcal / $unit",
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {}); // Cập nhật calo ước tính
                },
                decoration: InputDecoration(
                  labelText: "Số lượng ($unit)",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                  "Calo ước tính: ${estimatedCalories.toStringAsFixed(0)} kcal",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
            ],
          );
        },
      ),
      textConfirm: "Thêm",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      onConfirm: () {
        double quantity = double.tryParse(quantityController.text) ?? 1.0;
        if (quantity > 0) {
          controller.addSelectedFoodItem(food, quantity, unit);
          Get.back(); // Đóng dialog nhập số lượng
        } else {
          Get.snackbar("Lỗi", "Số lượng phải lớn hơn 0",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      },
      onCancel: () => Get.back(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      // Giới hạn chiều cao để nó trông như một Modal Sheet/Dialog
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tìm kiếm Thực phẩm",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          // Search Field
          TextField(
            controller: searchController,
            onChanged: (value) => searchTerm.value = value.toLowerCase(),
            decoration: const InputDecoration(
              labelText: "Nhập tên món ăn...",
              prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
          const SizedBox(height: 10),
          // Food List
          Expanded(
            child: Obx(() {
              if (controller.isFoodLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Lọc danh sách theo từ khóa tìm kiếm
              final filteredList = controller.foodList.where((food) {
                return food.name.toLowerCase().contains(searchTerm.value);
              }).toList();

              if (filteredList.isEmpty) {
                return Center(
                  child: Text(
                      searchTerm.value.isEmpty
                          ? "Không có dữ liệu thực phẩm"
                          : "Không tìm thấy món ăn '${searchTerm.value}'",
                      style: const TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final food = filteredList[index];
                  return ListTile(
                    title: Text(food.name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        "${food.calories.toStringAsFixed(0)} kcal / ${food.servingSize ?? '1 đơn vị'}"),
                    trailing: const Icon(Icons.add, color: Color(0xFF4CAF50)),
                    onTap: () {
                      _showQuantityDialog(context, food);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
