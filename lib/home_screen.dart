import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';
import 'monthly_report.dart';
import 'notifications_screen.dart';

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
        color: Color.fromARGB(255, 18, 82, 177),
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            child: const Icon(Icons.notifications, color: Colors.white),
          ),
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
          color: Colors.white.withOpacity(0.5),
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
                    color: Colors.white.withOpacity(1),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Color.fromARGB(255, 2, 46, 111),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "User",
                  style: TextStyle(
                    color: Color.fromARGB(255, 2, 46, 111),
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
      if (percentage <= 20) return const Color(0xFF00FF00); // Bright Neon Green
      if (percentage <= 40) return const Color(0xFF00E676); // Bright Green
      if (percentage <= 60) {
        return const Color(0xFFFFEB3B); // Bright Yellow
      }
      if (percentage <= 80) return const Color(0xFFFF5722); // Bright Orange
      return const Color(0xFFD50000); // Bright Red
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
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black45,
                offset: Offset(2, 2),
              ),
            ],
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
                  Container(
                    height: 270,
                    width: 270,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                  ),
                  SizedBox(
                    height: 260,
                    width: 260,
                    child: CircularProgressIndicator(
                      value: animatedValue / 100,
                      strokeWidth: 18,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logomark.png', height: 100),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonthlyReportScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Tap here",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
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
      backgroundColor: Color.fromARGB(255, 9, 38, 82),
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
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
