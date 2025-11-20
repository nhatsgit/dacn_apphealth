// File: lib/controllers/AddSleepController.dart

import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/SleepService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddSleepController extends GetxController {
  // Trạng thái cho việc hiển thị loading/saving
  var isLoading = false.obs;

  // Trạng thái của các trường nhập liệu (Observable)
  var startTime = Rxn<DateTime>();
  var endTime = Rxn<DateTime>();
  var sleepQuality = Rxn<String>(); // Sử dụng Rxn<String> cho phép null
  var sleepType = Rxn<String>();
  var notes = ''.obs;

  // Trạng thái tính toán
  var durationMinutes = 0.obs;

  // Danh sách cố định (để hiển thị trong Dropdown)
  final List<String> sleepQualities = ['Tuyệt', 'Tốt', 'Trung Bình', 'Xấu'];
  final List<String> sleepTypes = ['Ngủ Đêm', 'Ngắn Ngủ', 'Ngủ Trưa'];

  late final SleepService _sleepService;

  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _sleepService = SleepService(client);

    // 💡 Đăng ký lắng nghe sự thay đổi của startTime và endTime
    // để tính toán lại durationMinutes khi một trong hai thay đổi.
    everAll([startTime, endTime], (_) => _calculateDuration());
  }

  // ===============================================
  // LOGIC TÍNH TOÁN
  // ===============================================

  void _calculateDuration() {
    if (startTime.value != null && endTime.value != null) {
      final start = startTime.value!;
      final end = endTime.value!;

      // Xử lý trường hợp ngủ qua đêm (End time nhỏ hơn Start time)
      DateTime effectiveEnd = end;
      if (end.isBefore(start)) {
        // Giả định ngủ qua đêm, End time là ngày hôm sau
        effectiveEnd = end.add(const Duration(days: 1));
      }

      final duration = effectiveEnd.difference(start);
      // Thời gian ngủ không được âm
      if (duration.inMinutes > 0) {
        durationMinutes.value = duration.inMinutes;
      } else {
        durationMinutes.value = 0;
      }
    } else {
      durationMinutes.value = 0;
    }
  }

  // ===============================================
  // LOGIC LƯU DỮ LIỆU
  // ===============================================

  Future<void> saveRecord() async {
    // 1. Kiểm tra validation
    if (startTime.value == null || endTime.value == null) {
      Get.snackbar(
        "Lỗi",
        "Vui lòng chọn thời gian bắt đầu và kết thúc.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (durationMinutes.value <= 0) {
      Get.snackbar(
        "Lỗi",
        "Thời gian kết thúc phải sau thời gian bắt đầu.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Thiết lập trạng thái Loading
    isLoading(true);

    try {
      // 3. Gọi API tạo hồ sơ mới
      await _sleepService.createSleepRecord(
        startTime: startTime.value!,
        endTime: endTime.value!,
        sleepQuality: sleepQuality.value,
        sleepType: sleepType.value,
        notes: notes.value.isEmpty ? null : notes.value,
      );
      Get.back();
      // 4. Thông báo thành công và quay lại
      Get.snackbar(
        "Thành công",
        "Đã thêm hồ sơ giấc ngủ mới!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Trả về true để SleepPage biết cần tải lại danh sách
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        "Lỗi lưu",
        "Không thể lưu hồ sơ giấc ngủ: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
