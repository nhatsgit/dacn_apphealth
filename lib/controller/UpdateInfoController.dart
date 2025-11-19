// File: lib/controllers/UpdateInfoController.dart (hoặc đường dẫn tương tự)

import 'package:dacn_app/controller/MainPageController.dart';
import 'package:dacn_app/models/UserProfile.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:dacn_app/services/UserServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UpdateInfoController extends GetxController {
  // Trạng thái loading
  var isLoading = true.obs;

  // Biến giữ dữ liệu UserProfile
  var userProfile = Rxn<UserProfile>();

  // Controllers cho các ô nhập liệu
  final fullNameController = TextEditingController();
  final genderController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final heightController = TextEditingController();
  final latestWeightController = TextEditingController();
  // BMI sẽ được tính toán hoặc hiển thị, không cần controller nhập liệu

  // Biến giữ giới tính đang chọn cho Dropdown
  var selectedGender = Rxn<String>();
  final List<String> genders = [
    'Male',
    'Female',
    'Other'
  ]; // Tùy chỉnh theo API

  @override
  void onInit() {
    super.onInit();
    fetchAndPopulateProfile();
  }

  // Giải phóng tài nguyên khi Controller bị xóa
  @override
  void onClose() {
    fullNameController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    heightController.dispose();
    latestWeightController.dispose();
    super.onClose();
  }

  // Hàm tải dữ liệu và đổ vào các ô nhập liệu
  Future<void> fetchAndPopulateProfile() async {
    try {
      isLoading(true);
      final client = HttpRequest(http.Client());
      final profile = await UserService(client).fetchProfile();
      userProfile.value = profile;

      // Đổ dữ liệu vào các TextEditingController
      fullNameController.text = profile.fullName;
      heightController.text = profile.height?.toStringAsFixed(1) ?? '';
      latestWeightController.text =
          profile.latestWeight?.toStringAsFixed(1) ?? '';

      // Thiết lập giới tính đang chọn
      if (profile.gender != null && genders.contains(profile.gender)) {
        selectedGender.value = profile.gender;
      }

      // Định dạng ngày sinh (nếu API trả về định dạng ISO 8601)
      if (profile.dateOfBirth != null) {
        // Có thể cần xử lý định dạng nếu API không trả về định dạng dễ đọc
        dateOfBirthController.text = profile.dateOfBirth!.split('T')[0];
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải thông tin hồ sơ: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProfile() async {
    // 1. Kiểm tra trạng thái
    if (isLoading.isTrue) return;
    isLoading(true); // Bắt đầu loading cho nút bấm

    // 2. Thu thập dữ liệu
    final fullName = fullNameController.text.trim();
    final dateOfBirth = dateOfBirthController.text.trim();
    final height = double.tryParse(heightController.text.trim());
    final gender = selectedGender.value;

    // 3. Gọi Service API
    try {
      final client = HttpRequest(http.Client());
      await UserService(client).updateProfile(
        fullName: fullName,
        gender: gender,
        dateOfBirth: dateOfBirth.isNotEmpty ? dateOfBirth : null,
        height: height,
        // Cân nặng (latestWeight) không được gửi, vì nó được cập nhật qua API riêng
      );

      // 4. Cập nhật thành công
      Get.snackbar("Thành công", "Thông tin đã được cập nhật!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      // Cập nhật lại profile trên MainPage Controller (nếu có)
      // Giả định MainPageController đã được Get.put()
      if (Get.isRegistered<MainPageController>()) {
        Get.find<MainPageController>().fetchUserProfile();
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Cập nhật thất bại: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}
