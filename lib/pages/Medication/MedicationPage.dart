import 'package:dacn_app/pages/Medication/MedicationDetailPage.dart';
import 'package:flutter/material.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        color: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: const [
            MedicationCard(
              name: "Vitamin G",
              startDate: "20-10-2025",
              instruction: "Uống trước bữa ăn",
            ),
            MedicationCard(
              name: "Thuốc Đau Đầu",
              startDate: "20-10-2025",
              instruction: "Uống trước bữa ăn",
            ),
            MedicationCard(
              name: "Thuốc Bôi Da",
              startDate: "20-10-2025",
              instruction: "Thoa trước khi ngủ",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicationDetailPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String name;
  final String startDate;
  final String instruction;

  const MedicationCard({
    super.key,
    required this.name,
    required this.startDate,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ngày bắt đầu",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    startDate,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hướng dẫn",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    instruction,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
