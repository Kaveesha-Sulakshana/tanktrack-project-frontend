import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {
  static const String apiUrl = "http://10.0.2.2:8080/api/reports/latest";

  Future<Map<String, dynamic>> fetchLatestReport() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load report");
      }
    } catch (e) {
      throw Exception("Error fetching report: $e");
    }
  }
}
