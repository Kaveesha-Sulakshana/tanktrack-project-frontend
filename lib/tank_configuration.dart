import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tank_service.dart'; // Import the API service

class TankConfigurationScreen extends StatefulWidget {
  const TankConfigurationScreen({super.key});

  @override
  _TankConfigurationScreenState createState() => _TankConfigurationScreenState();
}

class _TankConfigurationScreenState extends State<TankConfigurationScreen> {
  final TextEditingController depthController = TextEditingController();
  final TextEditingController sensorDistanceController = TextEditingController();

  Future<void> _saveConfig() async {
    if (depthController.text.isEmpty || sensorDistanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all values")),
      );
      return;
    }

    double depth = double.tryParse(depthController.text) ?? 0;
    double sensorDistance = double.tryParse(sensorDistanceController.text) ?? 0;

    if (depth <= 0 || sensorDistance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Depth and sensor distance must be greater than zero")),
      );
      return;
    }

    try {
      await TankService.saveTankConfiguration(depth, sensorDistance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuration Saved Successfully")),
      );
      depthController.clear();
      sensorDistanceController.clear();
    } catch (e) {
      print("Error saving configuration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save configuration")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 18, 82, 177),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildBackButton(context),
                const SizedBox(height: 10),
                Text(
                  "TANK\nCONFIGURATION",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset("assets/truck.png", width: 250),
                const SizedBox(height: 20),
                _buildInputFields(),
                const SizedBox(height: 20),
                _buildConfirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTextField(
            "Enter the depth of your tank",
            "Depth of your tank (meters)",
            depthController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "Enter the distance between sensor and the overflow pipe",
            "Distance (meters)",
            sensorDistanceController,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.white60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B43D6),
        minimumSize: const Size(350, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      onPressed: _saveConfig,
      child: const Text("CONFIRM", style: TextStyle(color: Colors.white)),
    );
  }
}
