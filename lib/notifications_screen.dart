import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _requestFCMToken();
    _setupFCMListener();
  }

  void _requestFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    _sendTokenToBackend(token!);
    }

  void _sendTokenToBackend(String token) async {
    const String apiUrl = "http://10.0.2.2:8080/api/save-fcm-token";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fcmToken": token}),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ FCM Token sent successfully!");
      } else {
        print("❌ Failed to send token. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error sending FCM token: $e");
    }
  }

  void _setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        setState(() {
          notifications.insert(
            0,
            message.notification!.body ?? "New Notification",
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(255, 50, 45, 85),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 50, 45, 85)),
        child:
            notifications.isEmpty
                ? const Center(
                  child: Text(
                    "No Notifications",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5E35B1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: const Color.fromARGB(119, 240, 194, 142),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        title: Text(
                          notifications[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        leading: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
