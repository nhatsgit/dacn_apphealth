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
            // CẬP NHẬT: DrawerHeader sử dụng dữ liệu động
            Obx(() {
              final profile = controller.userProfile.value; //
              final isLoading = controller.isLoadingProfile.value;

              Widget headerContent;
              if (isLoading) {
                // Hiển thị loading
                headerContent = const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                );
              } else if (profile != null) {
                // Hiển thị thông tin hồ sơ
                headerContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tài Khoản: ${profile.fullName}', //
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Giới tính: ${profile.gender ?? 'N/A'}', //
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      'Chiều cao: ${profile.height != null ? '${profile.height!.toStringAsFixed(0)} cm' : 'N/A'}', //
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      'BMI: ${profile.bmi != null ? profile.bmi!.toStringAsFixed(1) : 'N/A'}', //
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                );
              } else {
                // Thông báo lỗi/không có dữ liệu
                headerContent = const Text(
                  'Tài Khoản: Không thể tải hồ sơ',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                );
              }

              return DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                ),
                child: headerContent,
              );
            }),

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
            // 🏋️ Thể dục
            Obx(() => ListTile(
                  leading: const Icon(Icons.fitness_center_outlined),
                  title: const Text('Các bài tập'),
                  selected: controller.selectedIndex.value == 4,
                  onTap: () {
                    controller.updateIndex(4);
                    Navigator.pop(context);
                  },
                )),
            Obx(() => ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text('Kế hoạch thể dục'),
                  selected: controller.selectedIndex.value == 6,
                  onTap: () {
                    controller.updateIndex(6);
                    Navigator.pop(context);
                  },
                )),
            // 🍽️ Bữa Ăn
            Obx(() => ListTile(
                  leading: const Icon(Icons.food_bank_outlined),
                  title: const Text('Danh sách món ăn'),
                  selected: controller.selectedIndex.value == 7,
                  onTap: () {
                    controller.updateIndex(7);
                    Navigator.pop(context);
                  },
                )),
            Obx(() => ListTile(
                  leading: const Icon(Icons.dining_sharp),
                  title: const Text('Bữa Ăn'),
                  selected: controller.selectedIndex.value == 9,
                  onTap: () {
                    controller.updateIndex(9);
                    Navigator.pop(context);
                  },
                )),

            // 📝 Hàng ngày

            // 💊 Uống thuốc
            Obx(() => ListTile(
                  leading: const Icon(Icons.medication),
                  title: const Text('Uống thuốc'),
                  selected: controller.selectedIndex.value == 5,
                  onTap: () {
                    controller.updateIndex(5);
                    Navigator.pop(context);
                  },
                )),
            Obx(() => ListTile(
                  leading: const Icon(Icons.account_box_sharp),
                  title: const Text('Tài khoản'),
                  selected: controller.selectedIndex.value == 8,
                  onTap: () {
                    controller.updateIndex(8);
                    Navigator.pop(context);
                  },
                )),

            const Divider(),

            // 🚪 Đăng xuất
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                // 💡 Gọi hàm logout từ Controller
                controller.logout();
                // Không cần Navigator.pop(context) vì Get.offAll sẽ tự động chuyển trang
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
