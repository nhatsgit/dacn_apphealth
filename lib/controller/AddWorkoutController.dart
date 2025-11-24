// File: lib/controller/AddWorkoutController.dart

import 'package:dacn_app/controller/WorkoutRecordController.dart';
import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/models/Workout.dart';
import 'package:dacn_app/services/ExerciseService.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/WorkoutService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddWorkoutPlanController extends GetxController {
  final WorkoutPlan? workoutPlanToEdit;

  AddWorkoutPlanController({this.workoutPlanToEdit});

  // Services
  late final WorkoutService _workoutService;
  late final ExerciseService _exerciseService;

  // Trạng thái reactive
  var isLoading = false.obs;
  var isExerciseLoading = false.obs;

  // Dữ liệu Form
  var nameController = TextEditingController();
  var frequencyController = TextEditingController();
  var targetStepsController = TextEditingController();
  // preferredTimeController.text sẽ chứa chuỗi định dạng "HH:mm"
  var preferredTimeController = TextEditingController();
  var notesController = TextEditingController();

  // Danh sách các bài tập được chọn trong kế hoạch (DTO)
  var workoutExercises = <CreateWorkoutExerciseDto>[].obs;
  // Danh sách tất cả bài tập (Library)
  var exerciseList = <Exercise>[].obs;

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _workoutService = WorkoutService(client);
    _exerciseService = ExerciseService(client);

    // Tải danh sách Exercise Library
    fetchExerciseList();

    // Nếu là chế độ chỉnh sửa, điền dữ liệu
    if (workoutPlanToEdit != null) {
      _loadDataForEdit();
    }
  }

  void _loadDataForEdit() {
    final plan = workoutPlanToEdit!;
    nameController.text = plan.name;
    frequencyController.text = plan.frequency ?? '';
    targetStepsController.text = plan.targetSteps?.toString() ?? '';
    // Gán dữ liệu thời gian có sẵn từ model
    preferredTimeController.text = plan.preferredTime ?? '';
    notesController.text = plan.notes ?? '';

    // Chuyển đổi WorkoutExercise thành CreateWorkoutExerciseDto
    workoutExercises.value = plan.exercises
        .map((we) => CreateWorkoutExerciseDto(
              exerciseId: we.exerciseId,
              durationMinutes: we.durationMinutes,
              sets: we.sets,
              reps: we.reps,
              dayOfWeek: we.dayOfWeek,
              notes: we.notes,
            ))
        .toList();
  }

  // Tải danh sách Exercise Library
  Future<void> fetchExerciseList() async {
    try {
      isExerciseLoading(true);
      final list = await _exerciseService.fetchAllExercises();
      exerciseList.value = list;
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải danh sách bài tập: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isExerciseLoading(false);
    }
  }

  // Thêm một bài tập vào kế hoạch
  void addExerciseToPlan({
    required int exerciseId,
    int? durationMinutes,
    int? sets,
    int? reps,
    String? dayOfWeek,
    String? notes,
  }) {
    final dto = CreateWorkoutExerciseDto(
      exerciseId: exerciseId,
      durationMinutes: durationMinutes,
      sets: sets,
      reps: reps,
      dayOfWeek: dayOfWeek,
      notes: notes,
    );
    workoutExercises.add(dto);
  }

  // Cập nhật một bài tập trong kế hoạch (dùng index)
  void updateExerciseInPlan(int index, CreateWorkoutExerciseDto newDto) {
    if (index >= 0 && index < workoutExercises.length) {
      workoutExercises[index] = newDto;
    }
  }

  // Xóa một bài tập khỏi kế hoạch
  void removeExerciseFromPlan(int index) {
    workoutExercises.removeAt(index);
  }

  // Hàm lưu
  Future<void> saveWorkoutPlan() async {
    if (nameController.text.isEmpty) {
      Get.snackbar("Cảnh báo", "Tên kế hoạch không được để trống.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    if (workoutExercises.isEmpty) {
      Get.snackbar("Cảnh báo", "Kế hoạch phải có ít nhất một bài tập.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isLoading(true);

    try {
      // Chuẩn bị DTO
      final dto = CreateWorkoutPlanDto(
        name: nameController.text,
        frequency:
            frequencyController.text.isEmpty ? null : frequencyController.text,
        // Chuyển đổi an toàn từ String sang Int
        targetSteps: int.tryParse(targetStepsController.text),
        // preferredTimeController đã chứa chuỗi "HH:mm" hoặc rỗng
        preferredTime: preferredTimeController.text.isEmpty
            ? null
            : preferredTimeController.text,
        notes: notesController.text.isEmpty ? null : notesController.text,
        exercises: workoutExercises.toList(),
      );
      Get.back();
      if (workoutPlanToEdit != null) {
        // Cập nhật
        await _workoutService.updateWorkoutPlan(workoutPlanToEdit!.id, dto);
        Get.snackbar("Thành công", "Đã cập nhật kế hoạch tập luyện.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        // Tạo mới
        await _workoutService.createWorkoutPlan(dto);
        Get.snackbar("Thành công", "Đã thêm kế hoạch tập luyện mới.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      }

      // Quay lại trang trước

      // Sau khi lưu, yêu cầu cập nhật danh sách trên trang chính
      // Lưu ý: Tên class đã được sửa thành WorkoutController nếu bạn dùng class này trên WorkoutPage
      // Tôi dùng Get.find<WorkoutController>() theo cấu trúc đã tạo trước đó
      final workoutController = Get.find<WorkoutController>();
      await workoutController.fetchWorkoutPlans();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu kế hoạch tập luyện: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // Hàm tìm Exercise từ ID
  Exercise? getExerciseById(int exerciseId) {
    return exerciseList.firstWhereOrNull((e) => e.id == exerciseId);
  }
}
