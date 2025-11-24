// File: lib/pages/Workout/AddWorkoutPage.dart

import 'package:dacn_app/controller/AddWorkoutController.dart';
import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/models/Workout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddWorkoutPlanPage extends StatelessWidget {
  final WorkoutPlan? workoutPlanToEdit;

  const AddWorkoutPlanPage({super.key, this.workoutPlanToEdit});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    // Đảm bảo tên Controller khớp với file đã sửa
    final controller = Get.put(
      AddWorkoutPlanController(workoutPlanToEdit: workoutPlanToEdit),
    );

    final isEditing = workoutPlanToEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          isEditing ? 'Chỉnh Sửa Kế Hoạch' : 'Thêm Kế Hoạch Mới',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.saveWorkoutPlan,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                  : const Text(
                      'LƯU',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM THÔNG TIN KẾ HOẠCH ---
              _buildPlanDetailsForm(context, controller), // Truyền context
              const SizedBox(height: 20),

              // --- DANH SÁCH BÀI TẬP ĐƯỢC CHỌN ---
              _buildSelectedExercisesSection(context, controller),
              const SizedBox(height: 20),

              // --- THANH TÌM KIẾM VÀ THÊM BÀI TẬP ---
              _buildAddExerciseSection(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng Form chi tiết Kế hoạch
  Widget _buildPlanDetailsForm(
      BuildContext context, AddWorkoutPlanController controller) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildTextField(
              controller: controller.nameController,
              label: 'Tên Kế hoạch',
              icon: Icons.bookmark_border,
              keyboardType: TextInputType.text,
            ),
            _buildTextField(
              controller: controller.frequencyController,
              label: 'Tần suất (Ví dụ: 3 lần/tuần)',
              icon: Icons.repeat,
              keyboardType: TextInputType.text,
            ),

            // ⭐️ ĐÃ SỬA: Dùng Time Picker thay vì TextField
            _buildTimePickerField(
              context,
              controller: controller.preferredTimeController,
              label: 'Thời gian ưu tiên',
              icon: Icons.access_time,
            ),

            _buildTextField(
              controller: controller.targetStepsController,
              label: 'Mục tiêu bước đi hàng ngày',
              icon: Icons.directions_walk,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: controller.notesController,
              label: 'Ghi chú',
              icon: Icons.note,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo TextField tùy chỉnh
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
      ),
    );
  }

  // ⭐️ HÀM MỚI: Dùng Time Picker để chọn giờ
  Widget _buildTimePickerField(BuildContext context,
      {required TextEditingController controller,
      required String label,
      required IconData icon}) {
    // Phân tích giá trị hiện tại để làm initial time
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split(':');
        initialTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {
        // Bỏ qua nếu giá trị không hợp lệ, giữ nguyên initialTime mặc định
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: initialTime,
            // Đảm bảo Time Picker hiện ra bằng ngôn ngữ/vùng miền của thiết bị
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat:
                        true), // Force 24h format for API compatibility
                child: child!,
              );
            },
          );
          if (picked != null) {
            // Định dạng thành chuỗi "HH:mm" (24h format) để gửi lên API
            final formattedTime =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
            controller.text = formattedTime;
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            readOnly: true, // Không cho phép gõ tay
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              hintText: controller.text.isEmpty
                  ? 'Chọn giờ (HH:mm)'
                  : controller.text,
              prefixIcon: Icon(icon, color: Colors.blue.shade700),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => controller.clear(),
                    )
                  : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng danh sách Bài tập đã chọn
  Widget _buildSelectedExercisesSection(
      BuildContext context, AddWorkoutPlanController controller) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Các bài tập trong kế hoạch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(() => Text(
                      '(${controller.workoutExercises.length})',
                      style:
                          TextStyle(fontSize: 14, color: Colors.blue.shade700),
                    )),
              ],
            ),
            const Divider(),
            Obx(() {
              if (controller.workoutExercises.isEmpty) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Vui lòng thêm bài tập vào kế hoạch.'),
                ));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.workoutExercises.length,
                itemBuilder: (context, index) {
                  final workoutExerciseDto = controller.workoutExercises[index];
                  final exercise =
                      controller.getExerciseById(workoutExerciseDto.exerciseId);

                  if (exercise == null) {
                    return ListTile(
                      title: Text(
                          'ID Bài tập: ${workoutExerciseDto.exerciseId} (Lỗi)',
                          style: const TextStyle(color: Colors.red)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            controller.removeExerciseFromPlan(index),
                      ),
                    );
                  }

                  // Hiển thị thông tin bài tập
                  String detailText = '';
                  if (workoutExerciseDto.durationMinutes != null &&
                      workoutExerciseDto.durationMinutes! > 0) {
                    detailText +=
                        '${workoutExerciseDto.durationMinutes!.toStringAsFixed(0)} phút';
                  }
                  if (workoutExerciseDto.sets != null &&
                      workoutExerciseDto.sets! > 0) {
                    if (detailText.isNotEmpty) detailText += ' | ';
                    detailText += '${workoutExerciseDto.sets} sets';
                  }
                  if (workoutExerciseDto.reps != null &&
                      workoutExerciseDto.reps! > 0) {
                    if (detailText.isNotEmpty) detailText += ' | ';
                    detailText += '${workoutExerciseDto.reps} reps';
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(detailText.isEmpty
                        ? 'Chưa nhập chi tiết tập luyện'
                        : detailText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút Sửa
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Colors.blue.shade700, size: 20),
                          onPressed: () => _showExerciseDetailDialog(
                              context, controller, exercise,
                              index: index, dtoToEdit: workoutExerciseDto),
                        ),
                        // Nút Xóa
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 20),
                          onPressed: () =>
                              controller.removeExerciseFromPlan(index),
                        ),
                      ],
                    ),
                    onTap: () => _showExerciseDetailDialog(
                        context, controller, exercise,
                        index: index, dtoToEdit: workoutExerciseDto),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng phần Tìm kiếm Bài tập
  Widget _buildAddExerciseSection(
      BuildContext context, AddWorkoutPlanController controller) {
    var searchTerm = ''.obs;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm bài tập từ thư viện',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                onChanged: (value) => searchTerm.value = value.toLowerCase(),
                decoration: InputDecoration(
                  labelText: 'Tìm kiếm bài tập...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),

            // Danh sách kết quả tìm kiếm
            Container(
              constraints:
                  const BoxConstraints(maxHeight: 300), // Giới hạn chiều cao
              child: Obx(() {
                if (controller.isExerciseLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Lọc danh sách theo từ khóa tìm kiếm
                final filteredList = controller.exerciseList.where((exercise) {
                  return exercise.name.toLowerCase().contains(searchTerm.value);
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                        searchTerm.value.isEmpty
                            ? "Không có dữ liệu bài tập trong thư viện"
                            : "Không tìm thấy bài tập '${searchTerm.value}'",
                        style: const TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredList[index];
                    return ListTile(
                      title: Text(exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          "${exercise.caloriesPerMinute?.toStringAsFixed(1) ?? '?'} kcal/phút"),
                      trailing: const Icon(Icons.add, color: Color(0xFF2196F3)),
                      onTap: () {
                        // Mở dialog để nhập thông tin chi tiết bài tập
                        _showExerciseDetailDialog(
                            context, controller, exercise);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog nhập thông tin chi tiết bài tập (Sets, Reps, Duration)
  void _showExerciseDetailDialog(BuildContext context,
      AddWorkoutPlanController controller, Exercise exercise,
      {int? index, CreateWorkoutExerciseDto? dtoToEdit}) {
    final isEditing = index != null;

    final durationController = TextEditingController(
        text: dtoToEdit?.durationMinutes?.toString() ?? '');
    final setsController =
        TextEditingController(text: dtoToEdit?.sets?.toString() ?? '');
    final repsController =
        TextEditingController(text: dtoToEdit?.reps?.toString() ?? '');
    final notesController = TextEditingController(text: dtoToEdit?.notes ?? '');

    Get.defaultDialog(
      title: isEditing ? 'Chỉnh Sửa Bài Tập' : 'Thêm Bài Tập',
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(exercise.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
                '~${exercise.caloriesPerMinute?.toStringAsFixed(1) ?? '?'} kcal/phút',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            _buildDialogTextField(
                controller: durationController,
                label: 'Thời lượng (phút)',
                keyboardType: TextInputType.number),
            _buildDialogTextField(
                controller: setsController,
                label: 'Số Sets',
                keyboardType: TextInputType.number),
            _buildDialogTextField(
                controller: repsController,
                label: 'Số Reps',
                keyboardType: TextInputType.number),
            _buildDialogTextField(
                controller: notesController,
                label: 'Ghi chú cho bài tập này',
                keyboardType: TextInputType.multiline,
                maxLines: 3),
          ],
        ),
      ),
      textConfirm: isEditing ? 'Cập nhật' : 'Thêm',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue.shade700,
      onConfirm: () {
        final duration = int.tryParse(durationController.text);
        final sets = int.tryParse(setsController.text);
        final reps = int.tryParse(repsController.text);
        final notes =
            notesController.text.isEmpty ? null : notesController.text;

        final newDto = CreateWorkoutExerciseDto(
          exerciseId: exercise.id,
          durationMinutes: duration,
          sets: sets,
          reps: reps,
          dayOfWeek: dtoToEdit?.dayOfWeek, // Giữ nguyên DayOfWeek nếu có
          notes: notes,
        );

        if (isEditing) {
          controller.updateExerciseInPlan(index!, newDto);
        } else {
          controller.addExerciseToPlan(
            exerciseId: exercise.id,
            durationMinutes: duration,
            sets: sets,
            reps: reps,
            notes: notes,
          );
        }

        Get.back(); // Đóng dialog
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
      ),
    );
  }
}
