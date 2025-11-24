// File: lib/pages/Exercise/ExercisePage.dart

import 'package:dacn_app/controller/ExcerciseController.dart';
import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/pages/Workout/AddExcercisePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(ExerciseController());

    // Màu chủ đạo cho Tập luyện
    const Color primaryColor = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Thư viện Bài tập',
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
                onPressed: controller.isLoading.value
                    ? null
                    : controller.fetchExercises,
              )),
          const SizedBox(width: 8),
        ],
      ),

      // --- BODY SỬ DỤNG Obx cho trạng thái Loading/List ---
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => controller.update([
                'exerciseList'
              ]), // Trigger update cho GetBuilder/GetX widget
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài tập...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
              controller:
                  TextEditingController(), // Cần controller riêng cho search nếu muốn lưu trạng thái
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.exerciseRecords.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Lọc danh sách theo từ khóa tìm kiếm
              final searchTerm =
                  (Get.context?.findAncestorWidgetOfExactType<TextField>()
                              as TextField?)
                          ?.controller
                          ?.text
                          .toLowerCase() ??
                      '';

              final filteredList = controller.exerciseRecords.where((exercise) {
                return exercise.name.toLowerCase().contains(searchTerm) ||
                    (exercise.category?.toLowerCase().contains(searchTerm) ??
                        false);
              }).toList();

              if (filteredList.isEmpty) {
                return Center(
                  child: Text(
                      searchTerm.isEmpty
                          ? "Không có dữ liệu bài tập trong thư viện"
                          : "Không tìm thấy bài tập '${searchTerm}'",
                      style: const TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final exercise = filteredList[index];
                  return _buildExerciseListItem(
                      context, exercise, primaryColor, controller);
                },
              );
            }),
          ),
        ],
      ),

      // --- Nút Thêm mới ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddExercisePage());
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExerciseListItem(BuildContext context, Exercise exercise,
      Color primaryColor, ExerciseController controller) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // Chuyển sang trang chỉnh sửa
          Get.to(() => AddExercisePage(exerciseToEdit: exercise));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.category ?? 'Không phân loại',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center,
                            color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          exercise.equipment ?? 'Thiết bị không rõ',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    exercise.caloriesPerMinute?.toStringAsFixed(1) ?? 'N/A',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  const Text(
                    "kcal/phút",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  // Nút xóa
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      _showDeleteDialog(context, exercise, controller);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Exercise exercise, ExerciseController controller) {
    Get.defaultDialog(
      title: "Xác nhận xóa",
      middleText:
          "Bạn có chắc chắn muốn xóa bài tập '${exercise.name}' khỏi thư viện?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteExercise(exercise.id);
        Get.back();
      },
    );
  }
}
