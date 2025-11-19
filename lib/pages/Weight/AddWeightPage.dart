import 'package:dacn_app/controller/AddWeightController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Đảm bảo import controller của bạn
// import 'package:dacn_app/controllers/AddWeightController.dart';

// Dùng StatelessWidget và Get.put
class AddWeightPage extends StatelessWidget {
  // Khởi tạo Controller
  final AddWeightController controller = Get.put(AddWeightController());

  AddWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thêm Hồ Sơ Cân Nặng"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () => controller.isLoading.value &&
                controller.previousWeight.value == 0.0
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Cân nặng mới (editable) ---
                    _WeightInputCard(
                      label: 'Cân nặng mới',
                      controller: controller.newWeightController,
                      unit: controller.unit.value,
                      onUnitChanged: controller.updateUnit,
                    ),

                    // --- 2. Cân nặng trước (readonly) ---
                    // Hiển thị giá trị từ Controller
                    _ReadOnlyWeightCard(
                      label: 'Cân nặng trước',
                      value: controller.previousWeight.value.toStringAsFixed(1),
                      unit: controller.unit.value,
                    ),

                    const SizedBox(height: 10),

                    // --- 3. Date & Time row ---
                    Row(
                      children: [
                        Expanded(
                          child: _DateTimeCard(
                            icon: Icons.calendar_today,
                            text: DateFormat('dd-MM-yyyy')
                                .format(controller.selectedDate.value),
                            onTap: () => controller.pickDate(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DateTimeCard(
                            icon: Icons.access_time,
                            // Định dạng giờ:phút, thêm Obx để cập nhật
                            text:
                                "${controller.selectedTime.value.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value.minute.toString().padLeft(2, '0')}",
                            onTap: () => controller.pickTime(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // --- 4. Notes ---
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Ghi chú",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: controller.noteController,
                              decoration: const InputDecoration(
                                hintText: "Nhập ghi chú (tùy chọn)",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 70),
                  ],
                ),
              ),
      ),

      // ✅ Nút Lưu (floating bottom)
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          backgroundColor: const Color(0xFF4CAF50),
          // Vô hiệu hóa nút khi đang loading
          onPressed:
              controller.isLoading.value ? null : controller.saveWeightRecord,
          label: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Lưu Hồ Sơ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
          icon: controller.isLoading.value
              ? null
              : const Icon(Icons.check, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// =======================================================
//                   REUSABLE WIDGETS
// =======================================================

class _WeightInputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final Function(String?) onUnitChanged;

  const _WeightInputCard({
    required this.label,
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.monitor_weight_outlined, color: Color(0xFF4CAF50)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  labelStyle: const TextStyle(color: Colors.black54),
                ),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: unit,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'kg', child: Text('kg')),
                DropdownMenuItem(value: 'lbs', child: Text('lbs')),
              ],
              onChanged: onUnitChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyWeightCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _ReadOnlyWeightCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // Hiển thị '--' nếu giá trị là 0.0 hoặc null
    final displayValue = value == '0.0' ? '--' : value;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey[200], // Thẻ chỉ đọc
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    displayValue,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              unit,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _DateTimeCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
