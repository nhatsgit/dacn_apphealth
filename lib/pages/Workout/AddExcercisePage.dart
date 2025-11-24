// File: lib/pages/Exercise/AddExercisePage.dart

import 'package:dacn_app/controller/AddExcerciseController.dart';
import 'package:dacn_app/models/Exercise.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExercisePage extends StatelessWidget {
  final Exercise? exerciseToEdit;

  const AddExercisePage({super.key, this.exerciseToEdit});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller =
        Get.put(AddExerciseController(exerciseToEdit: exerciseToEdit));

    final isEditing = exerciseToEdit != null;
    const Color primaryColor = Color(0xFF2196F3); // Màu xanh cho Tập luyện

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          isEditing ? 'Chỉnh Sửa Bài Tập' : 'Thêm Bài Tập Mới',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),

      // --- Nút LƯU --
      bottomNavigationBar: Obx(() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                isEditing ? 'CẬP NHẬT BÀI TẬP' : 'LƯU BÀI TẬP',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onPressed:
                  controller.isSaving.value ? null : controller.saveExercise,
            ),
          )),

      // --- BODY: FORM ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container chứa Form chính
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên bài tập (Bắt buộc)
                    _buildInput(Icons.fitness_center, 'Tên bài tập (*)',
                        controller.nameController),
                    const Divider(),

                    // Calo/Phút (Bắt buộc)
                    _buildInput(
                        Icons.local_fire_department,
                        'Calo đốt mỗi phút (kcal/phút) (*)',
                        controller.caloriesPerMinuteController,
                        isNumeric: true),
                    const Divider(),

                    // Phân loại
                    _buildInput(
                        Icons.category,
                        'Phân loại (Ví dụ: Cardio, Strength)',
                        controller.categoryController),
                    const Divider(),

                    // Thiết bị
                    _buildInput(Icons.hardware, 'Thiết bị cần thiết',
                        controller.equipmentController),
                    const Divider(),

                    // Link Video
                    _buildInput(
                        Icons.link,
                        'Link Video hướng dẫn (YouTube/Khác)',
                        controller.videoUrlController),
                  ],
                ),
              ),
            ),

            // Container Ghi chú/Mô tả
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: controller.descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Nhập mô tả chi tiết bài tập...",
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- Các Widget Con --
  Widget _buildInput(IconData icon, String label, TextEditingController c,
      {bool isNumeric = false}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        labelText: label,
        border: InputBorder.none,
      ),
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
    );
  }
}
