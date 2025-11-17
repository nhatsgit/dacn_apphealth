import 'package:dacn_app/controller/OverviewController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller
    final OverviewController controller = Get.put(OverviewController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          'Tổng Quan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thanh ngày (ĐÃ SỬA: Sử dụng Obx và gắn hàm chuyển ngày)
          Container(
            color: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 16),
                    onPressed:
                        controller.goToPreviousDay, // Gắn hàm chuyển lùi ngày
                  ),
                  Text(
                    controller.formattedDateText, // Hiển thị tên ngày động
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      // Mờ đi và vô hiệu hóa nếu là ngày hôm nay
                      color: controller.isTodaySelected
                          ? Colors.white54
                          : Colors.white,
                      size: 16,
                    ),
                    onPressed: controller.isTodaySelected
                        ? null
                        : controller.goToNextDay, // Gắn hàm chuyển tiến ngày
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách các thẻ thông tin (SỬA: Gắn dữ liệu động)
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
              }

              if (controller.userOverview.value == null ||
                  controller.idealStats.value == null) {
                return const Center(
                    child: Text("Không có dữ liệu tổng quan cho ngày này."));
              }

              final overview = controller.userOverview.value!;
              final ideal = controller.idealStats.value!;

              return ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  // Cân nặng
                  _InfoCard(
                    icon: Icons.monitor_weight_outlined,
                    title:
                        '${overview.latestWeight != null ? overview.latestWeight!.toStringAsFixed(1) : 'N/A'} kg',
                    subtitle:
                        'Mục tiêu: ${ideal.idealWeight.toStringAsFixed(1)} kg',
                    rightText: '',
                    progress: null,
                  ),

                  // Nước
                  _InfoCard(
                    icon: Icons.local_drink_outlined,
                    title:
                        '${(overview.waterToday / 1000).toStringAsFixed(1)} Litre',
                    subtitle:
                        'Mục tiêu: ${(ideal.idealWaterMl / 1000).toStringAsFixed(1)} Lít',
                    rightText:
                        'Còn lại: ${((ideal.idealWaterMl - overview.waterToday).toDouble() / 1000).toStringAsFixed(1)} Lít',
                    progress: controller.waterProgress,
                  ),

                  // Calories In (Ăn vào)
                  _InfoCard(
                    icon: Icons.restaurant_menu_outlined,
                    title:
                        '${overview.caloriesInToday.toStringAsFixed(0)} Kcal',
                    subtitle:
                        'Mục tiêu: ${ideal.idealCaloriesIn.toStringAsFixed(0)} Kcal',
                    rightText:
                        'Còn lại: ${(ideal.idealCaloriesIn - overview.caloriesInToday).toStringAsFixed(0)}',
                    progress: controller.caloriesInProgress,
                  ),

                  // Calories Out (Đốt cháy)
                  _InfoCard(
                    icon: Icons.local_fire_department_outlined,
                    title:
                        '${overview.caloriesOutToday.toStringAsFixed(0)} Kcal',
                    subtitle:
                        'Mục tiêu: ${ideal.idealCaloriesOut.toStringAsFixed(0)} Kcal',
                    rightText:
                        'Còn lại: ${(ideal.idealCaloriesOut - overview.caloriesOutToday).toStringAsFixed(0)}',
                    progress: controller.caloriesOutProgress,
                  ),

                  // Giấc ngủ
                  _InfoCard(
                    icon: Icons.bedtime_outlined,
                    title:
                        '${overview.sleepHoursToday.toStringAsFixed(1)} Hours',
                    subtitle: '',
                    rightText: '',
                    progress: null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Giữ nguyên _InfoCard và đã thêm hỗ trợ hiển thị subtitle
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String rightText;
  final double? progress;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rightText,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (rightText.isNotEmpty)
                  Text(
                    rightText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
