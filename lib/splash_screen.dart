import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // Import LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ), // Navigate to LoginScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 72, 66, 109),
        child: const Center(
          child: Image(
            image: AssetImage('assets/logo.png'),
            width: 500, // Maintained the width for consistency
            height: 500,
          ),
        ),
      ),
    );
  }
}
