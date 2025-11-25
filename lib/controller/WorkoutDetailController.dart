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

class WorkoutDetailController extends GetxController {
  final WorkoutPlan? workoutPlanToEdit;

  WorkoutDetailController({this.workoutPlanToEdit});

  // Services
  late final WorkoutService _workoutService;
  late final ExerciseService _exerciseService;

  // Trạng thái reactive
  var isLoading = false.obs;

  // 💡 NEW: Cache để lưu trữ Exercise đã tải từ Service
  var _exerciseCache = <int, Exercise>{}.obs;

  // Dữ liệu Form
  var nameController = TextEditingController();
  var frequencyController = TextEditingController();
  var targetStepsController = TextEditingController();
  // preferredTimeController.text sẽ chứa chuỗi định dạng "HH:mm"
  var preferredTimeController = TextEditingController();
  var notesController = TextEditingController();

  // Danh sách các bài tập được chọn trong kế hoạch (DTO)
  var workoutExercises = <CreateWorkoutExerciseDto>[].obs;

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _workoutService = WorkoutService(client);
    _exerciseService = ExerciseService(client); // Khởi tạo ExerciseService

    if (workoutPlanToEdit != null) {
      _loadDataForEdit();
    }
  }

  // ===============================================
  // LOGIC LẤY DỮ LIỆU EXERCISE TỪ SERVICE
  // ===============================================
  // 💡 HÀM ĐÃ SỬA: Bị động bộ (async) và gọi service thay vì tìm trong list
  Future<Exercise?> getExerciseById(int exerciseId) async {
    print('Tìm Exercise với ID: $exerciseId (Async)');

    // 1. Kiểm tra cache
    if (_exerciseCache.containsKey(exerciseId)) {
      return _exerciseCache[exerciseId];
    }

    // 2. Nếu không có trong cache, gọi API
    try {
      final exercise = await _exerciseService.fetchExerciseById(exerciseId);
      // 3. Cập nhật cache
      _exerciseCache[exerciseId] = exercise;
      return exercise;
    } catch (e) {
      // API có thể trả về lỗi 404 nếu bài tập bị xóa. Trả về null
      print('Lỗi khi tải Exercise ID $exerciseId từ API: $e');
      return null;
    }
  }

  // ===============================================
  // LOGIC TẢI DỮ LIỆU KHI CHỈNH SỬA
  // ===============================================
  void _loadDataForEdit() {
    final plan = workoutPlanToEdit!;
    nameController.text = plan.name;
    frequencyController.text = plan.frequency ?? '';
    targetStepsController.text = plan.targetSteps?.toString() ?? '';
    preferredTimeController.text = plan.preferredTime ?? '';
    notesController.text = plan.notes ?? '';

    // Chuyển đổi từ WorkoutExercise sang CreateWorkoutExerciseDto
    final dtos = plan.exercises.map((e) => CreateWorkoutExerciseDto(
          exerciseId: e.exerciseId,
          durationMinutes: e.durationMinutes,
          sets: e.sets,
          reps: e.reps,
          dayOfWeek: e.dayOfWeek,
          notes: e.notes,
        ));
    workoutExercises.assignAll(dtos);

    // 💡 Tải trước/cache các bài tập để hiển thị nhanh hơn (Optional)
    // Dù sao thì FutureBuilder cũng sẽ tự gọi, nhưng preload sẽ tốt hơn
    // Bạn có thể bỏ qua bước này nếu muốn giảm tải lúc khởi tạo
    for (var dto in dtos) {
      getExerciseById(dto.exerciseId);
    }
  }

  // ===============================================
  // LOGIC THÊM, SỬA, XÓA EXERCISE TRONG PLAN
  // ===============================================

  // Giả định bạn có hàm này để gọi Dialog chọn bài tập
  void showAddExerciseDialog(BuildContext context) {
    // Logic để hiển thị dialog chọn exercise
    // Trong dialog này, bạn cần gọi API lấy list exercise để chọn
    // Ví dụ: Get.to(() => SelectExercisePage());
  }

  void addExerciseToPlan({
    required int exerciseId,
    int? durationMinutes,
    int? sets,
    int? reps,
    String? notes,
  }) {
    final newDto = CreateWorkoutExerciseDto(
      exerciseId: exerciseId,
      durationMinutes: durationMinutes,
      sets: sets,
      reps: reps,
      notes: notes,
    );
    workoutExercises.add(newDto);
  }

  void updateExerciseInPlan(int index, CreateWorkoutExerciseDto dto) {
    workoutExercises[index] = dto;
  }

  void removeExerciseFromPlan(int index) {
    workoutExercises.removeAt(index);
  }

  // ===============================================
  // LOGIC LƯU DỮ LIỆU
  // ===============================================
  Future<void> saveWorkoutPlan() async {
    if (nameController.text.isEmpty) {
      Get.snackbar(
        "Lỗi",
        "Tên kế hoạch là bắt buộc.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Kiểm tra xem có bài tập nào không
    if (workoutExercises.isEmpty) {
      Get.snackbar(
        "Lỗi",
        "Kế hoạch cần có ít nhất một bài tập.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading(true);

    try {
      final int? targetSteps =
          int.tryParse(targetStepsController.text.replaceAll(',', '.'));

      final dto = CreateWorkoutPlanDto(
        name: nameController.text,
        frequency:
            frequencyController.text.isEmpty ? null : frequencyController.text,
        targetSteps: targetSteps,
        preferredTime: preferredTimeController.text.isEmpty
            ? null
            : preferredTimeController.text,
        notes: notesController.text.isEmpty ? null : notesController.text,
        exercises: workoutExercises.toList(),
      );

      // Gọi API
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

      Get.back(); // Quay lại trang trước

      // Sau khi lưu, yêu cầu cập nhật danh sách trên trang chính
      // Giả định WorkoutController tồn tại
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
}
