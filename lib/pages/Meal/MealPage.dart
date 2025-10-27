import 'package:dacn_app/pages/Meal/AddFoodPage.dart';
import 'package:flutter/material.dart';

class ListFoodPage extends StatefulWidget {
  const ListFoodPage({super.key});

  @override
  State<ListFoodPage> createState() => _ListFoodPageState();
}

class _ListFoodPageState extends State<ListFoodPage> {
  final List<Map<String, String>> foods = [
    {
      "name": "Cơm gà",
      "brand": "Nhà làm",
      "mealType": "Lunch",
      "date": "27-10-2025",
    },
    {
      "name": "Bánh mì trứng",
      "brand": "Quán A",
      "mealType": "Breakfast",
      "date": "27-10-2025",
    },
    {
      "name": "Sữa chua",
      "brand": "Vinamilk",
      "mealType": "Snack",
      "date": "27-10-2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'Danh sách món ăn',
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, size: 30),
        onPressed: () async {
          // Chuyển sang trang thêm món ăn
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodPage()),
          );
          // TODO: cập nhật lại danh sách sau khi thêm (nếu cần)
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return _buildFoodCard(food);
        },
      ),
    );
  }

  Widget _buildFoodCard(Map<String, String> food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // TODO: mở trang chi tiết món ăn (nếu có)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.restaurant_menu,
                  color: Color(0xFF4CAF50), size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food["name"] ?? "",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          "Ngày: ",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          food["date"] ?? "",
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Bữa: ",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          food["mealType"] ?? "",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    if (food["brand"]?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 3),
                      Text(
                        food["brand"]!,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
