import 'dart:async';
import 'package:flutter/material.dart';

class AddActivityPage extends StatefulWidget {
  final String activityName;
  const AddActivityPage({super.key, required this.activityName});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  bool isRunning = false;
  Duration elapsed = Duration.zero;
  Timer? timer;
  double calories = 0;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsed += const Duration(seconds: 1);
        calories = (elapsed.inSeconds / 10); // tạm tính 0.1 calo/s
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void toggleTimer() {
    setState(() {
      if (isRunning) {
        stopTimer();
      } else {
        startTimer();
      }
      isRunning = !isRunning;
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      elapsed = Duration.zero;
      calories = 0;
      isRunning = false;
    });
  }

  void saveActivity() {
    stopTimer();
    // TODO: Gửi dữ liệu lưu vào DB hoặc API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Đã lưu hoạt động '${widget.activityName}' - ${calories.toStringAsFixed(1)} kcal"),
      ),
    );
    Navigator.pop(context);
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "${h}h ${m}m ${s}s";
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thêm hoạt động"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tên bài tập
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.activityName,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Calo tiêu hao
          Column(
            children: [
              const Text(
                "Calo đã đốt cháy",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                calories == 0 ? "--" : calories.toStringAsFixed(0),
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Thanh thời gian phía dưới
          Container(
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút start/pause
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: toggleTimer,
                  child: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                ),
                // Đồng hồ
                Text(
                  formatTime(elapsed),
                  style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                // Nút lưu khi đang chạy
                if (isRunning)
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: saveActivity,
                    child: const Icon(Icons.check, size: 32),
                  )
                else
                  const SizedBox(width: 56), // để căn giữa
              ],
            ),
          ),
        ],
      ),
    );
  }
}
