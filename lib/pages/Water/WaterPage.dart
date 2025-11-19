// File: lib/pages/WaterPage.dart

import 'package:dacn_app/controller/WaterController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterPage extends StatelessWidget {
  const WaterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 💡 Khởi tạo Controller (Dependency Injection)
    final controller = Get.put(WaterController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Theo Dõi Nước',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        backgroundColor: Colors.green,
        actions: const [
          Icon(Icons.edit, color: Colors.white),
          SizedBox(width: 10),
          Icon(Icons.share, color: Colors.white),
          SizedBox(width: 10),
          Icon(Icons.local_drink_outlined, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),

      // 🔑 Sử dụng controller.obx để xử lý các trạng thái: Loading, Success, Error
      body: controller.obx(
        // === Trạng thái Success: Hiển thị giao diện chính khi dữ liệu đã sẵn sàng ===
        (state) => Column(
          children: [
            // --- Header card ---
            _buildHeaderCard(controller),
            // --- Water fill area ---
            Expanded(child: _buildWaterFillArea(context, controller)),
            // --- Bottom buttons ---
            _buildBottomButtons(controller),
          ],
        ),

        // === Trạng thái Loading ===
        onLoading:
            const Center(child: CircularProgressIndicator(color: Colors.blue)),

        // === Trạng thái Error ===
        onError: (error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  'Lỗi tải dữ liệu: ${error ?? 'Không rõ'} \nVui lòng thử lại!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.fetchTodayWaterRecord(),
                  child: const Text('Tải lại'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Các Widget con (nhận Controller) ---

  Widget _buildHeaderCard(WaterController controller) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Text("Mục tiêu nước",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 5),
                // ✅ HIỂN THỊ MỤC TIÊU TỪ CONTROLLER
                Obx(() => Text(
                    "${controller.goalIntake.value.toStringAsFixed(2)} Lít",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            Column(
              children: [
                const Text("Tỷ lệ hoàn thành",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 5),
                // ✅ HIỂN THỊ PHẦN TRĂM HOÀN THÀNH
                Obx(() {
                  // Chuyển từ fillPercent (0.0 - 1.0) sang %
                  final percent =
                      (controller.fillPercent.value * 100).toStringAsFixed(0);
                  // Màu sắc thay đổi khi đạt 100%
                  final color = controller.fillPercent.value >= 1.0
                      ? Colors.blue
                      : Colors.green;
                  return Text("$percent %",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color));
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWaterFillArea(BuildContext context, WaterController controller) {
    return Obx(() {
      final fillHeight = controller.fillPercent.value;
      final remainingLiter = controller.remaining.value;
      final totalLiter = controller.totalIntake.value;

      return Center(
        child: Container(
          width: 400,
          height: 600,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Hiển thị Lượng nước đã uống
                    FractionallySizedBox(
                      heightFactor: fillHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                            topLeft: fillHeight >= 1.0
                                ? const Radius.circular(12)
                                : Radius.zero,
                            topRight: fillHeight >= 1.0
                                ? const Radius.circular(12)
                                : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                    // Hiển thị Text
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 10, right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Đã uống:',
                            style: TextStyle(
                                fontSize: 14,
                                color: fillHeight > 0.5
                                    ? Colors.white
                                    : Colors.black54),
                          ),
                          Text(
                            '${totalLiter.toStringAsFixed(2)} Lít',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: fillHeight > 0.5
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (fillHeight < 1.0)
                            Text(
                              'Còn lại: ${remainingLiter.toStringAsFixed(2)} Lít',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: fillHeight > 0.5
                                      ? Colors.white70
                                      : Colors.redAccent),
                            ),
                          if (fillHeight >= 1.0)
                            const Text(
                              'Tuyệt vời! Đã đạt mục tiêu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomButtons(WaterController controller) {
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _waterButton(controller, "180 ml", 0.18),
          _waterButton(controller, "350 ml", 0.35),
          _waterButton(controller, "500 ml", 0.5),
          _waterButton(controller, "1000 ml", 1.0),
        ],
      ),
    );
  }

  Widget _waterButton(WaterController controller, String label, double amount) {
    return GestureDetector(
      // ✅ GỌI addWater CỦA CONTROLLER VỚI LƯỢNG NƯỚC (Lít)
      onTap: () async {
        await controller.addWater(amount);
      },
      child: Column(
        children: [
          Icon(Icons.local_drink, color: Colors.blue[700], size: 30),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}
