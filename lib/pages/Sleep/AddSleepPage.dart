// File: lib/pages/Sleep/AddSleepPage.dart (Áp dụng Controller)

import 'package:dacn_app/controller/AddSleepController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddSleepPage extends StatelessWidget {
  const AddSleepPage({Key? key}) : super(key: key);

  // Định dạng Duration từ phút thành chuỗi "8h 0phút"
  String formatDuration(int durationMinutes) {
    if (durationMinutes <= 0) return 'N/A';
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes}phút';
  }

  // Hàm chọn thời gian
  Future<void> pickTime(
      BuildContext context, AddSleepController controller, bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: isStart
          ? controller.startTime.value ?? now
          : controller.endTime.value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selectedDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    if (isStart) {
      controller.startTime.value = selectedDateTime;
    } else {
      controller.endTime.value = selectedDateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(AddSleepController());

    // Gán giá trị ban đầu cho notesController
    final notesController = TextEditingController(text: controller.notes.value);

    // 💡 Lắng nghe sự thay đổi của textfield và cập nhật controller
    notesController.addListener(() {
      controller.notes.value = notesController.text;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm Hồ Sơ Giấc Ngủ",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THỜI GIAN BẮT ĐẦU VÀ KẾT THÚC ---
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildTimePicker(
                        context,
                        controller,
                        isStart: true,
                        label: "Bắt đầu",
                        time: controller.startTime.value,
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => _buildTimePicker(
                        context,
                        controller,
                        isStart: false,
                        label: "Kết thúc",
                        time: controller.endTime.value,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- THỜI LƯỢNG VÀ THÔNG TIN KHÁC ---
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _infoCard("Thời lượng",
                        formatDuration(controller.durationMinutes.value)),
                  ],
                )),
            const SizedBox(height: 20),

            // --- CHẤT LƯỢNG NGỦ VÀ LOẠI NGỦ ---
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildDropdown(
                        label: "Chất lượng ngủ",
                        value: controller.sleepQuality.value,
                        items: controller.sleepQualities,
                        onChanged: (val) => controller.sleepQuality.value = val,
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => _buildDropdown(
                        label: "Loại ngủ",
                        value: controller.sleepType.value,
                        items: controller.sleepTypes,
                        onChanged: (val) => controller.sleepType.value = val,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- GHI CHÚ ---
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: _inputDecoration("Ghi chú"),
            ),
            const SizedBox(height: 30),

            // --- NÚT LƯU ---
            Obx(() => ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check, color: Colors.white),
                  label: Text(
                      controller.isLoading.value
                          ? "Đang lưu..."
                          : "Lưu Hồ Sơ Giấc Ngủ",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  onPressed:
                      controller.isLoading.value ? null : controller.saveRecord,
                )),
          ],
        ),
      ),
    );
  }

  // --- Các Widget Con ---

  Widget _buildTimePicker(
    BuildContext context,
    AddSleepController controller, {
    required bool isStart,
    required String label,
    DateTime? time,
  }) {
    return InkWell(
      onTap: () => pickTime(context, controller, isStart),
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Row(
          children: [
            const Icon(Icons.access_time),
            const SizedBox(width: 8),
            Text(
              time != null
                  ? DateFormat('dd/MM HH:mm').format(time)
                  : 'Chọn thời gian',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
