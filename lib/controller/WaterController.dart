// File: lib/controller/WaterController.dart

import 'package:dacn_app/models/Water.dart';
import 'package:dacn_app/models/Weight.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/UserServices.dart'; // Giả định cần UserServices để lấy mục tiêu

import 'package:dacn_app/services/WaterServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WaterController extends GetxController with StateMixin<WaterRecord> {
  // Trạng thái cho bản ghi nước hôm nay
  var todayRecord = Rxn<WaterRecord>(); // Rxn cho phép giá trị null

  // Trạng thái hiển thị trong UI (được tính toán)
  var goalIntake = 2.0.obs; // Mục tiêu (Lít), mặc định 2L
  var totalIntake = 0.0.obs; // Tổng lượng đã uống (Lít)
  var remaining = 2.0.obs; // Lượng còn lại cần uống (Lít)
  var fillPercent = 0.0.obs; // Tỷ lệ hoàn thành (0.0 - 1.0)

  // Instance Service
  late final WaterService _waterService;
  late final HttpRequest _client;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo Client và Service
    _client = HttpRequest(http.Client());
    _waterService = WaterService(_client);

    // Tải dữ liệu ban đầu
    fetchTodayWaterRecord();
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU
  // ===============================================
  Future<void> fetchTodayWaterRecord() async {
    // 💡 Sử dụng change(null, status: RxStatus.loading()) để thiết lập trạng thái Loading
    change(null, status: RxStatus.loading());
    try {
      // 1. Lấy bản ghi nước hôm nay (hoặc tạo mới)
      final record = await _waterService.getOrCreateTodayWaterRecord();
      final resIdealWater = await UserService(_client).fetchIdealWater();
      // 2. Cập nhật trạng thái
      todayRecord.value = record;
      goalIntake.value = resIdealWater;
      // 3. Tính toán các chỉ số
      _calculateStats(record);

      // 4. Thiết lập trạng thái Success
      change(record, status: RxStatus.success());
    } catch (e) {
      print("Lỗi tải hồ sơ nước hôm nay: $e");
      // 5. Thiết lập trạng thái Error
      change(null, status: RxStatus.error(e.toString()));
      Get.snackbar(
        "Lỗi tải nước",
        "Không thể tải hồ sơ nước hôm nay: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ===============================================
  // HÀM TÍNH TOÁN STATS
  // ===============================================
  void _calculateStats(WaterRecord record) {
    // Lấy mục tiêu (chuyển từ ml sang L)
    final goalMl = goalIntake.value;
    goalIntake.value = goalMl / 1000.0;

    // Lấy lượng đã uống (chuyển từ ml sang L)
    final totalMl = record.amount.toDouble();
    totalIntake.value = totalMl / 1000.0;

    // Tính toán tỷ lệ phần trăm
    fillPercent.value = totalMl / goalMl;
    // Giới hạn phần trăm tối đa là 1.0
    if (fillPercent.value > 1.0) {
      fillPercent.value = 1.0;
    }

    // Tính lượng còn lại
    final remainingMl = goalMl - totalMl;
    // Giới hạn lượng còn lại tối thiểu là 0.0
    remaining.value = (remainingMl / 1000.0).clamp(0.0, double.infinity);
  }

  // ===============================================
  // HÀM XỬ LÝ SỰ KIỆN THÊM NƯỚC
  // ===============================================
  Future<void> addWater(double amountLiter) async {
    if (todayRecord.value == null) {
      Get.snackbar("Lỗi", "Không thể ghi nhận nước. Vui lòng tải lại trang.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Chuyển lượng nước thêm vào từ Lít sang ml
    final amountMl = (amountLiter * 1000).round();

    try {
      // 1. Tạo bản ghi mới (sử dụng createWaterRecord)
      // Giả định createWaterRecord sẽ tạo một bản ghi nước chi tiết
      // và backend tự động cập nhật tổng lượng nước trong bản ghi today.
      final newRecord = await _waterService.createWaterRecord(
        amount: amountMl,
        date: todayRecord.value!.date, // Dùng ngày của bản ghi hôm nay
        time: DateFormat('HH:mm').format(DateTime.now()), // Thêm thời gian uống
        target: todayRecord.value!.target,
      );

      // 2. Sau khi thêm thành công, tải lại bản ghi hôm nay
      // để cập nhật totalIntake và các chỉ số.
      await fetchTodayWaterRecord();

      Get.snackbar(
        "Thành công",
        "Đã thêm ${amountLiter.toStringAsFixed(2)} Lít nước!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Lỗi thêm nước: $e");
      Get.snackbar(
        "Lỗi thêm nước",
        "Không thể thêm nước: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
