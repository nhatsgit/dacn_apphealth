import 'package:dacn_app/pages/Sleep/AddSleepPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({Key? key}) : super(key: key);

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> sleepRecords = [
    {
      'startTime': DateTime(2025, 10, 17, 23, 0),
      'endTime': DateTime(2025, 10, 18, 7, 0),
      'duration': 480,
      'sleepQuality': 'Good',
      'sleepType': 'Night Sleep',
    },
    {
      'startTime': DateTime(2025, 10, 16, 12, 30),
      'endTime': DateTime(2025, 10, 16, 13, 0),
      'duration': 30,
      'sleepQuality': 'Average',
      'sleepType': 'Nap',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return "${hours}h ${mins}m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Giấc Ngủ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AddSleepPage()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "HISTORY"),
            Tab(text: "TRENDS"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sleepRecords.length,
      itemBuilder: (context, index) {
        final record = sleepRecords[index];
        final start = record['startTime'] as DateTime;
        final end = record['endTime'] as DateTime;
        final duration = record['duration'] as int;
        final quality = record['sleepQuality'] as String?;
        final type = record['sleepType'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.nightlight_round, color: Colors.blueGrey),
            title: Text(
              "${formatDate(start)} → ${DateFormat('HH:mm').format(end)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Duration: ${formatDuration(duration)}"),
                  Text("Quality: $quality"),
                  Text("Type: $type"),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bar_chart, color: Colors.green),
                Text("${(duration / 60).toStringAsFixed(1)} h",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return const Center(
      child: Text(
        "Charts / Sleep Trends will appear here",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
