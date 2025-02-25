import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double tankPercentage = 0; // Default value
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('tankLevel');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    dbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          tankPercentage = double.parse(event.snapshot.child('percentage').value.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [
              Color(0xFF011D47), 
              Color(0xFF00050B), 
              Color(0xFF00060E),
            ],
            stops: [0.0, 1.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildUserCard(),
              _buildTankIndicator(),
              _buildBottomPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  // Top AppBar Section
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logomark.png', height: 40), // Your logo
          const Text(
            "Home",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Icon(Icons.notifications, color: Colors.white),
        ],
      ),
    );
  }

  // User Welcome Card
  Widget _buildUserCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_circle, size: 50, color: Colors.white),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Friday, February 14",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Welcome Back",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "User",
                  style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// Tank Level Circular Indicator (Fixed Layout)
// Tank Level Circular Indicator (Fixed Layout)
Widget _buildTankIndicator() {
 
  Color getColor(double percentage) {
    if (percentage <= 20) {
      return const Color(0xFF66FF66); // Light Green
    } else if (percentage <= 40) {
      return const Color(0xFF00C49A); // Green
    } else if (percentage <= 60) {
      return const Color.fromARGB(255, 255, 234, 172); // Yellow
    } else if (percentage <= 80) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFFF3D00); // Red
    }
  }

  return Column(
    children: [
      const SizedBox(height: 20),
      const Text(
        "Tank Summary",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 30), // Adjusted spacing
      TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: tankPercentage),
        duration: const Duration(seconds: 2), // Smooth animation
        builder: (context, double animatedValue, child) {
          Color progressColor = getColor(animatedValue); // Dynamic color update

          return SizedBox(
            height: 280, // Adjusted size to match the UI
            width: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular Progress Indicator (Animated)
                SizedBox(
                  height: 260,
                  width: 260,
                  child: CircularProgressIndicator(
                    value: animatedValue / 100,
                    strokeWidth: 18, // Thick stroke for bold look
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                // Centered Logo and Text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logomark.png',
                      height: 100, // Perfect size for inside circle
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Tap here",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                // Percentage Text Inside the Circle (Animated)
                Positioned(
                  bottom: 20, // Moves percentage inside the circle
                  child: Text(
                    "${animatedValue.toStringAsFixed(0)}%", // Rounded percentage with animation
                    style: TextStyle(
                      color: progressColor, // Dynamic Color for Percentage Text
                      fontSize: 28, // Adjusted for better visibility
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}



  // Placeholder for bottom section
  Widget _buildBottomPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        width: double.infinity,
        height: 100, // Adjust this as needed
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

