import 'package:dacn_app/controller/WeightController.dart';
import 'package:dacn_app/pages/Weight/AddWeightPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 💡 Import GetX

class WeightPage extends StatelessWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller
    final controller = Get.put(WeightController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Weight Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
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

      // Thân trang (SỬ DỤNG OBX ĐỂ THEO DÕI TRẠNG THÁI)
      body: Obx(() {
        if (controller.isLoading.value && controller.weightRecords.isEmpty) {
          // ⚠️ Hiển thị loading khi đang tải lần đầu
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }

        if (controller.weightRecords.isEmpty) {
          // ⚠️ Hiển thị khi không có dữ liệu
          return const Center(
            child: Text("Chưa có hồ sơ cân nặng. Hãy thêm hồ sơ mới!"),
          );
        }

        final records = controller.weightRecords;

        // Logic tính toán Icon Xu hướng (chỉ cho bản ghi mới nhất)
        IconData? trendIcon;
        Color trendColor = Colors.grey;
        if (records.length >= 2) {
          final latestWeight = records.first.weight;
          final previousWeight = records[1].weight;
          if (latestWeight > previousWeight) {
            trendIcon = Icons.trending_up;
            trendColor = Colors.redAccent; // Tăng cân
          } else if (latestWeight < previousWeight) {
            trendIcon = Icons.trending_down;
            trendColor = Colors.green; // Giảm cân
          } else {
            trendIcon = Icons.trending_flat;
            trendColor = Colors.blueGrey; // Giữ nguyên
          }
        }

        return Column(
          children: [
            // 🟩 Card thống kê (ĐỔ DỮ LIỆU ĐỘNG)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                      label: 'Minimum',
                      value:
                          '${controller.minWeight.value.toStringAsFixed(1)} kg'),
                  _StatItem(
                      label: 'Maximum',
                      value:
                          '${controller.maxWeight.value.toStringAsFixed(1)} kg'),
                  _StatItem(
                      label: 'Average',
                      value:
                          '${controller.avgWeight.value.toStringAsFixed(1)} kg'),
                  _StatItem(
                      label: 'Ideal weight',
                      value:
                          '${controller.idealWeight.value.toStringAsFixed(1)} kg'),
                ],
              ),
            ),

            // 🔸 Tabs: HISTORY / TRENDS (giữ nguyên)
            Container(
              color: Colors.green,
              child: const DefaultTabController(
                length: 2,
                child: TabBar(
                  indicatorColor: Colors.orange,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'HISTORY'),
                    Tab(text: 'TRENDS'),
                  ],
                ),
              ),
            ),

            // 📋 Danh sách lịch sử (ĐỔ DỮ LIỆU TỪ CONTROLLER)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _WeightCard(
                    date: controller.formatWeightDate(record.date),
                    bmi: record.bmi.toStringAsFixed(1),
                    weight: record.weight.toStringAsFixed(1),
                    note: record.note, // ✅ TRUYỀN NOTE
                    // Chỉ truyền icon xu hướng cho bản ghi mới nhất (index == 0)
                    trendIcon: index == 0 ? trendIcon : null,
                    trendColor: index == 0 ? trendColor : Colors.transparent,
                  );
                },
              ),
            ),
          ],
        );
      }),

      // ➕ Nút thêm
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          // 1. Dùng await Get.to() để chuyển trang và chờ kết quả
          final result = await Get.to(
            () => AddWeightPage(),
            // Truyền arguments nếu cần (ví dụ: cân nặng gần nhất)
            arguments: controller.weightRecords.isNotEmpty
                ? controller.weightRecords.first.weight
                : null,
          );

          // 2. Kiểm tra kết quả trả về. Nếu là true, gọi hàm tải lại.
          if (result == true) {
            // Hàm này sẽ tải lại danh sách cân nặng và cập nhật UI
            controller.fetchWeights();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Widget con hiển thị chỉ số (giữ nguyên)
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }
}

// Widget thẻ lịch sử cân nặng (ĐÃ SỬA để nhận IconData cho xu hướng)
class _WeightCard extends StatelessWidget {
  final String date;
  final String weight;
  final String bmi;
  final String? note; // ✅ THÊM NOTE
  final IconData? trendIcon;
  final Color? trendColor;

  const _WeightCard({
    required this.date,
    required this.weight,
    required this.bmi,
    this.note, // ✅ THÊM NOTE
    this.trendIcon,
    this.trendColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('BMI $bmi',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),

                // 📝 HIỂN THỊ GHI CHÚ
                if (note != null && note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.45, // Giới hạn chiều rộng
                    child: Text('Ghi chú: $note', // ✅ VIỆT HÓA VÀ HIỂN THỊ NOTE
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(weight,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 28)),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text('kg',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                ),
                // HIỂN THỊ ICON XU HƯỚNG
                if (trendIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Icon(trendIcon, color: trendColor, size: 18),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
