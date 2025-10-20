import 'package:flutter/material.dart';

class MedicationDetailPage extends StatelessWidget {
  const MedicationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        title: const Text("Thêm thuốc"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 9,
                    width: 9,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🧾 Nhập tên thuốc
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
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Tên thuốc",
                        prefixIcon: Icon(Icons.medication_outlined),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          "Ngày bắt đầu:",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          "20-10-2025",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🍽 Hướng dẫn và đơn vị
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
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Hướng dẫn",
                          border: InputBorder.none,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "before",
                              child: Text("Uống trước bữa ăn")),
                          DropdownMenuItem(
                              value: "after", child: Text("Uống sau bữa ăn")),
                          DropdownMenuItem(
                              value: "bed", child: Text("Trước khi ngủ")),
                        ],
                        onChanged: (v) {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Đơn vị",
                          border: InputBorder.none,
                        ),
                        items: const [
                          DropdownMenuItem(value: "pill", child: Text("viên")),
                          DropdownMenuItem(value: "ml", child: Text("ml")),
                          DropdownMenuItem(value: "drop", child: Text("giọt")),
                        ],
                        onChanged: (v) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🗓 Ngày kết thúc + số ngày
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
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Ngày kết thúc",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Số ngày",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔁 Lặp lại
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
                  children: const [
                    Text("Lặp lại",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    SizedBox(height: 6),
                    Text(
                      "CN, Th 2, Th 3, Th 4, Th 5, Th 6, Th 7",
                      style: TextStyle(color: Colors.grey),
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
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Ghi chú",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {},
        child: const Icon(Icons.check),
      ),
    );
  }
}
