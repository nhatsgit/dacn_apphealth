// File: lib/controllers/MedicationDetailController.dart

import 'package:dacn_app/controller/MedicationController.dart';
import 'package:dacn_app/models/Medication.dart'; // Giả định: Chứa MedicationReminder & CreateMedicationReminderDto
import 'package:dacn_app/services/HttpRequest.dart'; // Giả định
import 'package:dacn_app/services/MedicationService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MedicationDetailController extends GetxController {
  // ===============================================
  // TRẠNG THÁI CHUNG
  // ===============================================
  var isLoading = false.obs;
  var isEditMode = false.obs;
  int? recordId; // ID của bản ghi nếu đang ở chế độ Edit

  // ===============================================
  // FORM CONTROLLERS & OBSERVABLES
  // ===============================================
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final noteController = TextEditingController();

  // Observable cho các trường cần chọn
  // Ngày bắt đầu (DateTime) - sử dụng Rxn<DateTime> cho tính linh hoạt
  var selectedStartDate = Rxn<DateTime>();
  var selectedEndDate = Rxn<DateTime>(); // Ngày kết thúc (Optional)

  // Thời gian nhắc nhở (TimeOfDay)
  var selectedReminderTime = TimeOfDay.now().obs;

  // Tần suất/Hướng dẫn (String, ví dụ: 'before', 'after')
  var selectedFrequency = "before".obs;

  // Trạng thái hoạt động
  var isActive = true.obs;

  // ===============================================
  // LOGIC KHỞI TẠO & TẢI DỮ LIỆU
  // ===============================================

  void initForm(int? id) {
    if (id != null) {
      recordId = id;
      isEditMode(true);
      fetchMedicationDetail(id);
    } else {
      // Chế độ Add New
      recordId = null;
      isEditMode(false);
      resetForm();
    }
  }

  void resetForm() {
    nameController.clear();
    dosageController.clear();
    noteController.clear();
    // Khởi tạo các giá trị mặc định cho form
    selectedStartDate.value = DateTime.now();
    selectedEndDate.value = null;
    selectedReminderTime.value = TimeOfDay.now();
    selectedFrequency.value = "before";
    isActive.value = true;
  }

  Future<void> fetchMedicationDetail(int id) async {
    try {
      isLoading(true);
      final client = HttpRequest(http.Client());
      final service = MedicationService(client);

      final record = await service.fetchMedicationById(id);

      // Gán dữ liệu vào các Controller/Observable
      nameController.text = record.medicineName;
      dosageController.text = record.dosage ?? '';
      noteController.text = record.note ?? '';

      selectedStartDate.value = record.startDate;
      selectedEndDate.value = record.endDate;
      selectedFrequency.value = record.frequency ?? 'before';
      isActive.value = record.isActive;
      selectedReminderTime.value = _parseTimeOnly(record.reminderTime);
    } catch (e) {
      Get.snackbar("Lỗi tải chi tiết", "Không thể tải chi tiết thuốc: $e",
          snackPosition: SnackPosition.BOTTOM);
      Get.back(); // Quay lại trang trước nếu lỗi
    } finally {
      isLoading(false);
    }
  }

  // ===============================================
  // LOGIC FORM SUBMISSION
  // ===============================================

  Future<void> saveMedication() async {
    if (nameController.text.isEmpty || selectedStartDate.value == null) {
      Get.snackbar("Lỗi", "Tên thuốc và Ngày bắt đầu không được để trống",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Đảm bảo startDate không null
    final startDate = selectedStartDate.value!;

    try {
      // 1. Format ReminderTime thành string HH:MM:SS
      final timeOfDay = selectedReminderTime.value;
      final formattedTime =
          '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}:00';

      final client = HttpRequest(http.Client());
      final service = MedicationService(client);

      // 2. Tạo DTO
      final dto = CreateMedicationReminderDto(
        medicineName: nameController.text,
        dosage: dosageController.text,
        frequency: selectedFrequency.value,
        startDate: startDate,
        endDate: selectedEndDate.value,
        reminderTime: formattedTime,
        note: noteController.text,
        isActive: isActive.value,
      );

      // 3. Thực hiện Create hoặc Update
      if (isEditMode.value && recordId != null) {
        // UPDATE
        await service.updateMedication(recordId!, dto);
        Get.snackbar("Thành công", "Đã cập nhật nhắc nhở thuốc",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // CREATE
        await service.createMedication(dto);
        Get.snackbar("Thành công", "Đã thêm nhắc nhở thuốc mới",
            snackPosition: SnackPosition.BOTTOM);
      }

      // 4. Cập nhật danh sách trên trang chính và đóng trang chi tiết
      // Giả định MedicationController đã được Get.put() trên MedicationPage
      Get.find<MedicationController>().fetchMedications();
      Get.back(result: true); // Trả về true báo hiệu cần refresh
    } catch (e) {
      Get.snackbar("Lỗi Lưu", "Lỗi khi lưu thuốc: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ===============================================
  // HÀM HELPER VÀ FORMAT
  // ===============================================

  // Chuyển đổi TimeOnly (string HH:MM:SS) sang TimeOfDay
  TimeOfDay _parseTimeOnly(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  // Định dạng ngày hiển thị
  String formatDisplayDate(DateTime? dateTime) {
    if (dateTime == null) return "Chưa chọn";
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }
}

// ⚠️ Bạn cần đảm bảo các DTO/Model (MedicationReminder, CreateMedicationReminderDto) 
// được định nghĩa trong file Medication.dart hoặc tương đương để Controller này hoạt động.