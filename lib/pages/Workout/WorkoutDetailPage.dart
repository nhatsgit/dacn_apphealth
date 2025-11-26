// File: lib/pages/Workout/AddWorkoutPage.dart

import 'package:dacn_app/controller/WorkoutDetailController.dart';
import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/models/Workout.dart';
import 'package:dacn_app/pages/Workout/AddActivityPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Đổi tên class nếu cần thiết (dựa trên tên file bạn cung cấp)
class WorkoutDetailPage extends StatelessWidget {
  final WorkoutPlan? workoutPlanToEdit;

  const WorkoutDetailPage({super.key, this.workoutPlanToEdit});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(
      WorkoutDetailController(workoutPlanToEdit: workoutPlanToEdit),
    );

    final isEditing = workoutPlanToEdit != null;
    const Color primaryColor = Color(0xFF2196F3); // Màu xanh cho Tập luyện

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Hero(
          // <--- THÊM HERO TẠI ĐÂY
          tag: isEditing
              ? 'plan_name_${workoutPlanToEdit!.id}'
              : 'new_plan_title', // Cần khớp tag
          child: Material(
            color: Colors.transparent,
            child: Text(
              isEditing ? 'Chỉnh Sửa Kế Hoạch' : 'Thêm Kế Hoạch Mới',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => TextButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      // Logic để mở màn hình chọn/tìm kiếm Exercise
                      // Ví dụ: Get.to(() => ExerciseSelectionPage());
                    },
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text('Thêm bài tập',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),

      // --- Nút LƯU ---
      bottomNavigationBar: Obx(() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                isEditing ? 'CẬP NHẬT KẾ HOẠCH' : 'LƯU KẾ HOẠCH',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.saveWorkoutPlan,
            ),
          )),

      // --- BODY: FORM và LIST BÀI TẬP ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin Kế hoạch
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInput(Icons.fitness_center, 'Tên kế hoạch (*)',
                        controller.nameController),
                    _buildInput(
                        Icons.calendar_today,
                        'Tần suất (Ví dụ: 3/tuần)',
                        controller.frequencyController),
                    _buildInput(Icons.flag, 'Mục tiêu Bước chân/ngày (Bước)',
                        controller.targetStepsController,
                        isNumeric: true),
                    _buildInput(
                        Icons.access_time,
                        'Thời gian yêu thích (HH:mm)',
                        controller.preferredTimeController),
                    _buildInput(
                        Icons.note, 'Ghi chú', controller.notesController,
                        maxLines: 3),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                "Danh sách Bài tập:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Danh sách các Bài tập đã thêm
            Obx(
              () => controller.workoutExercises.isEmpty
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text("Chưa có bài tập nào được thêm."),
                    ))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.workoutExercises.length,
                      itemBuilder: (context, index) {
                        final workoutExerciseDto =
                            controller.workoutExercises[index];

                        // 💡 ĐOẠN CODE ĐÃ SỬA: SỬ DỤNG FutureBuilder 💡
                        return FutureBuilder<Exercise?>(
                          future: controller
                              .getExerciseById(workoutExerciseDto.exerciseId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Trạng thái đang tải dữ liệu Exercise
                              return _buildLoadingTile(
                                  workoutExerciseDto.exerciseId);
                            }

                            final exercise = snapshot.data;

                            if (exercise == null) {
                              // Lỗi/Không tìm thấy Exercise trong thư viện (Mất đồng bộ)
                              return _buildErrorTile(
                                workoutExerciseDto.exerciseId,
                                index,
                                controller,
                                primaryColor,
                              );
                            }

                            // Hiển thị bài tập thành công
                            return _buildExerciseTile(
                              context,
                              exercise,
                              workoutExerciseDto,
                              index,
                              controller,
                              primaryColor,
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- Các Widget Con ---
  Widget _buildInput(IconData icon, String label, TextEditingController c,
      {bool isNumeric = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          labelText: label,
          border: InputBorder.none,
        ),
        keyboardType: isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
      ),
    );
  }

  Widget _buildLoadingTile(int id) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Đang tải Exercise ID: $id...'),
      ),
    );
  }

  Widget _buildErrorTile(int id, int index, WorkoutDetailController controller,
      Color primaryColor) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text('ID Bài tập: $id (Lỗi Dữ liệu)',
            style: const TextStyle(color: Colors.red)),
        subtitle: const Text(
            'Bài tập này không còn tồn tại trong thư viện. Vui lòng xóa.',
            style: TextStyle(color: Colors.red)),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => controller.removeExerciseFromPlan(index),
        ),
      ),
    );
  }

  Widget _buildExerciseTile(
      BuildContext context,
      Exercise exercise,
      CreateWorkoutExerciseDto dto,
      int index,
      WorkoutDetailController controller,
      Color primaryColor) {
    // Hàm hiển thị chi tiết Sets, Reps, Duration
    String getDetails() {
      final parts = <String>[];
      if (dto.sets != null && dto.reps != null) {
        parts.add('${dto.sets} sets x ${dto.reps} reps');
      } else if (dto.durationMinutes != null) {
        parts.add('${dto.durationMinutes!.toStringAsFixed(0)} phút');
      }
      return parts.join(' | ');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Text(
            '${getDetails()} - ${exercise.caloriesPerMinute?.toStringAsFixed(1) ?? 'N/A'} kcal/phút'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow, color: primaryColor),
              onPressed: () {
                // Điều hướng đến trang hẹn giờ
                Get.to(() => ExerciseTimerPage(
                      exercise: exercise,
                      workoutExerciseDto: dto,
                    ));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.removeExerciseFromPlan(index),
            ),
          ],
        ),
      ),
    );
  }
}
