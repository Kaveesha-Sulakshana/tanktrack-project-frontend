import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tank_service.dart'; // ✅ Import the API service

class TankConfigurationScreen extends StatefulWidget {
  const TankConfigurationScreen({super.key});

  @override
  _TankConfigurationScreenState createState() => _TankConfigurationScreenState();
}

class _TankConfigurationScreenState extends State<TankConfigurationScreen> {
  final TextEditingController depthController = TextEditingController();
  final TextEditingController sensorDistanceController = TextEditingController();

  double? currentDepth;
  double? currentSensorDistance;

  @override
  void initState() {
    super.initState();
    _fetchTankConfiguration();
  }

  // 🔹 Fetch existing Tank Configuration
  Future<void> _fetchTankConfiguration() async {
    try {
      const String tankId = "your-tank-id"; // Replace with actual tankId
      Map<String, dynamic>? tankConfig = await TankService.getTankConfiguration(tankId);

      if (tankConfig != null) {
        setState(() {
          currentDepth = tankConfig['depth'];
          currentSensorDistance = tankConfig['sensorDistance'];

          depthController.text = currentDepth?.toString() ?? "";
          sensorDistanceController.text = currentSensorDistance?.toString() ?? "";
        });
      }
    } catch (e) {
      print("❌ Error fetching tank configuration: $e");
    }
  }

  // 🔹 Save Tank Configuration
  Future<void> _saveTankConfiguration() async {
    if (depthController.text.isEmpty || sensorDistanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both Depth and Sensor Distance")),
      );
      return;
    }

    double depth = double.tryParse(depthController.text) ?? 0;
    double sensorDistance = double.tryParse(sensorDistanceController.text) ?? 0;

    if (depth <= 0 || sensorDistance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Depth and Sensor Distance must be greater than zero")),
      );
      return;
    }

    try {
      await TankService.saveTankConfiguration(depth, sensorDistance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tank Configuration Saved Successfully")),
      );
      _fetchTankConfiguration(); // Refresh data
    } catch (e) {
      print("❌ Error saving configuration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save tank configuration")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 18, 82, 177),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Tank Configuration",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset("assets/truck.png", width: 130), // Ensure you have a matching image
                    const SizedBox(height: 40),
                    _buildLabel("Tank Depth (meters)"),
                    _buildTextField(controller: depthController, hint: "Enter depth in meters"),
                    const SizedBox(height: 20),
                    _buildLabel("Sensor Distance (meters)"),
                    _buildTextField(controller: sensorDistanceController, hint: "Enter sensor distance"),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B43D6),
                        minimumSize: const Size(350, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: _saveTankConfiguration,
                      child: const Text(
                        "Save Configuration",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Colors.white60),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
