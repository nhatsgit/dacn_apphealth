// File: lib/pages/SleepPage.dart (Sử dụng Controller)

import 'package:dacn_app/controller/SleepController.dart';
import 'package:dacn_app/models/Sleep.dart';
import 'package:dacn_app/pages/Sleep/AddSleepPage.dart'; // Giả định
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Chuyển từ StatefulWidget sang StatelessWidget để dùng GetX Controller
class SleepPage extends StatelessWidget {
  const SleepPage({Key? key}) : super(key: key);

  // Định dạng Duration từ phút thành chuỗi "8h 0phút"
  String formatDuration(int durationMinutes) {
    if (durationMinutes <= 0) return '0h 0phút';
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes}phút';
  }

  // Định dạng DateTime thành chuỗi "Thứ Ba, 17/10 23:00"

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final SleepController controller = Get.put(SleepController());

    // Cần 1 TabController cục bộ cho TabBarView
    // Ta bọc toàn bộ nội dung trong DefaultTabController
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            'Theo Dõi Giấc Ngủ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () async {
                // Điều hướng đến trang thêm, và tải lại dữ liệu khi quay về
                final result = await Get.to(() =>
                    const AddSleepPage()); // Giả định AddSleepPage tồn tại
                if (result == true) {
                  controller.fetchSleepRecords();
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Lịch Sử", icon: Icon(Icons.list)),
              Tab(text: "Xu Hướng", icon: Icon(Icons.bar_chart)),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),

        // 🔑 Body dùng controller.obx để xử lý trạng thái tải/lỗi
        body: TabBarView(
          children: [
            // Tab 1: Lịch Sử
            controller.obx(
              (records) => _buildRecordsList(controller, records!),
              onLoading: const Center(child: CircularProgressIndicator()),
              onError: (error) => Center(
                child: Text('Lỗi tải dữ liệu: $error \n Kéo xuống để tải lại.',
                    textAlign: TextAlign.center),
              ),
              onEmpty: const Center(
                child: Text(
                    'Chưa có hồ sơ giấc ngủ nào. Hãy thêm một bản ghi mới!'),
              ),
            ),

            // Tab 2: Xu Hướng (giữ nguyên mẫu)
            _buildTrendsTab(controller),
          ],
        ),
      ),
    );
  }

  // ===============================================
  // CÁC WIDGET CON ĐƯỢC CẬP NHẬT
  // ===============================================

  Widget _buildRecordsList(
      SleepController controller, List<SleepRecord> records) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchSleepRecords(),
      child: ListView(
        children: [
          _buildStatsCard(controller),

          ...records.map((record) {
            return _buildSleepRecordItem(
              controller: controller,
              id: record.id,
              start: record.startTime,
              end: record.endTime,
              duration: record.durationMinutes ?? 0,
              quality: record.sleepQuality ?? 'N/A',
              type: record.sleepType ?? 'N/A',
            );
          }).toList(),

          // Thêm nút tải thêm nếu có nhiều bản ghi hơn (phân trang)
          if (controller.sleepRecords.length < controller.totalRecords.value)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  final nextPage = (controller.sleepRecords.length ~/ 10) + 1;
                  controller.fetchSleepRecords(pageNumber: nextPage);
                },
                child: const Text('Tải thêm'),
              ),
            ),
        ],
      ),
    );
  }

  // Widget hiển thị thống kê
  Widget _buildStatsCard(SleepController controller) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Tổng giờ ngủ',
                        style: TextStyle(
                            color: Colors.blueGrey.shade700, fontSize: 13),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${controller.totalSleepHours.value.toStringAsFixed(1)} h',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.blueAccent),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'TB mỗi ngày',
                        style: TextStyle(
                            color: Colors.blueGrey.shade700, fontSize: 13),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatDuration(controller.avgDurationMinutes.value),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildSleepRecordItem({
    required SleepController controller,
    required int id,
    required DateTime start,
    required DateTime end,
    required int duration,
    required String quality,
    required String type,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Dismissible(
        key: ValueKey(id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) {
          return Get.defaultDialog<bool>(
            title: "Xác nhận xóa",
            middleText: "Bạn có chắc chắn muốn xóa bản ghi giấc ngủ này không?",
            textConfirm: "Xóa",
            textCancel: "Hủy",
            confirmTextColor: Colors.white,
            onConfirm: () {
              controller.deleteSleepRecord(id);
              Get.back(result: true);
            },
            onCancel: () => Get.back(result: false),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.nightlight_round, color: Colors.blueGrey),
            title: Text(
              "${start} → ${DateFormat('HH:mm').format(end)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thời lượng: ${formatDuration(duration)}"),
                  Text("Chất lượng: $quality"),
                  Text("Loại: $type"),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_filled, color: Colors.blueAccent),
                Text("${(duration / 60).toStringAsFixed(1)} h",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsTab(SleepController controller) {
    // 💡 Tại đây, bạn có thể sử dụng Obx để lấy dữ liệu thống kê từ controller
    // và vẽ biểu đồ.
    return Obx(() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Biểu đồ Xu Hướng Giấc Ngủ",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Tổng số bản ghi: ${controller.totalRecords.value}",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                "Thời gian ngủ trung bình: ${formatDuration(controller.avgDurationMinutes.value)}",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              //
            ],
          ),
        ));
  }
}
