import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/emergency_service.dart'; // Import your data model

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<EmergencyService> emergencyServices = [];
  bool isLoading = true; // To show loading indicator

  @override
  void initState() {
    super.initState();
    fetchEmergencyServices();
  }

  Future<void> fetchEmergencyServices() async {
    final url = Uri.parse("http://172.20.10.2:8080/api/services");  // Backend API

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          emergencyServices =
              data.map((json) => EmergencyService.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Contacts"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : ListView.builder(
              itemCount: emergencyServices.length,
              itemBuilder: (context, index) {
                final service = emergencyServices[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.local_hospital, color: Colors.red),
                    title: Text(service.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.address),
                        Text(service.phoneNumber, style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Text(service.rating.toString()),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
