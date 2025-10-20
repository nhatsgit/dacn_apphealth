import 'package:dacn_app/pages/Workout/AddActivityPage.dart';
import 'package:dacn_app/pages/Workout/AddWorkoutPage.dart';
import 'package:flutter/material.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  // Danh sách hoạt động mẫu
  final List<String> _activities = [
    "Aerobics, dance",
    "Aerobics, general",
    "Aerobics, high impact",
    "Aerobics, low impact",
    "Aerobics, spinning",
    "Aerobics, step",
    "Automobile repair",
    "Backpacking",
    "Badminton",
    "Baseball",
    "Basketball",
    "Basketball, shooting",
    "Bathing dog",
    "Belly dancing",
    "Bicycling, mountain",
    "Bicycling, leisure",
    "Bowling",
    "Boxing, sparring",
  ];

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo text tìm kiếm
    final filtered = _activities
        .where((a) => a.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Search Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Focus vào ô tìm kiếm
              showSearchBar(context);
            },
          ),
        ],
      ),

      // Danh sách hoạt động
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(filtered[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddActivityPage(activityName: filtered[index]),
                  ),
                );
              },
            ),
          );
        },
      ),

      // Nút thêm hoạt động
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWorkoutPage(),
            ),
          );
        },
      ),
    );
  }

  // Thanh tìm kiếm (overlay)
  void showSearchBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search activity...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchText = value);
            },
          ),
        );
      },
    );
  }
}
