import 'package:dacn_app/controller/MedicationController.dart';
import 'package:dacn_app/models/Medication.dart';
import 'package:dacn_app/pages/Medication/MedicationDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX

class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller và đưa vào GetX
    final controller = Get.put(MedicationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nhắc nhở uống thuốc',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade400,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, size: 26),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),

      // 💡 Sử dụng Obx để theo dõi trạng thái loading và danh sách
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.medicationRecords.isEmpty) {
          // ⚠️ Hiển thị loading khi đang tải lần đầu
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }

        if (controller.medicationRecords.isEmpty) {
          // ⚠️ Hiển thị khi không có dữ liệu
          return const Center(
            child: Text("Chưa có nhắc nhở thuốc nào. Hãy thêm hồ sơ mới!"),
          );
        }

        // Hiển thị danh sách động
        return Container(
          color: Colors.grey.shade100,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: controller.medicationRecords.length,
            itemBuilder: (context, index) {
              final record = controller.medicationRecords[index];
              return MedicationCard(
                // ✅ ÁP DỤNG DỮ LIỆU ĐỘNG TỪ MODEL
                record: record,
                controller: controller, // Truyền controller để dùng hàm format
              );
            },
          ),
        );
      }),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          // 1. Dùng await Get.to() để chuyển trang và chờ kết quả
          final result = await Get.to(() => const MedicationDetailPage());

          // 2. Kiểm tra kết quả trả về. Nếu là true, gọi hàm tải lại.
          if (result == true) {
            // Hàm này sẽ tải lại danh sách nhắc nhở thuốc và cập nhật UI
            controller.fetchMedications();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 💡 Sửa MedicationCard để nhận MedicationReminder
class MedicationCard extends StatelessWidget {
  final MedicationReminder record;
  final MedicationController controller;

  const MedicationCard({
    super.key,
    required this.record,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Thông tin hiển thị
    final String startDateStr = controller.formatDate(record.startDate);
    final String reminderTimeStr = controller.formatTime(record.reminderTime);
    // Hướng dẫn (Dosage + Frequency, nếu có)
    final String instruction =
        (record.dosage != null && record.dosage!.isNotEmpty
                ? "${record.dosage}"
                : "") +
            (record.frequency != null && record.frequency!.isNotEmpty
                ? (record.dosage != null && record.dosage!.isNotEmpty
                        ? " - "
                        : "") +
                    "${record.frequency}"
                : "");

    // Trạng thái hoạt động
    final bool isActive = record.isActive;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // 💡 Thêm màu nền dựa trên trạng thái (tùy chọn)
      color: isActive ? Colors.white : Colors.grey.shade300,
      child: ListTile(
        title: Text(
          record.medicineName, // Tên thuốc
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            // 💡 Thêm hiệu ứng gạch ngang nếu không hoạt động
            decoration:
                isActive ? TextDecoration.none : TextDecoration.lineThrough,
            color: isActive ? Colors.black : Colors.grey.shade600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 💊 Thời gian nhắc nhở
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thời gian nhắc",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        reminderTimeStr, // Thời gian (HH:mm)
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // 📅 Ngày bắt đầu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ngày bắt đầu",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        startDateStr, // Ngày bắt đầu
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  // ℹ️ Hướng dẫn
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hướng dẫn",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        instruction.isEmpty ? "Không rõ" : instruction,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),

              // 📝 Hiển thị Ghi chú (Note)
              if (record.note != null && record.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Ghi chú: ${record.note}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          // Xử lý khi nhấn vào thẻ (ví dụ: chuyển đến trang chi tiết)
          Get.to(
            () => const MedicationDetailPage(),
            arguments: record.id, // Truyền ID của bản ghi
          )?.then((result) {
            if (result == true) {
              controller.fetchMedications(); // Tải lại nếu có thay đổi
            }
          });
        },
      ),
    );
  }
}
