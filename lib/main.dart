import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'splash_screen.dart';
import 'home_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tank Track',
      theme: ThemeData.dark(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission for notifications");
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        _sendTokenToBackend(fcmToken);
      }
    } else {
      print("User denied notifications permission");
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("New foreground notification: ${message.notification?.title}");
    });
  }

  void _sendTokenToBackend(String token) async {
    const String apiUrl = "http://localhost:8080/api/save-fcm-token";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fcmToken": token}),
      );

      if (response.statusCode == 200) {
        print("FCM Token sent successfully!");
      } else {
        print("Failed to send token. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending FCM token: $e");
    }
  }

  Future<bool> _checkUserExists(User? user) async {
    if (user == null) return false;
    try {
      await user.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        await FirebaseAuth.instance.signOut();
        return false;
      }
      return true;
    } catch (e) {
      print("Error checking user existence: $e");
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _checkUserExists(snapshot.data),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (asyncSnapshot.hasData && asyncSnapshot.data == true) {
                return const HomeScreen();
              } else {
                return const SplashScreen();
              }
            },
          );
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}
