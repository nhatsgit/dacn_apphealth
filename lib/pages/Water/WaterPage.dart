import 'package:flutter/material.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({Key? key}) : super(key: key);

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  double totalIntake = 1.0; // Lượng nước đã uống (lit)
  double goalIntake = 1.83; // Mục tiêu (lit)

  void addWater(double amount) {
    setState(() {
      totalIntake += amount;
      if (totalIntake > goalIntake) totalIntake = goalIntake;
    });
  }

  @override
  Widget build(BuildContext context) {
    double remaining = goalIntake - totalIntake;
    double fillPercent = (totalIntake / goalIntake).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nước',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        backgroundColor: Colors.green,
        actions: const [
          Icon(Icons.edit),
          SizedBox(width: 10),
          Icon(Icons.share),
          SizedBox(width: 10),
          Icon(Icons.local_drink_outlined),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // --- Header card ---
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text("Ideal water intake",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text("${goalIntake.toStringAsFixed(2)} Litre",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: const [
                      Text("Goal water intake",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      SizedBox(height: 5),
                      Text("Goal not set",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ),

          // --- Water fill area ---
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(color: Colors.grey[100]),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height:
                      MediaQuery.of(context).size.height * fillPercent * 0.5,
                  color: Colors.blue[300],
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    children: [
                      Text(
                        "${remaining.toStringAsFixed(2)} Litre to go!",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "You have logged ${totalIntake.toStringAsFixed(2)} Litre",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Bottom buttons ---
          Container(
            color: Colors.orange[300],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                waterButton("180 ml", 0.18),
                waterButton("350 ml", 0.35),
                waterButton("500 ml", 0.5),
                waterButton("1000 ml", 1.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget waterButton(String label, double amount) {
    return GestureDetector(
      onTap: () => addWater(amount),
      child: Column(
        children: [
          const Icon(Icons.local_drink_outlined, size: 40, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
