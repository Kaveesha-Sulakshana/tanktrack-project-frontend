import 'dart:convert';
import 'package:http/http.dart' as http;

class TankService {
  static const String baseUrl = "http://10.0.2.2:8080/api/tank";

  static Future<void> saveTankConfiguration(
    double depth,
    double sensorDistance,
    String email,
  ) async {
    final url = Uri.parse("$baseUrl/save");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "depth": depth,
        "sensorDistance": sensorDistance,
        "email": email,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Tank configuration saved successfully");
      print("📩 Response: ${response.statusCode} - ${response.body}");
    } else {
      throw Exception("❌ Failed to save tank configuration: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>?> getTankConfiguration(
    String tankId,
  ) async {
    final url = Uri.parse("$baseUrl/$tankId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Tank configuration fetched: $data");
      return data;
    } else if (response.statusCode == 404) {
      print("⚠️ No tank configuration found for tankId: $tankId");
      return null;
    } else {
      throw Exception("❌ Failed to load tank configuration: ${response.body}");
    }
  }

  static Future<List<dynamic>> fetchAllConfigurations() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "❌ Failed to fetch all tank configurations: ${response.body}",
      );
    }
  }
}
