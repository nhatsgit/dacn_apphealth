// File: lib/controllers/WeightController.dart

import 'package:dacn_app/models/Weight.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/UserServices.dart';
import 'package:dacn_app/services/WeightService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeightController extends GetxController {
  // Trạng thái loading
  var isLoading = true.obs;
  // Danh sách hồ sơ cân nặng
  var weightRecords = <WeightRecord>[].obs;

  // Các chỉ số thống kê (sẽ được tính toán)
  var minWeight = 0.0.obs;
  var maxWeight = 0.0.obs;
  var avgWeight = 0.0.obs;
  var idealWeight = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeights();
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU VÀ TÍNH TOÁN STATS
  // ===============================================
  Future<void> fetchWeights() async {
    try {
      isLoading(true);
      final client = HttpRequest(http.Client());
      // Lấy tối đa 100 bản ghi để tính toán thống kê và hiển thị lịch sử
      final response = await WeightService(client).fetchWeights(
        pageNumber: 1,
        pageSize: 50,
      );
      final resIdealWeight = await UserService(client).fetchIdealWeight();
      weightRecords.assignAll(response.data);

      // ✅ Tính toán Stats
      if (weightRecords.isNotEmpty) {
        final weights = weightRecords.map((r) => r.weight).toList();
        minWeight.value = weights.reduce((a, b) => a < b ? a : b);
        maxWeight.value = weights.reduce((a, b) => a > b ? a : b);
        // Tính trung bình
        avgWeight.value = weights.reduce((a, b) => a + b) / weights.length;

        // Lấy IdealWeight từ bản ghi gần nhất (giả định nó giống nhau)
        idealWeight.value = resIdealWeight;
      } else {
        // Đặt lại về 0 nếu không có dữ liệu
        minWeight.value = 0.0;
        maxWeight.value = 0.0;
        avgWeight.value = 0.0;
        idealWeight.value =
            0.0; // Có thể gọi UserService.fetchIdealWeight() nếu cần
      }
    } catch (e) {
      print(
        "Lỗi tải cân nặng" + "Không thể tải hồ sơ cân nặng: $e",
      );
      Get.snackbar(
        "Lỗi tải cân nặng",
        "Không thể tải hồ sơ cân nặng: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Hàm Helper định dạng ngày giờ cho UI
  String formatWeightDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}
