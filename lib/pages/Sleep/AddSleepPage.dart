import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSleepPage extends StatefulWidget {
  const AddSleepPage({Key? key}) : super(key: key);

  @override
  State<AddSleepPage> createState() => _AddSleepPageState();
}

class _AddSleepPageState extends State<AddSleepPage> {
  DateTime? startTime;
  DateTime? endTime;
  int? durationMinutes;
  String? sleepQuality;
  String? sleepType;
  final TextEditingController notesController = TextEditingController();

  final List<String> sleepQualities = ['Excellent', 'Good', 'Average', 'Poor'];
  final List<String> sleepTypes = ['Night Sleep', 'Nap'];

  Future<void> pickTime(bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selectedDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        startTime = selectedDateTime;
      } else {
        endTime = selectedDateTime;
      }
      _calculateDuration();
    });
  }

  void _calculateDuration() {
    if (startTime != null && endTime != null) {
      durationMinutes = endTime!.difference(startTime!).inMinutes;
      if (durationMinutes! < 0) durationMinutes = 0;
    }
  }

  void _saveRecord() {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep record saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Record"),
        backgroundColor: Colors.green,
        actions: const [
          Icon(Icons.nightlight_round_outlined),
          SizedBox(width: 12),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // --- Time cards ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Start Time",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          startTime != null
                              ? DateFormat('dd-MM-yyyy HH:mm')
                                  .format(startTime!)
                              : "Select start time",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => pickTime(true),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text("End Time", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          endTime != null
                              ? DateFormat('dd-MM-yyyy HH:mm').format(endTime!)
                              : "Select end time",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => pickTime(false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Duration + Quality + Type ---
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    "Duration",
                    durationMinutes != null
                        ? "${(durationMinutes! ~/ 60)}h ${(durationMinutes! % 60)}m"
                        : "--",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: _dropdownDecoration("Sleep Quality"),
                    value: sleepQuality,
                    items: sleepQualities
                        .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                        .toList(),
                    onChanged: (val) => setState(() => sleepQuality = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: _dropdownDecoration("Sleep Type"),
                    value: sleepType,
                    items: sleepTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => sleepType = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Notes ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: "Notes", border: InputBorder.none),
              ),
            ),

            const SizedBox(height: 20),

            // --- Save Button ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("Save Sleep Record",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _saveRecord,
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
