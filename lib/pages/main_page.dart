import 'package:dacn_app/controller/MainPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatelessWidget {
  final MainPageController controller = Get.put(MainPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Drawer bên trái
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
              ),
              child: Text(
                'Tài Khoản:Nguyễn Anh Nhật',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            // 🏠 Tổng quan
            Obx(() => ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('Tổng Quan'),
                  selected: controller.selectedIndex.value == 0,
                  onTap: () {
                    controller.updateIndex(0);
                    Navigator.pop(context);
                  },
                )),

            // ⚖️ Cân nặng
            Obx(() => ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: const Text('Cân Nặng'),
                  selected: controller.selectedIndex.value == 1,
                  onTap: () {
                    controller.updateIndex(1);
                    Navigator.pop(context);
                  },
                )),

            // 💧 Uống nước
            Obx(() => ListTile(
                  leading: const Icon(Icons.local_drink_outlined),
                  title: const Text('Uống Nước'),
                  selected: controller.selectedIndex.value == 2,
                  onTap: () {
                    controller.updateIndex(2);
                    Navigator.pop(context);
                  },
                )),

            // 💤 Giấc ngủ
            Obx(() => ListTile(
                  leading: const Icon(Icons.bedtime_outlined),
                  title: const Text('Giấc Ngủ'),
                  selected: controller.selectedIndex.value == 3,
                  onTap: () {
                    controller.updateIndex(3);
                    Navigator.pop(context);
                  },
                )),
            // 💤 Giấc ngủ
            Obx(() => ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text('Thể dục'),
                  selected: controller.selectedIndex.value == 6,
                  onTap: () {
                    controller.updateIndex(6);
                    Navigator.pop(context);
                  },
                )),
            // 💤 Giấc ngủ
            Obx(() => ListTile(
                  leading: const Icon(Icons.local_dining),
                  title: const Text('Bữa Ăn'),
                  selected: controller.selectedIndex.value == 7,
                  onTap: () {
                    controller.updateIndex(7);
                    Navigator.pop(context);
                  },
                )),

            Obx(() => ListTile(
                  leading: const Icon(Icons.notes_sharp),
                  title: const Text('Hàng ngày'),
                  selected: controller.selectedIndex.value == 4,
                  onTap: () {
                    controller.updateIndex(4);
                    Navigator.pop(context);
                  },
                )),
            Obx(() => ListTile(
                  leading: const Icon(Icons.medication),
                  title: const Text('Uống thuốc'),
                  selected: controller.selectedIndex.value == 5,
                  onTap: () {
                    controller.updateIndex(5);
                    Navigator.pop(context);
                  },
                )),

            const Divider(),

            // 🚪 Đăng xuất (nếu muốn thêm)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                // TODO: xử lý logout
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // 🔸 Nội dung hiển thị
      body: SafeArea(
        child: Obx(() {
          return IndexedStack(
            index: controller.selectedIndex.value,
            children:
                controller.pages.map((page) => page ?? Container()).toList(),
          );
        }),
      ),
    );
  }
}
