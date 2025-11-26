import 'package:dacn_app/controller/MedicationDetailController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:intl/intl.dart'; // Cần intl cho date/time picker

// Thay thế StatelessWidget bằng GetView
class MedicationDetailPage extends GetView<MedicationDetailController> {
  const MedicationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller và xử lý tham số ID (nếu có)
    final int? medicationId = Get.arguments;
    // Khởi tạo Controller và gọi initForm ngay lập tức.
    Get.put(MedicationDetailController()).initForm(medicationId);

    // Sử dụng Get.find() hoặc controller (vì đây là GetView) để truy cập
    final controller = Get.find<MedicationDetailController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        // 💡 Dùng Obx để cập nhật tiêu đề động
        title: Obx(() => Text(
              controller.isEditMode.value ? "Sửa nhắc nhở" : "Thêm nhắc nhở",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // 💡 Nút xóa chỉ hiển thị ở chế độ Edit
          Obx(() {
            if (controller.isEditMode.value) {
              return IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                onPressed: () {
                  // Hiển thị dialog xác nhận trước khi xóa
                  Get.defaultDialog(
                    title: "Xác nhận xóa",
                    middleText: "Bạn có chắc chắn muốn xóa nhắc nhở này?",
                    textConfirm: "Xóa",
                    textCancel: "Hủy",
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () {
                      if (controller.recordId != null) {
                        Get.back(); // Đóng dialog
                        // Controller.deleteMedication sẽ gọi Get.back(result: true)
                      }
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      // Dùng Obx để hiển thị loading hoặc form
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 🧾 Nhập tên thuốc & Thời gian nhắc
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 💊 Tên thuốc
                      TextField(
                        controller: controller.nameController,
                        decoration: const InputDecoration(
                          labelText: "Tên thuốc",
                          prefixIcon: Icon(Icons.medication_outlined),
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(),
                      // ⏰ Thời gian nhắc nhở
                      _buildTimePickerTile(context, controller),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🗓 Ngày bắt đầu & Ngày kết thúc
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Ngày bắt đầu (Bắt buộc)
                    _buildDatePickerTile(
                      context,
                      controller,
                      title: "Ngày bắt đầu",
                      currentDate: controller.selectedStartDate.value,
                      onDatePicked: (date) =>
                          controller.selectedStartDate.value = date,
                      isMandatory: true,
                    ),
                    const Divider(height: 1),
                    // Ngày kết thúc (Tùy chọn)
                    _buildDatePickerTile(
                      context,
                      controller,
                      title: "Ngày kết thúc (Không bắt buộc)",
                      currentDate: controller.selectedEndDate.value,
                      onDatePicked: (date) =>
                          controller.selectedEndDate.value = date,
                      onLongPress: () =>
                          controller.selectedEndDate.value = null,
                      isMandatory: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🍽 Hướng dẫn (Frequency) và Liều lượng (Dosage)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Hướng dẫn (Frequency)
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: controller.selectedFrequency.value,
                          decoration: const InputDecoration(
                            labelText: "Hướng dẫn",
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: "before", child: Text("Trước bữa ăn")),
                            DropdownMenuItem(
                                value: "after", child: Text("Sau bữa ăn")),
                            DropdownMenuItem(
                                value: "bed", child: Text("Trước khi ngủ")),
                            DropdownMenuItem(
                                value: "other", child: Text("Khác")),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              controller.selectedFrequency.value = v;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Liều lượng & Đơn vị
                      Expanded(
                        child: TextField(
                          controller: controller.dosageController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "Liều lượng & Đơn vị",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 📝 Ghi chú
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: controller.noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Ghi chú",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🟢 Trạng thái Hoạt động
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kích hoạt nhắc nhở",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Switch(
                        value: controller.isActive.value,
                        onChanged: (bool value) {
                          controller.isActive.value = value;
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              // Loại bỏ phần "Lặp lại" vì API DTO không hỗ trợ logic này
              // const SizedBox(height: 10),
              // Card(...),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: controller.saveMedication, // Gắn hàm lưu
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }

  // Widget riêng cho Time Picker
  Widget _buildTimePickerTile(
      BuildContext context, MedicationDetailController controller) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: controller.selectedReminderTime.value,
        );
        if (pickedTime != null) {
          controller.selectedReminderTime.value = pickedTime;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.access_time_outlined, size: 20),
            const SizedBox(width: 10),
            const Text(
              "Thời gian nhắc:",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Spacer(),
            Text(
              controller.selectedReminderTime.value.format(context),
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  // Widget riêng cho Date Picker
  Widget _buildDatePickerTile(
    BuildContext context,
    MedicationDetailController controller, {
    required String title,
    required DateTime? currentDate,
    required Function(DateTime) onDatePicked,
    VoidCallback? onLongPress,
    bool isMandatory = false,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: currentDate ?? DateTime.now(),
          firstDate: isMandatory
              ? DateTime(2000)
              : DateTime(2000), // Cho phép chọn quá khứ nếu là EndDate
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDatePicked(pickedDate);
        }
      },
      onLongPress: onLongPress, // Cho phép xóa ngày nếu là EndDate
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 20),
            const SizedBox(width: 10),
            Text(
              "$title${isMandatory ? ' *' : ''}:",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Spacer(),
            Text(
              currentDate != null
                  ? DateFormat('dd-MM-yyyy').format(currentDate)
                  : "Không chọn",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color:
                      currentDate != null ? Colors.grey.shade800 : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
