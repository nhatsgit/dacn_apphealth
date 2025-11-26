// File: lib/controllers/MedicationController.dart

import 'package:dacn_app/models/Medication.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/MedicationService.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MedicationController extends GetxController {
  // Trạng thái loading
  var isLoading = true.obs;

  // Danh sách nhắc nhở thuốc
  var medicationRecords = <MedicationReminder>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMedications();
  }

  // ===============================================
  // HÀM TẢI DỮ LIỆU
  // ===============================================
  Future<void> fetchMedications({
    bool? active,
    DateTime? date,
  }) async {
    try {
      isLoading(true);
      final client = HttpRequest(http.Client());

      // Gọi service để lấy danh sách.
      // Vì API có phân trang (dù service chỉ trả về data), ta chọn pageSize đủ lớn
      // để lấy hết các bản ghi cần hiển thị (ví dụ: 100)
      final records = await MedicationService(client).fetchMedications(
        active: active,
        date: date,
        pageNumber: 1,
        pageSize: 100,
      );

      // Cập nhật danh sách
      medicationRecords.assignAll(records);
    } catch (e) {
      Get.snackbar(
        "Lỗi tải nhắc nhở thuốc",
        "Không thể tải hồ sơ thuốc: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Hàm Helper định dạng ngày giờ cho UI
  String formatDate(DateTime dateTime) {
    // Định dạng ngày: DD-MM-YYYY
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  // Hàm Helper định dạng thời gian: HH:mm
  String formatTime(String timeString) {
    // timeString là chuỗi HH:mm:ss từ API. Ta chỉ lấy HH:mm
    try {
      // Lấy 5 ký tự đầu tiên (HH:mm)
      return timeString.substring(0, 5);
    } catch (e) {
      return timeString; // Trả về nguyên nếu có lỗi
    }
  }
}
