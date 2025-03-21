import 'dart:convert';
import 'package:http/http.dart' as http;

class TankService {
  static const String baseUrl = "http://10.0.2.2:8080/api/tank"; // Use 10.0.2.2 for Android emulator, localhost for Web/PC

  // Send tank configuration data to the backend
  static Future<void> saveTankConfiguration(double depth, double sensorDistance) async {
    final response = await http.post(
      Uri.parse("$baseUrl"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "depth": depth,
        "sensorDistance": sensorDistance
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Tank configuration saved successfully");
    } else {
      throw Exception("Failed to save tank configuration: ${response.body}");
    }
  }

  // Fetch all tank configurations from the backend
  static Future<List<dynamic>> fetchTankConfigurations() async {
    final response = await http.get(Uri.parse("$baseUrl"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load configurations");
    }
  }
}
