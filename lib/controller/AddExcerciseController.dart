// File: lib/controller/AddExerciseController.dart

import 'package:dacn_app/controller/ExcerciseController.dart';
import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/services/ExerciseService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExerciseController extends GetxController {
  final Exercise? exerciseToEdit;

  AddExerciseController({this.exerciseToEdit});

  // Trạng thái loading
  var isSaving = false.obs;

  // Controllers cho các trường nhập liệu
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  // Calo/Phút là bắt buộc và là double
  final caloriesPerMinuteController = TextEditingController();
  final equipmentController = TextEditingController();
  final videoUrlController = TextEditingController();

  // Tham chiếu đến ExerciseController để cập nhật danh sách sau khi lưu
  late final ExerciseController _exerciseController;
  late final ExerciseService _exerciseService;
  @override
  void onInit() {
    super.onInit();
    _exerciseController = Get.find<ExerciseController>();

    if (exerciseToEdit != null) {
      _loadDataForEdit();
    }
  }

  void _loadDataForEdit() {
    final e = exerciseToEdit!;
    nameController.text = e.name;
    categoryController.text = e.category ?? '';
    descriptionController.text = e.description ?? '';
    caloriesPerMinuteController.text = e.caloriesPerMinute?.toString() ?? '';
    equipmentController.text = e.equipment ?? '';
    videoUrlController.text = e.videoUrl ?? '';
  }

  // ===============================================
  // LOGIC LƯU DỮ LIỆU
  // ===============================================
  Future<void> saveExercise() async {
    // 1. Validation cơ bản
    if (nameController.text.isEmpty ||
        caloriesPerMinuteController.text.isEmpty) {
      Get.snackbar(
        "Lỗi",
        "Tên bài tập và Calo/phút là bắt buộc.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final double? caloriesPerMinute =
        double.tryParse(caloriesPerMinuteController.text.replaceAll(',', '.'));

    if (caloriesPerMinute == null || caloriesPerMinute <= 0) {
      Get.snackbar(
        "Lỗi",
        "Calo/phút phải là số lớn hơn 0.",
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
      final CreateExerciseDto dto = CreateExerciseDto(
        name: nameController.text,
        category:
            categoryController.text.isNotEmpty ? categoryController.text : null,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        caloriesPerMinute: caloriesPerMinute,
        equipment: equipmentController.text.isNotEmpty
            ? equipmentController.text
            : null,
        videoUrl:
            videoUrlController.text.isNotEmpty ? videoUrlController.text : null,
      );

      if (exerciseToEdit != null) {
        // Cập nhật
        await _exerciseService.updateExercise(exerciseToEdit!.id, dto);

        Get.snackbar("Thành công", "Đã cập nhật bài tập '${dto.name}'.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        // Tạo mới
        await _exerciseController.createExercise(dto);
      }

      // 4. Thành công: Quay lại trang danh sách và tải lại
      Get.back();
      _exerciseController.fetchExercises();
    } catch (e) {
      // Lỗi đã được xử lý trong createExercise/updateExercise nhưng ném lại để đảm bảo trạng thái loading được reset
      Get.snackbar(
        "Lỗi",
        "Không thể lưu bài tập: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving(false);
    }
  }
}
