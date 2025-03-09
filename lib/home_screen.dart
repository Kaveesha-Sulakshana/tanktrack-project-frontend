import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double tankPercentage = 0; // Default value
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('tankLevel');

  int _selectedIndex = 0; // Track active bottom nav item

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    dbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          tankPercentage = double.parse(
            event.snapshot.child('percentage').value.toString(),
          );
        });
      }
    });
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 2) {
        // Navigate to Settings Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [Color(0xFF011D47), Color(0xFF00050B), Color(0xFF00060E)],
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 🔹 Top AppBar Section
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logomark.png', height: 40),
          const Text(
            "Home",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Icon(Icons.notifications, color: Colors.white),
        ],
      ),
    );
  }

  // 🔹 User Welcome Card
  Widget _buildUserCard() {
    String todayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todayDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "User",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.account_circle, size: 80, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // 🔹 Tank Level Circular Indicator
  Widget _buildTankIndicator() {
    Color getColor(double percentage) {
      if (percentage <= 20) return const Color(0xFF66FF66); // Light Green
      if (percentage <= 40) return const Color(0xFF00C49A); // Green
      if (percentage <= 60) {
        return const Color.fromARGB(255, 255, 234, 172); // Yellow
      }
      if (percentage <= 80) return const Color(0xFFFF9800); // Orange
      return const Color(0xFFFF3D00); // Red
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Tank Summary",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: tankPercentage),
          duration: const Duration(seconds: 2),
          builder: (context, double animatedValue, child) {
            Color progressColor = getColor(animatedValue);
            return SizedBox(
              height: 280,
              width: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 260,
                    width: 260,
                    child: CircularProgressIndicator(
                      value: animatedValue / 100,
                      strokeWidth: 18,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logomark.png', height: 100),
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
                  Positioned(
                    bottom: 20,
                    child: Text(
                      "${animatedValue.toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 28,
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

  // 🔹 Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Alerts"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }

  // 🔹 Placeholder for bottom section
  Widget _buildBottomPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
