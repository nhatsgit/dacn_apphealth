import 'package:dacn_app/controller/MealController.dart';
import 'package:dacn_app/models/Meal.dart';
import 'package:dacn_app/pages/Meal/AddMealRecordPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MealRecordPage extends StatelessWidget {
  const MealRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(MealController());
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'Theo Dõi Dinh Dưỡng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() => IconButton(
                icon: Icon(Icons.refresh,
                    color: controller.isLoading.value
                        ? Colors.grey
                        : Colors.white),
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.fetchMealsForSelectedDate(
                        controller.selectedDate.value),
              )),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // --- HEADER: Date Picker và Total Calories ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null &&
                        picked != controller.selectedDate.value) {
                      controller.fetchMealsForSelectedDate(picked);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.blueGrey, size: 20),
                      const SizedBox(width: 8),
                      Obx(
                        () => Text(
                          formatter.format(controller.selectedDate.value),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.black87),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Total Calories
                Row(
                  children: [
                    const Text("Tổng Calo hôm nay: ",
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                    Obx(
                      () => Text(
                        "${controller.totalCaloriesToday.value.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    const Text(" kcal",
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- BODY: Danh sách bữa ăn ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.mealRecords.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.set_meal, size: 80, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text("Chưa có hồ sơ bữa ăn nào cho ngày này.",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      TextButton.icon(
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFF4CAF50)),
                        label: const Text("Thêm bữa ăn mới"),
                        onPressed: () => Get.to(() => AddMealRecordPage(
                            date: controller.selectedDate.value)),
                      )
                    ],
                  ),
                );
              }

              // Sắp xếp theo thứ tự ưu tiên: Sáng, Trưa, Chiều, Tối, Ăn nhẹ, Khác
              final sortedRecords = controller.mealRecords.toList();
              final mealOrder = [
                'Breakfast',
                'Lunch',
                'Dinner',
                'Snack',
                'Other'
              ];

              sortedRecords.sort((a, b) {
                final aIndex = mealOrder.indexOf(a.mealType);
                final bIndex = mealOrder.indexOf(b.mealType);
                return aIndex.compareTo(bIndex);
              });

              return ListView.builder(
                itemCount: sortedRecords.length,
                itemBuilder: (context, index) {
                  final meal = sortedRecords[index];
                  return _buildMealItem(context, meal, controller);
                },
              );
            }),
          ),
        ],
      ),

      // --- Nút Thêm Mới ---
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: () => Get.to(
                () => AddMealRecordPage(date: controller.selectedDate.value)),
            backgroundColor: const Color(0xFF4CAF50),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Thêm Bữa Ăn",
                style: TextStyle(color: Colors.white)),
          )),
    );
  }

  // Widget riêng để hiển thị 1 Item
  Widget _buildMealItem(
      BuildContext context, MealRecord meal, MealController controller) {
    // Chuyển đổi tên bữa ăn từ tiếng Anh sang tiếng Việt để hiển thị
    String mealTypeVietnamese = _mapMealTypeToVietnamese(meal.mealType);

    // 💡 Sử dụng Dismissible để thêm chức năng swipe-to-delete
    return Dismissible(
      key: Key(meal.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await Get.defaultDialog<bool>(
          title: "Xác nhận xóa",
          middleText:
              "Bạn có chắc chắn muốn xóa hồ sơ bữa ăn **${mealTypeVietnamese}** này (${meal.totalCalories.toStringAsFixed(0)} kcal)?",
          textConfirm: "Xóa",
          textCancel: "Hủy",
          confirmTextColor: Colors.white,
          onConfirm: () {
            controller.deleteMealRecord(meal.id);
            Get.back(result: true); // Trả về true để xác nhận xóa
          },
          onCancel: () => Get.back(result: false),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            // Chuyển sang trang chỉnh sửa
            Get.to(() => AddMealRecordPage(mealToEdit: meal));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_getMealIcon(meal.mealType),
                    color: _getMealColor(meal.mealType)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên bữa ăn
                      Text(
                        mealTypeVietnamese,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Chi tiết các món ăn (Tối đa 2 món)
                      if (meal.items.isNotEmpty)
                        Text(
                          "Gồm: ${meal.items.map((i) => i.foodName).take(2).join(', ')}${meal.items.length > 2 ? ' và ${meal.items.length - 2} món khác.' : ''}",
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      // Note
                      if (meal.note != null && meal.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Ghi chú: ${meal.note!}",
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Tổng Calo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      meal.totalCalories.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50)),
                    ),
                    const Text(
                      "kcal",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.wb_sunny;
      case 'Lunch':
        return Icons.local_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snack':
        return Icons.cookie;
      default:
        return Icons.fastfood;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Colors.amber.shade700;
      case 'Lunch':
        return Colors.green.shade700;
      case 'Dinner':
        return Colors.blueGrey;
      case 'Snack':
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }

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
