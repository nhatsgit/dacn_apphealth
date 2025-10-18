import 'package:dacn_app/controller/RegisterController.dart';
import 'package:dacn_app/pages/Auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📧 Nhập Email
              Obx(() => TextField(
                    onChanged: (value) => controller.email.value = value,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: controller.emailError.value.isEmpty
                          ? null
                          : controller.emailError.value,
                    ),
                  )),

              const SizedBox(height: 16),

              // 🔒 Nhập Password
              Obx(() => TextField(
                    onChanged: (value) => controller.password.value = value,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      errorText: controller.passwordError.value.isEmpty
                          ? null
                          : controller.passwordError.value,
                    ),
                  )),

              const SizedBox(height: 16),

              // 👤 Họ tên
              TextField(
                onChanged: (value) => controller.fullName.value = value,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),

              const SizedBox(height: 16),

              // 🎂 Ngày sinh (định dạng dd-MM-yyyy)
              Obx(() {
                // Format hiển thị dd-MM-yyyy nếu có giá trị
                String displayDate = '';
                if (controller.dateOfBirth.value.isNotEmpty) {
                  try {
                    DateTime parsed =
                        DateTime.parse(controller.dateOfBirth.value);
                    displayDate = DateFormat('dd-MM-yyyy').format(parsed);
                  } catch (_) {}
                }

                return TextField(
                  readOnly: true,
                  controller: TextEditingController(text: displayDate),
                  decoration: const InputDecoration(
                    labelText: 'Ngày sinh',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      // Lưu theo dạng ISO để gửi API
                      controller.dateOfBirth.value =
                          pickedDate.toIso8601String();
                    }
                  },
                );
              }),

              const SizedBox(height: 16),

              // 🚻 Chọn giới tính
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.gender.value.isEmpty
                        ? null
                        : controller.gender.value,
                    items: const [
                      DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                      DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                      DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.gender.value = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      border: OutlineInputBorder(),
                    ),
                  )),

              const SizedBox(height: 16),

              // 📏 Nhập chiều cao (cm)
              Obx(() => TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        final heightValue = double.tryParse(value);
                        if (heightValue != null && heightValue > 0) {
                          controller.height.value = heightValue;
                        }
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Chiều cao (cm)',
                      hintText: 'Nhập chiều cao của bạn (ví dụ: 170)',
                      border: const OutlineInputBorder(),
                      errorText: controller.height.value <= 0
                          ? 'Chiều cao phải lớn hơn 0'
                          : null,
                    ),
                  )),

              const SizedBox(height: 24),

              // 🧾 Nút đăng ký
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text("Đã có tài khoản"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
