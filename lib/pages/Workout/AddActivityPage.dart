// File: lib/pages/Workout/ExerciseTimerPage.dart

import 'package:dacn_app/controller/TimerController.dart';
import 'package:dacn_app/models/Exercise.dart';
import 'package:dacn_app/models/Workout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class ExerciseTimerPage extends StatefulWidget {
  final Exercise exercise;
  final CreateWorkoutExerciseDto workoutExerciseDto;
  final String planName;

  const ExerciseTimerPage({
    super.key,
    required this.exercise,
    required this.workoutExerciseDto,
    required this.planName,
  });

  @override
  State<ExerciseTimerPage> createState() => _ExerciseTimerPageState();
}

class _ExerciseTimerPageState extends State<ExerciseTimerPage> {
  // Trạng thái đếm giờ
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isRunning = false;
  String _elapsedTime = '00:00:00';
  double _caloriesBurned = 0.0;

  // Lấy giá trị caloriesPerMinute từ Exercise
  double get _caloriesPerMinute => widget.exercise.caloriesPerMinute ?? 0.0;

  // Controller
  late final ExerciseTimerController controller; // <<-- Khai báo controller

  final Color primaryColor = const Color(0xFF2196F3); // Màu xanh cho Tập luyện

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    // Khởi tạo Controller
    controller = Get.put(
      ExerciseTimerController(
        exercise: widget.exercise,
        workoutExerciseDto: widget.workoutExerciseDto,
        planName: widget.planName,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    // Không cần Get.delete() vì Controller sẽ tự động bị xóa khi trang bị pop khỏi stack (nếu dùng Get.put() trong Widget)
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_stopwatch.isRunning) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedTime = _formatTime(_stopwatch.elapsed);
        // Tính calo: Calo/phút * (Thời gian đã trôi qua/60 giây)
        _caloriesBurned =
            _caloriesPerMinute * (_stopwatch.elapsed.inSeconds / 60.0);
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
    });
    _stopwatch.stop();
    _timer.cancel();

    // Gửi dữ liệu đã tính toán sang Controller
    final durationMinutes = _stopwatch.elapsed.inSeconds / 60.0;
    controller.updateStats(durationMinutes, _caloriesBurned);

    // Mở Dialog xác nhận lưu
    _showSaveConfirmationDialog();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // Hàm hiển thị dialog xác nhận lưu
  void _showSaveConfirmationDialog() {
    Get.defaultDialog(
      title: "Hoàn Thành Bài Tập",
      content: Column(
        children: [
          Text("Bài tập: ${widget.exercise.name}"),
          Text("Thời gian: $_elapsedTime"),
          Text("Calo đốt: ${_caloriesBurned.toStringAsFixed(1)} kcal"),
          const SizedBox(height: 10),
          const Text("Bạn có muốn lưu hồ sơ hoạt động này không?"),
        ],
      ),
      confirm: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    // GỌI HÀM LƯU TỪ CONTROLLER
                    controller.saveActivityRecord();
                  },
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Lưu"),
          )),
      cancel: TextButton(
        onPressed: () => Get.back(), // Đóng dialog
        child: const Text("Hủy bỏ"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Controller đã được khởi tạo trong initState

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.exercise.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thông tin Kế hoạch và Bài tập
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kế hoạch: **${widget.planName}**",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.blueGrey)),
                      const SizedBox(height: 5),
                      Text("Loại: ${widget.exercise.category ?? 'Tập luyện'}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text(
                          "Calo tiêu chuẩn: **${_caloriesPerMinute.toStringAsFixed(1)} kcal/phút**",
                          style: const TextStyle(fontSize: 14)),
                      // Hiển thị Sets/Reps/Duration mục tiêu (Nếu có)
                      if (widget.workoutExerciseDto.sets != null &&
                          widget.workoutExerciseDto.reps != null)
                        Text(
                            "Mục tiêu: **${widget.workoutExerciseDto.sets} sets x ${widget.workoutExerciseDto.reps} reps**",
                            style: const TextStyle(fontSize: 14)),
                      if (widget.workoutExerciseDto.durationMinutes != null &&
                          (widget.workoutExerciseDto.sets == null ||
                              widget.workoutExerciseDto.reps == null))
                        Text(
                            "Mục tiêu: **${widget.workoutExerciseDto.durationMinutes!.toStringAsFixed(0)} phút**",
                            style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Hiển thị Thời gian
              Text(
                _elapsedTime,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w100,
                  color: primaryColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 10),

              // Hiển thị Calo đốt được
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _caloriesBurned.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "kcal",
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Nút Start/Stop
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'fabStartStop',
                    onPressed: _isRunning ? _stopTimer : _startTimer,
                    backgroundColor: _isRunning ? Colors.red : primaryColor,
                    child: Icon(
                      _isRunning
                          ? Icons.pause
                          : Icons.play_arrow, // Sửa thành pause khi đang chạy
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Nút Reset (chỉ hiện khi dừng)
                  if (!_isRunning && _stopwatch.elapsed.inSeconds > 0)
                    FloatingActionButton(
                      heroTag: 'fabReset',
                      onPressed: () {
                        _stopwatch.reset();
                        _caloriesBurned = 0.0;
                        _elapsedTime = '00:00:00';
                        setState(() {});
                      },
                      backgroundColor: Colors.grey,
                      child: const Icon(Icons.refresh,
                          color: Colors.white, size: 32),
                    ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
