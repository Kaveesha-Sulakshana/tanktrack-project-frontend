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
    print("FCM Token: $token"); // ✅ Print Token for Debugging
    if (token != null) {
      _sendTokenToBackend(token);
    } else {
      print("Failed to get FCM token");
    }
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
        title: const Text("Notifications"),
        backgroundColor: const Color.fromARGB(255, 72, 66, 109),
      ),
      body:
          notifications.isEmpty
              ? const Center(child: Text("No Notifications"))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(notifications[index]),
                      leading: const Icon(Icons.notifications),
                    ),
                  );
                },
              ),
    );
  }
}
