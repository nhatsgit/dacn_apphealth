import 'package:dacn_app/services/AuthServices.dart';
import 'package:dacn_app/services/HttpRequest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UpdateUserController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final fullName = ''.obs;
  final gender = ''.obs;
  final height = 0.0.obs;
  final dateOfBirth = ''.obs;

  final emailError = ''.obs;
  final passwordError = ''.obs;

  bool validateFields() {
    // Email
    emailError.value =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(email.value)
            ? ''
            : 'Email không hợp lệ';

    // Password
    passwordError.value = '';
    if (password.value.length < 6) {
      passwordError.value += 'Ít nhất 6 ký tự.\n';
    }
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(password.value)) {
      passwordError.value += 'Ít nhất 1 ký tự hoa (A-Z).\n';
    }
    if (!RegExp(r'^(?=.*\d)').hasMatch(password.value)) {
      passwordError.value += 'Ít nhất 1 ký tự số (0-9).\n';
    }
    if (!RegExp(r'^(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(password.value)) {
      passwordError.value += 'Ít nhất 1 ký tự đặc biệt.\n';
    }

    return emailError.value.isEmpty && passwordError.value.isEmpty;
  }

  Future<void> register() async {
    if (validateFields()) {
      try {
        // Hàm register trả về String message
        final message = await AuthServices(HttpRequest(http.Client())).register(
          email: email.value,
          password: password.value,
          fullName: fullName.value,
          height: height.value.toString(),
          gender: gender.value,
          dateOfBirth: dateOfBirth.value,
        );

        Get.snackbar(
          'Thành công',
          message.isNotEmpty ? message : 'Đăng ký thành công!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.3),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Đăng ký thất bại: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.3),
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Cảnh báo',
        'Vui lòng điền đầy đủ thông tin hợp lệ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.3),
        colorText: Colors.white,
      );
    }
  }
}
