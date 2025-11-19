// File: lib/pages/Auth/UpdateInfoPage.dart (hoặc đường dẫn thích hợp)

import 'package:dacn_app/controller/UpdateInfoController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateInfoPage extends StatelessWidget {
  const UpdateInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller
    final controller = Get.put(UpdateInfoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tài Khoản',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        backgroundColor: Colors.green,
        actions: const [
          Icon(Icons.edit),
          SizedBox(width: 10),
          Icon(Icons.share),
          SizedBox(width: 10),
          Icon(Icons.local_drink_outlined),
          SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
        }

        final profile = controller.userProfile.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tên đầy đủ
              _buildTextField(
                controller: controller.fullNameController,
                label: 'Tên đầy đủ',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Giới tính (Sử dụng Dropdown cho UX tốt hơn)
              _buildGenderDropdown(controller),
              const SizedBox(height: 16),

              // Ngày sinh
              _buildTextField(
                controller: controller.dateOfBirthController,
                label: 'Ngày sinh (YYYY-MM-DD)',
                icon: Icons.calendar_today,
                readOnly:
                    true, // Không cho sửa trực tiếp, dùng Date Picker nếu cần
                onTap: () async {
                  // TODO: Triển khai DatePicker nếu cần cho việc cập nhật ngày sinh
                },
              ),
              const SizedBox(height: 16),

              // Chiều cao
              _buildTextField(
                controller: controller.heightController,
                label: 'Chiều cao (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                suffixText: 'cm',
              ),
              const SizedBox(height: 16),

              // Cân nặng gần nhất
              _buildTextField(
                controller: controller.latestWeightController,
                label: 'Cân nặng gần nhất (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                suffixText: 'kg',
              ),
              const SizedBox(height: 16),

              // BMI (Chỉ hiển thị)
              Text(
                'Chỉ số BMI: ${profile?.bmi?.toStringAsFixed(2) ?? 'N/A'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Nút Cập nhật
              ElevatedButton(
                onPressed: controller.updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cập Nhật Thông Tin',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Widget Helper cho TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? suffixText,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        suffixText: suffixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Widget Helper cho Dropdown Giới tính
  Widget _buildGenderDropdown(UpdateInfoController controller) {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedGender.value,
          decoration: InputDecoration(
            labelText: 'Giới tính',
            prefixIcon:
                const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: controller.genders
              .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
              .toList(),
          onChanged: (newValue) {
            controller.selectedGender.value = newValue;
          },
        ));
  }
}
