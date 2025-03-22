import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wifi_service.dart';

class WiFiConfigurationScreen extends StatefulWidget {
  const WiFiConfigurationScreen({super.key});

  @override
  _WiFiConfigurationScreenState createState() =>
      _WiFiConfigurationScreenState();
}

class _WiFiConfigurationScreenState extends State<WiFiConfigurationScreen> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? currentSSID;
  String? currentPassword;

  @override
  void initState() {
    super.initState();
    _fetchWiFiConfiguration();
  }

  // Fetch existing WiFi configuration
  Future<void> _fetchWiFiConfiguration() async {
    try {
      const String tankId = "your-tank-id"; // Replace with actual tankId
      Map<String, dynamic>? wifiConfig = await WiFiService.getWiFiConfiguration(
        tankId,
      );

      if (wifiConfig != null) {
        setState(() {
          currentSSID = wifiConfig['ssid'];
          currentPassword = wifiConfig['password'];
          ssidController.text = currentSSID!;
          passwordController.text = currentPassword!;
        });
      }
    } catch (e) {
      print("Error fetching WiFi configuration: $e");
    }
  }

  // Save WiFi configuration
  Future<void> _saveWiFiConfiguration() async {
    if (ssidController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both SSID and Password")),
      );
      return;
    }

    try {
      await WiFiService.saveWiFiConfiguration(
        ssidController.text,
        passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WiFi Configuration Saved Successfully")),
      );
      _fetchWiFiConfiguration(); // Refresh data
    } catch (e) {
      print("Error saving WiFi configuration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save WiFi configuration")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 50, 45, 85),
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
                      "Wi-fi Configuration",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset("assets/wificonfig.png", width: 130),
                    const SizedBox(height: 40),
                    _buildLabel("Wi-fi SSID"),
                    _buildTextField(controller: ssidController),
                    const SizedBox(height: 20),
                    _buildLabel("Wi-fi Password"),
                    _buildTextField(
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          247,
                          240,
                          194,
                          142,
                        ),
                        minimumSize: const Size(350, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: _saveWiFiConfiguration,
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Color.fromARGB(255, 72, 66, 109),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Colors.white60),
          ),
          hintText: obscureText ? "Enter password" : "Enter SSID",
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
