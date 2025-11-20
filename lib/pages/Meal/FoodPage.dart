import 'package:dacn_app/controller/FoodController.dart';
import 'package:dacn_app/models/Food.dart';
import 'package:dacn_app/pages/Meal/AddFoodPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(FoodController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Danh sach món ăn',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          // Nút Tải lại dữ liệu
          Obx(() => IconButton(
                icon: Icon(Icons.refresh,
                    color: controller.isLoading.value
                        ? Colors.grey
                        : Colors.white),
                onPressed:
                    controller.isLoading.value ? null : controller.fetchFoods,
              )),
          const SizedBox(width: 8),
        ],
      ),

      // --- BODY SỬ DỤNG Obx ---
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.foodRecords.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có món ăn nào trong cơ sở dữ liệu.",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50)),
                  label: const Text("Thêm mới ngay"),
                  onPressed: () => Get.to(() => const AddFoodPage()),
                )
              ],
            ),
          );
        }

        // --- Danh sách món ăn ---
        return ListView.builder(
          itemCount: controller.foodRecords.length,
          itemBuilder: (context, index) {
            final food = controller.foodRecords[index];
            return _buildFoodItem(context, food, controller);
          },
        );
      }),

      // --- Nút Thêm Mới ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddFoodPage()),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget riêng để hiển thị 1 Item
  Widget _buildFoodItem(
      BuildContext context, Food food, FoodController controller) {
    // 💡 Sử dụng Dismissible để thêm chức năng swipe-to-delete
    return Dismissible(
      key: Key(food.id.toString()),
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
              "Bạn có chắc chắn muốn xóa món ăn '${food.name}' khỏi database?",
          textConfirm: "Xóa",
          textCancel: "Hủy",
          confirmTextColor: Colors.white,
          onConfirm: () {
            controller.deleteFood(food.id);
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
            // 💡 TODO: Chuyển sang trang AddFoodPage để chỉnh sửa
            // Get.to(() => AddFoodPage(foodToEdit: food));
            Get.snackbar(
                "Chức năng", "Chức năng chỉnh sửa đang được phát triển.",
                snackPosition: SnackPosition.BOTTOM);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.restaurant_menu, color: Color(0xFF4CAF50)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên món ăn
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Chi tiết dinh dưỡng
                      _buildNutritionRow(
                          "Calo", "${food.calories.toStringAsFixed(0)} kcal"),
                      _buildNutritionRow("Protein",
                          "${food.protein?.toStringAsFixed(1) ?? 'N/A'}g"),
                      _buildNutritionRow("Carb",
                          "${food.carbs?.toStringAsFixed(1) ?? 'N/A'}g"),
                      _buildNutritionRow(
                          "Fat", "${food.fat?.toStringAsFixed(1) ?? 'N/A'}g"),
                    ],
                  ),
                ),
                // Serving Size
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      food.servingSize ?? '1 serving',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.type ?? 'Homemade',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic),
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

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}
