import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Internal imports
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/WeightService.dart';
import 'package:dacn_app/services/UserServices.dart'; // Để lấy thông tin người dùng

class AddWeightController extends GetxController {
  // Trạng thái Loading
  var isLoading = false.obs;

  // Input fields
  final TextEditingController newWeightController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Dữ liệu hiển thị/chọn
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var previousWeight = 0.0.obs;
  var unit = 'kg'.obs; // Đơn vị mặc định

  // Services
  // LƯU Ý: Đảm bảo HttpRequest được khởi tạo đúng cách trong ứng dụng của bạn
  final WeightService _weightService =
      WeightService(HttpRequest(http.Client()));
  final UserService _userService = UserService(HttpRequest(http.Client()));

  @override
  void onInit() {
    super.onInit();
    // 1. Nhận cân nặng trước đó nếu được truyền qua arguments
    if (Get.arguments is double?) {
      previousWeight.value = Get.arguments ?? 0.0;
    }

    // 2. Gọi hàm để lấy dữ liệu ban đầu
    fetchInitialData();
  }

  // Lấy cân nặng gần nhất từ API (thay thế cho dữ liệu cứng)
  Future<void> fetchInitialData() async {
    try {
      // Dùng isLoading chỉ khi tải dữ liệu lớn, ở đây có thể bỏ qua
      // isLoading(true);

      // Lấy thông tin hồ sơ để có cân nặng gần nhất
      final profile = await _userService.fetchProfile();
      final latestWeight = profile.latestWeight ?? 0.0;

      // Nếu cân nặng gần nhất khác 0 và chưa được truyền qua argument, cập nhật
      if (latestWeight > 0 && previousWeight.value == 0.0) {
        previousWeight.value = latestWeight;
      }

      // Đặt giá trị mặc định cho ô nhập nếu có cân nặng trước đó
      if (previousWeight.value > 0) {
        newWeightController.text = previousWeight.value.toStringAsFixed(1);
      }
    } catch (e) {
      // Bỏ qua lỗi nếu không tải được cân nặng cũ, chỉ cần log
      debugPrint("Lỗi tải cân nặng cũ: $e");
    } finally {
      // isLoading(false);
    }
  }

  // --- Logic UI ---

  void updateUnit(String? newUnit) {
    if (newUnit != null) {
      unit.value = newUnit;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Chọn đến ngày hiện tại
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  // --- Logic Lưu ---

  Future<void> saveWeightRecord() async {
    final String weightText = newWeightController.text.trim();
    final double? weight = double.tryParse(weightText);

    if (weight == null || weight <= 0) {
      Get.snackbar("Lỗi", "Vui lòng nhập cân nặng hợp lệ.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading(true);

      final DateTime combinedDateTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        selectedTime.value.hour,
        selectedTime.value.minute,
      );

      final String dateForApi =
          DateFormat('yyyy-MM-dd').format(combinedDateTime);
      final String note = noteController.text.trim();

      await _weightService.createWeight(
        weight: weight,
        date: dateForApi,
        note: note,
      );
      Get.back(result: true);
      Get.snackbar(
        "Thành công",
        "Hồ sơ cân nặng đã được lưu.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ✅ CHỈNH SỬA: Quay lại và truyền kết quả thành công (true)
    } catch (e) {
      Get.snackbar(
        "Lỗi lưu cân nặng",
        "Không thể lưu hồ sơ: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
