import 'package:dacn_app/controller/AddFoodController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFoodPage extends StatelessWidget {
  // 💡 Tạo Constructor để có thể nhận Food object nếu muốn dùng cho chỉnh sửa
  // final Food? foodToEdit;
  const AddFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(AddFoodController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'Thêm món ăn mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // --- Nút LƯU ---
      bottomNavigationBar: Obx(() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                  controller.isSaving.value ? "Đang lưu..." : "Lưu món ăn",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: controller.isSaving.value ? null : controller.saveFood,
            ),
          )),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Tên và Barcode ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildInput(Icons.label, "Tên món ăn (Bắt buộc)",
                        controller.foodNameController),
                    const Divider(height: 1, indent: 40),
                    _buildInput(Icons.qr_code, "Mã Barcode (Tùy chọn)",
                        controller.barcodeController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Thông tin dinh dưỡng cơ bản ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildInput(Icons.local_fire_department,
                        "Calo / 100g (Bắt buộc)", controller.caloriesController,
                        isNumeric: true),
                    const Divider(height: 1, indent: 40),
                    _buildInput(Icons.straighten, "Khẩu phần (Ví dụ: 100 g)",
                        controller.servingSizeController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Thông tin dinh dưỡng chi tiết ---
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 4),
              child: Text("Macronutrients (Mỗi 100g):",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: _buildSmallInput(
                            "Protein (g)", controller.proteinController)),
                    const VerticalDivider(),
                    Expanded(
                        child: _buildSmallInput(
                            "Carb (g)", controller.carbsController)),
                    const VerticalDivider(),
                    Expanded(
                        child: _buildSmallInput(
                            "Fat (g)", controller.fatController)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Loại món ăn (Type) ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Loại món ăn",
                        prefixIcon:
                            Icon(Icons.fastfood, color: Color(0xFF4CAF50)),
                        border: InputBorder.none,
                      ),
                      value: controller.selectedType.value,
                      items: controller.foodTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.selectedType.value = newValue;
                        }
                      },
                    )),
              ),
            ),
            const SizedBox(height: 20),

            // --- Hướng dẫn (Instructions) ---
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 4),
              child: Text("Hướng dẫn/Công thức:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: controller.instructionsController,
                  decoration: const InputDecoration(
                    labelText: "Nhập hướng dẫn hoặc ghi chú...",
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- Các Widget Con ---
  Widget _buildInput(IconData icon, String label, TextEditingController c,
      {bool isNumeric = false}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        labelText: label,
        border: InputBorder.none,
      ),
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
    );
  }

  Widget _buildSmallInput(String label, TextEditingController c) {
    return TextField(
      controller: c,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: InputBorder.none,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
