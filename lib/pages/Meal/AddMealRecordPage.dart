import 'package:dacn_app/controller/AddMealRecordController.dart';
import 'package:dacn_app/controller/FoodController.dart';
import 'package:dacn_app/models/Meal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddMealRecordPage extends StatelessWidget {
  final MealRecord? mealToEdit;
  final DateTime? date;

  const AddMealRecordPage({super.key, this.mealToEdit, this.date});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(AddMealRecordController(
      mealToEdit: mealToEdit,
      initialDate: date ?? mealToEdit?.date.toDateTime() ?? DateTime.now(),
    ));

    // 💡 Đảm bảo FoodController đã được khởi tạo để tải danh sách Food.
    // Nếu chưa, nó sẽ được khởi tạo tại đây (hoặc tốt hơn là trong Binding).
    Get.put(FoodController());

    final String title =
        controller.isEditing.value ? "Chỉnh Sửa Bữa Ăn" : "Thêm Bữa Ăn Mới";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // --- Nút LƯU ---
      bottomNavigationBar: Obx(() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                  controller.isSaving.value
                      ? "Đang lưu..."
                      : (controller.isEditing.value
                          ? "Cập Nhật Bữa Ăn"
                          : "Lưu Bữa Ăn"),
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              onPressed:
                  controller.isSaving.value ? null : controller.saveMealRecord,
            ),
          )),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Thông tin cơ bản (Ngày và Loại bữa ăn) ---
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Ngày (Chỉ hiển thị, không cho phép sửa vì ta đã lấy ngày từ MealController)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('EEEE, dd/MM/yyyy', 'vi_VN')
                                .format(controller.initialDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Loại bữa ăn
                    Obx(() => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Loại bữa ăn",
                            prefixIcon: Icon(Icons.restaurant_menu,
                                color: Color(0xFF4CAF50)),
                            border: InputBorder.none,
                          ),
                          value: controller.selectedMealType.value,
                          items: controller.mealTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(_mapMealTypeToVietnamese(value)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.selectedMealType.value = newValue;
                            }
                          },
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. Tổng Calo (Calculated) ---
            Obx(() => _TotalCalorieCard(
                totalCalories: controller.totalCalories.value)),
            const SizedBox(height: 20),

            // --- 3. Danh sách các món ăn (Meal Items) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Các món ăn đã thêm:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
                TextButton.icon(
                  onPressed: () => controller.showAddEditItemDialog(),
                  icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
                  label: const Text("Thêm món"),
                ),
              ],
            ),
            Obx(() => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: controller.mealItems.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                              child: Text("Chưa có món ăn nào trong bữa này.",
                                  style: TextStyle(color: Colors.grey))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.mealItems.length,
                          itemBuilder: (context, index) {
                            final item = controller.mealItems[index];
                            return _buildMealItemTile(
                                context, item, index, controller);
                          },
                        ),
                )),
            const SizedBox(height: 20),

            // --- 4. Ghi chú ---
            const Text("Ghi chú/Nhận xét:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: controller.noteController,
                  decoration: const InputDecoration(
                    labelText: "Nhập ghi chú (nếu có)...",
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị một Item
  Widget _buildMealItemTile(BuildContext context, MealItem item, int index,
      AddMealRecordController controller) {
    return ListTile(
      leading: const Icon(Icons.food_bank, color: Colors.lightGreen),
      title: Text(item.foodName ?? "Món ăn không tên",
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        "${item.quantity.toStringAsFixed(1)} ${item.unit ?? 'g'} | ${item.protein?.toStringAsFixed(1) ?? '0'}g P, ${item.carbs?.toStringAsFixed(1) ?? '0'}g C, ${item.fat?.toStringAsFixed(1) ?? '0'}g F",
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
      trailing: Text(
        "${item.calories?.toStringAsFixed(0) ?? '0'} kcal",
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
      ),
      onTap: () =>
          controller.showAddEditItemDialog(itemToEdit: item, index: index),
      onLongPress: () {
        Get.defaultDialog(
            title: "Xóa món ăn",
            middleText:
                "Bạn có muốn xóa món ăn **${item.foodName}** khỏi bữa ăn này?",
            textConfirm: "Xóa",
            textCancel: "Hủy",
            confirmTextColor: Colors.white,
            onConfirm: () {
              controller.removeItem(index);
              Get.back();
            });
      },
    );
  }

  // Hàm chuyển đổi sang tiếng Việt
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
}

// Widget Thống kê Calo
class _TotalCalorieCard extends StatelessWidget {
  final double totalCalories;

  const _TotalCalorieCard({required this.totalCalories});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tổng Calo:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  "${totalCalories.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.trending_up,
              size: 40,
              color: Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }
}

// Hàm mở rộng để chuyển đổi String dateOnly thành DateTime
extension DateOnly on String {
  DateTime toDateTime() {
    return DateFormat('yyyy-MM-dd').parse(this);
  }
}
