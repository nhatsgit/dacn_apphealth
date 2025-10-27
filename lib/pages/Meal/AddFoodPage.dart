import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _foodNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _proteinController = TextEditingController();
  final _servingsController = TextEditingController(text: "1");
  final _servingSizeController = TextEditingController(text: "Servings");
  final _notesController = TextEditingController();

  String _selectedMeal = "Breakfast";
  final List<String> _mealTypes = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
  ];

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final formattedDate = dateFormat.format(selectedDate);
    final formattedTime = selectedTime.format(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'Create Food',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () {
          // TODO: handle save
        },
        child: const Icon(Icons.check, size: 30),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            // --- Card 1: Food Info ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    _buildInput(
                        Icons.restaurant, "Food name", _foodNameController),
                    const SizedBox(height: 10),
                    _buildInput(
                        Icons.restaurant, "Brand name", _brandNameController),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- Card 2: Nutrition Info ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildSmallInput(
                                "Calories (Kcal)", _caloriesController)),
                        const SizedBox(width: 10),
                        Expanded(
                            child:
                                _buildSmallInput("Fat (gm)", _fatController)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildSmallInput(
                                "Carbohydrates (gm)", _carbsController)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildSmallInput(
                                "Protein (gm)", _proteinController)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildSmallInput(
                                "Servings", _servingsController)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildSmallInput(
                                "Serving size", _servingSizeController)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedMeal,
                      decoration: const InputDecoration(
                        labelText: "Meal type",
                        border: InputBorder.none,
                      ),
                      items: _mealTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() {
                        _selectedMeal = val!;
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    color: Colors.grey),
                                const SizedBox(width: 10),
                                Text(formattedDate,
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(formattedTime,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 10),
                                const Icon(Icons.access_time_outlined,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- Notes ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: "Notes",
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(IconData icon, String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        labelText: label,
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildSmallInput(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
    );
  }
}
