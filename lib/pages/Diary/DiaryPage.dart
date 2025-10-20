import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiaryController extends GetxController {
  var selectedDate = DateTime.now().obs;
}

class DiaryPage extends StatelessWidget {
  final DiaryController controller = Get.put(DiaryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nhật ký hôm nay',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.green.shade400,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---- THỐNG KÊ CALO ----
            Container(
              color: Colors.green.shade400,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Text(
                    "Tổng quan hôm nay",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 110,
                        width: 110,
                        child: CircularProgressIndicator(
                          value: 0.7,
                          strokeWidth: 8,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const Text(
                        "1732\ncòn lại",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _StatItem(label: "Nạp", value: "610", unit: "Kcal"),
                      _StatItem(label: "Tiêu", value: "0", unit: "Kcal"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _MacroItem(label: "Chất béo", value: "24,6g"),
                      _MacroItem(label: "Tinh bột", value: "59g"),
                      _MacroItem(label: "Đạm", value: "31g"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ---- PHẦN DANH MỤC ----
            _CategorySection(
              icon: Icons.water_drop_outlined,
              title: "Uống nước",
              subtitle: "0 lít",
              trailing: "Còn 1,83 lít",
            ),
            _MealSection(
              title: "Bữa sáng",
              items: [
                MealItem(
                    name: "Gà chiên (2 miếng)",
                    sub: "Burger King",
                    quantity: "2.0 phần",
                    kcal: 224,
                    maxKcal: 400),
              ],
              totalKcal: 224,
            ),
            _MealSection(
              title: "Bữa trưa",
              items: [
                MealItem(
                    name: "Thịt bê",
                    sub: "Nạc vai",
                    quantity: "0.5 chén",
                    kcal: 210,
                    maxKcal: 400),
                MealItem(
                    name: "Cơm Jasmine",
                    sub: "Gạo Thái Lan",
                    quantity: "0.25 chén (50g)",
                    kcal: 176,
                    maxKcal: 400),
              ],
              totalKcal: 386,
            ),
            _CategorySection(
              icon: Icons.apple_outlined,
              title: "Ăn nhẹ",
              subtitle: "Khuyến nghị",
              trailing: "0 - 468 Kcal",
            ),
            _CategorySection(
              icon: Icons.dinner_dining_outlined,
              title: "Bữa tối",
              subtitle: "Khuyến nghị",
              trailing: "937 - 1288 Kcal",
            ),
            _CategorySection(
              icon: Icons.directions_run_outlined,
              title: "Hoạt động",
              subtitle: "Chưa có hoạt động nào",
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// --------------------------- //
// Các Widget phụ tá

class _StatItem extends StatelessWidget {
  final String label, value, unit;
  const _StatItem(
      {required this.label, required this.value, required this.unit});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20)),
        Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label, value;
  const _MacroItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;

  const _CategorySection({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing != null ? Text(trailing!) : null,
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String title;
  final List<MealItem> items;
  final int totalKcal;

  const _MealSection({
    required this.title,
    required this.items,
    required this.totalKcal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          ...items.map((item) => item.buildCard()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("$totalKcal Kcal",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MealItem {
  final String name, sub, quantity;
  final int kcal;
  final int maxKcal;

  MealItem({
    required this.name,
    required this.sub,
    required this.quantity,
    required this.kcal,
    required this.maxKcal,
  });

  Widget buildCard() {
    double percent = kcal / maxKcal;
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("$sub\n$quantity"),
      isThreeLine: true,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 4,
                  color: Colors.green,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              Text("$kcal", style: const TextStyle(fontSize: 12)),
            ],
          ),
          const Text("Kcal", style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
