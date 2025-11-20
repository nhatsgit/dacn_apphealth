// File: lib/controllers/SleepController.dart

import 'package:dacn_app/models/Sleep.dart'; // SleepRecord, cần được định nghĩa
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/SleepService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SleepController extends GetxController
    with StateMixin<List<SleepRecord>> {
  // Danh sách hồ sơ giấc ngủ
  var sleepRecords = <SleepRecord>[].obs;

  // Các chỉ số thống kê (Duration tính bằng phút)
  var avgDurationMinutes = 0.obs;
  var totalSleepHours = 0.0.obs;

  // Tổng số bản ghi (dùng cho phân trang)
  var totalRecords = 0.obs;

  late final SleepService _sleepService;

  // Khởi tạo Client và Service
  @override
  void onInit() {
    super.onInit();
    final client = HttpRequest(http.Client());
    _sleepService = SleepService(client);

    // Tải dữ liệu khi Controller được khởi tạo
    fetchSleepRecords();
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU & TÍNH TOÁN STATS
  // ===============================================
  Future<void> fetchSleepRecords(
      {int pageNumber = 1, int pageSize = 10}) async {
    // Đặt trạng thái Loading, chỉ áp dụng cho lần tải đầu tiên
    if (pageNumber == 1) {
      change(null, status: RxStatus.loading());
    }

    try {
      final response = await _sleepService.fetchSleepRecords(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      if (pageNumber == 1) {
        // Thay thế hoàn toàn danh sách cho trang đầu tiên
        sleepRecords.assignAll(response.data);
      } else {
        // Thêm vào danh sách cho các trang tiếp theo
        sleepRecords.addAll(response.data);
      }

      totalRecords.value = response.totalRecords;

      // ✅ Tính toán Stats
      _calculateStats();

      // Đặt trạng thái Success
      change(sleepRecords, status: RxStatus.success());
    } catch (e) {
      print("Lỗi tải hồ sơ giấc ngủ: $e");
      // Đặt trạng thái Error
      change(null, status: RxStatus.error(e.toString()));
      Get.snackbar(
        "Lỗi tải dữ liệu",
        "Không thể tải hồ sơ giấc ngủ: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Hàm tính toán các chỉ số thống kê
  void _calculateStats() {
    if (sleepRecords.isEmpty) {
      avgDurationMinutes.value = 0;
      totalSleepHours.value = 0.0;
      return;
    }

    // Lọc ra các bản ghi có durationMinutes hợp lệ
    final validDurations = sleepRecords
        .where((r) => r.durationMinutes != null && r.durationMinutes! > 0)
        .map((r) => r.durationMinutes!)
        .toList();

    if (validDurations.isEmpty) {
      avgDurationMinutes.value = 0;
      totalSleepHours.value = 0.0;
      return;
    }

    // Tính tổng thời lượng (phút)
    final totalMinutes = validDurations.reduce((a, b) => a + b);

    // Tính thời lượng ngủ trung bình (phút)
    avgDurationMinutes.value = (totalMinutes / validDurations.length).round();

    // Tính tổng số giờ ngủ (chỉ lấy tổng của trang đầu tiên hoặc toàn bộ)
    // Lưu ý: totalSleepHours thường tính trong một khung thời gian cụ thể (ví dụ: tuần, tháng)
    // Ở đây ta tính tổng số giờ ngủ của các bản ghi hiện có trong danh sách
    totalSleepHours.value = totalMinutes / 60.0;
  }

  // ===============================================
  // HÀM XÓA
  // ===============================================
  Future<void> deleteSleepRecord(int id) async {
    try {
      // 1. Gọi API xóa
      await _sleepService.deleteSleepRecord(id);

      // 2. Xóa khỏi danh sách cục bộ và cập nhật UI
      sleepRecords.removeWhere((record) => record.id == id);

      // 3. Tái tính toán stats
      _calculateStats();

      Get.snackbar(
        "Thành công",
        "Đã xóa hồ sơ giấc ngủ!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // 4. Nếu danh sách trống, chuyển trạng thái về empty
      if (sleepRecords.isEmpty) {
        change(sleepRecords, status: RxStatus.empty());
      } else {
        // Cập nhật trạng thái Success để kích hoạt Obx
        change(sleepRecords, status: RxStatus.success());
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi xóa",
        "Không thể xóa hồ sơ giấc ngủ: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
