import 'package:flutter/material.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          'Overview',
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
          // Thanh ngày
          Container(
            color: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                Text(
                  'Yesterday',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách các thẻ thông tin
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: const [
                _InfoCard(
                  icon: Icons.monitor_weight_outlined,
                  title: '56 kg',
                  subtitle: '',
                  rightText: '',
                  progress: null,
                ),
                _InfoCard(
                  icon: Icons.local_drink_outlined,
                  title: '1 Litre',
                  subtitle: '',
                  rightText: '1,83',
                  progress: 0.55,
                ),
                _InfoCard(
                  icon: Icons.restaurant_menu_outlined,
                  title: '224 Kcal',
                  subtitle: '',
                  rightText: '2342',
                  progress: 0.1,
                ),
                _InfoCard(
                  icon: Icons.local_fire_department_outlined,
                  title: '0 Kcal',
                  subtitle: '',
                  rightText: '',
                  progress: null,
                ),
                _InfoCard(
                  icon: Icons.bedtime_outlined,
                  title: 'No measurement',
                  subtitle: '',
                  rightText: '',
                  progress: null,
                ),
                _InfoCard(
                  icon: Icons.directions_walk_outlined,
                  title: '0 km',
                  subtitle: '',
                  rightText: '',
                  progress: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
