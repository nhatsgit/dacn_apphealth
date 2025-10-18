import 'package:flutter/material.dart';

class AddWeightPage extends StatefulWidget {
  final double? lastWeight; // ✅ Truyền cân nặng trước đó từ lịch sử

  const AddWeightPage({super.key, this.lastWeight});

  @override
  State<AddWeightPage> createState() => _AddWeightPageState();
}

class _AddWeightPageState extends State<AddWeightPage> {
  final TextEditingController newWeightController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String unit = 'kg';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previousWeight = widget.lastWeight?.toStringAsFixed(1) ?? '--';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Add Weight Record"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- New weight (editable) ---
            _WeightInputCard(
              label: 'New weight',
              controller: newWeightController,
              unit: unit,
              onUnitChanged: (val) => setState(() => unit = val!),
            ),

            // --- Previous weight (readonly) ---
            _ReadOnlyWeightCard(
              label: 'Previous weight',
              value: previousWeight,
              unit: unit,
            ),

            const SizedBox(height: 10),

            // --- Date & Time row ---
            Row(
              children: [
                Expanded(
                  child: _DateTimeCard(
                    icon: Icons.calendar_today,
                    text:
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateTimeCard(
                    icon: Icons.access_time,
                    text:
                        "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- BMI info cards ---
            Row(
              children: const [
                Expanded(
                  child: _InfoBox(
                    title: "BMI",
                    content: "19,6\nBody fat (%): 15,1\nMuscle: 47,5 kg",
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _InfoBox(
                    title: "Ideal weight",
                    content:
                        "72,3 kg\n% of Change: 0,2 %\nVariation from goal: Goal not set",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- Notes ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notes"),
                    const SizedBox(height: 4),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        hintText: "Notes",
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 70),
          ],
        ),
      ),

      // ✅ Save button (floating bottom)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Weight record saved ✅')),
          );
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

// --- Editable weight card ---
class _WeightInputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final Function(String?) onUnitChanged;

  const _WeightInputCard({
    required this.label,
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.monitor_weight_outlined, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: unit,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'kg', child: Text('kg')),
                DropdownMenuItem(value: 'lbs', child: Text('lbs')),
              ],
              onChanged: onUnitChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Readonly weight card ---
class _ReadOnlyWeightCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _ReadOnlyWeightCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$value",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              unit,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Date/time & info boxes ---

class _DateTimeCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _DateTimeCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const _InfoBox({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              content,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
