// File: lib/pages/Workout/WorkoutPage.dart

import 'package:dacn_app/controller/WorkoutRecordController.dart';
import 'package:dacn_app/models/Workout.dart';
import 'package:dacn_app/pages/Workout/AddWorkoutPage.dart';
import 'package:dacn_app/pages/Workout/WorkoutDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(WorkoutController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green.shade700, // Phong cách màu xanh lam
        title: const Text(
          'Kế hoạch tập luyện',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () =>
              Scaffold.of(context).openDrawer(), // Giả định có Drawer
        ),
      ),

      body: Column(
        children: [
          // --- HEADER: Thống kê tổng quan ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thống kê Tổng số kế hoạch
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng số kế hoạch',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.totalPlans.value}',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
                // Thống kê ước tính (Ví dụ: Số bài tập)
                _buildStatCard(
                  title: 'Số Bài Tập Khác Nhau',
                  value: _countUniqueExercises(controller.workoutPlans.value)
                      .toString(),
                  unit: 'bài',
                  color: Colors.blue.shade700,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // --- BODY: Danh sách Kế hoạch tập luyện ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.workoutPlans.isEmpty) {
                return Center(
                  child: Text(
                    "Chưa có kế hoạch tập luyện nào.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: controller.workoutPlans.length,
                  itemBuilder: (context, index) {
                    final plan = controller.workoutPlans[index];
                    return _buildWorkoutPlanCard(
                      context,
                      controller,
                      plan,
                      Colors.blue.shade700,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),

      // Floating Action Button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(
          () => const AddWorkoutPlanPage(),
        )?.then((value) => controller.refreshData()), // Refresh sau khi thêm
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Hàm đếm số lượng bài tập duy nhất trong tất cả các plans
  int _countUniqueExercises(List<WorkoutPlan> plans) {
    final Set<int> uniqueIds = {};
    for (var plan in plans) {
      for (var exercise in plan.exercises) {
        uniqueIds.add(exercise.exerciseId);
      }
    }
    return uniqueIds.length;
  }

  Widget _buildStatCard(
      {required String title,
      required String value,
      required String unit,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card chi tiết Kế hoạch tập luyện
  Widget _buildWorkoutPlanCard(BuildContext context,
      WorkoutController controller, WorkoutPlan plan, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên Kế hoạch
            Row(
              children: [
                Icon(Icons.fitness_center, color: color, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Chi tiết
            _buildDetailRow(
              icon: Icons.repeat,
              label: 'Tần suất',
              value: plan.frequency ?? 'Chưa xác định',
              color: color,
            ),
            _buildDetailRow(
              icon: Icons.timer,
              label: 'Thời gian ưu tiên',
              value: plan.preferredTime ?? 'Bất kỳ',
              color: color,
            ),
            _buildDetailRow(
              icon: Icons.list_alt,
              label: 'Số bài tập',
              value: '${plan.exercises.length}',
              color: color,
            ),

            // Nút Thao tác
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Nút Chỉnh sửa
                TextButton.icon(
                  onPressed: () {
                    Get.to(
                      () => WorkoutDetailPage(workoutPlanToEdit: plan),
                    )?.then((value) => controller.refreshData());
                  },
                  icon: Icon(Icons.edit, size: 18, color: color),
                  label: Text('Chi tiết', style: TextStyle(color: color)),
                ),
                const SizedBox(width: 8),
                // Nút Xóa
                TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Xác nhận xóa",
                      middleText:
                          "Bạn có chắc chắn muốn xóa kế hoạch '${plan.name}'?",
                      onConfirm: () {
                        Get.back(); // Đóng dialog
                        controller.deleteWorkoutPlan(plan.id);
                      },
                      onCancel: () {},
                      textConfirm: "Xóa",
                      textCancel: "Hủy",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
                    );
                  },
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
