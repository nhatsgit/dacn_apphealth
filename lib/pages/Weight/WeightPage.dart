import 'package:flutter/material.dart';

class WeightPage extends StatelessWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context) {
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

      // Thân trang
      body: Column(
        children: [
          // 🟩 Card thống kê
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem(label: 'Minimum', value: '55 kg'),
                _StatItem(label: 'Maximum', value: '56 kg'),
                _StatItem(label: 'Average', value: '55,5 kg'),
                _StatItem(label: 'Ideal weight', value: '72,3 kg'),
              ],
            ),
          ),

          // 🔸 Tabs: HISTORY / TRENDS
          Container(
            color: Colors.green,
            child: DefaultTabController(
              length: 2,
              child: TabBar(
                indicatorColor: Colors.orange,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'HISTORY'),
                  Tab(text: 'TRENDS'),
                ],
              ),
            ),
          ),

          // 📋 Danh sách lịch sử
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                _WeightCard(
                  date: '16-10-2025 16:42',
                  bmi: '19,6',
                  bodyFat: '15,1 %',
                  weight: '56',
                  showTrend: true,
                ),
                _WeightCard(
                  date: '15-10-2025 19:06',
                  bmi: '19,3',
                  bodyFat: '14,6 %',
                  weight: '55',
                ),
              ],
            ),
          ),
        ],
      ),

      // ➕ Nút thêm
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Widget con hiển thị chỉ số
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

// Widget thẻ lịch sử cân nặng
class _WeightCard extends StatelessWidget {
  final String date;
  final String bmi;
  final String bodyFat;
  final String weight;
  final bool showTrend;

  const _WeightCard({
    required this.date,
    required this.bmi,
    required this.bodyFat,
    required this.weight,
    this.showTrend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
                Text('Body fat ($bodyFat)',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
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
                if (showTrend)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Icon(Icons.trending_up,
                        color: Colors.redAccent, size: 18),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
