import 'dart:convert';
import 'package:http/http.dart' as http;

class WiFiService {
  static const String baseUrl = "http://10.0.2.2:8080/api/wifi/save"; 
  static Future<Map<String, dynamic>?> getWiFiConfiguration(String tankId) async {
    final response = await http.get(Uri.parse("$baseUrl/$tankId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null; 
    } else {
      throw Exception("Failed to load WiFi configuration");
    }
  }

  static Future<void> saveWiFiConfiguration(String ssid, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ssid": ssid, "password": password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("WiFi configuration saved successfully");
    } else {
      throw Exception("Failed to save WiFi configuration: ${response.body}");
    }
  }
}
