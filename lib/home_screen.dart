import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'monthly_report.dart';
import 'emergency_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double tankPercentage = 0;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('tankLevel');
  String _rainCategory = "";
  String _location = "";
  bool _isLoadingWeather = true;

  int _selectedIndex = 0;
  String firstName = "User";
  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchUserFirstName();
    _fetchWeatherForecast();
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

  Future<void> _fetchUserFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        final response = await http.get(
          Uri.parse("http://10.0.2.2:8080/auth/user?email=${user.email}"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            firstName = data["firstName"] ?? "User";
          });
        } else {
          print("❌ Failed to fetch user data: ${response.body}");
        }
      } catch (e) {
        print("❌ Error: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyScreen()),
        );
      } else if (index == 2) {
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
        decoration: const BoxDecoration(color: Color.fromARGB(255, 50, 45, 85)),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Column(
                  children: [
                    _buildUserCard(firstName),
                    const SizedBox(height: 10),
                    _buildTankIndicator(),
                    const SizedBox(height: 10),
                    _buildBottomPlaceholder(),
                  ],
                ),
              ),
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
            child: const Icon(
              Icons.notifications,
              color: Color.fromARGB(247, 240, 194, 142),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 User Welcome Card
  Widget _buildUserCard(String firstName) {
    String todayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 49, 44, 81),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, -12),
            ),
          ],
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
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Color.fromARGB(255, 253, 253, 255),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  firstName,
                  style: const TextStyle(
                    color: Color.fromARGB(247, 240, 194, 142),
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.account_circle,
              size: 80,
              color: Color.fromARGB(247, 240, 194, 142),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Tank Level Circular Indicator
  Widget _buildTankIndicator() {
    Color getColor(double percentage) {
      if (percentage <= 20) return const Color.fromARGB(191, 0, 255, 0);
      if (percentage <= 40) return const Color.fromARGB(217, 0, 230, 119);
      if (percentage <= 60) return const Color.fromARGB(201, 249, 187, 0);
      if (percentage <= 80) return const Color.fromARGB(223, 255, 86, 34);
      return const Color(0xFFD50000);
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Tank Summary",
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black45,
                offset: Offset(0, 5),
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
    return Container(
      decoration: const BoxDecoration(color: Color.fromARGB(255, 50, 45, 85)),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(247, 240, 194, 142),
        unselectedItemColor: Colors.white54,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 30,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency, color: Colors.white, size: 28),
            ),
            label: "",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
      ),
    );
  }

  Widget _buildBottomPlaceholder() {
  String getWeatherImage(String category) {
    switch (category) {
      case "Low":
        return 'assets/sunny.png';
      case "Average":
        return 'assets/cloudy.png';
      case "High":
        return 'assets/rainy.png';
      case "Critical":
        return 'assets/storm.png';
      default:
        return 'assets/unknown.png';
    }
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // ⬅️ Reduced vertical padding
    child: Container(
      width: double.infinity,
      height: 130, // ⬅️ Reduced height from 150
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 44, 81),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _isLoadingWeather
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      getWeatherImage(_rainCategory),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Weather Forecast",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rain Category: $_rainCategory",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
    ),
  );
}





  Future<void> _fetchWeatherForecast() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/weather/forecast"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _location = data["location"] ?? "";
          _rainCategory = data["rain_category"] ?? "Unknown";
          _isLoadingWeather = false;
        });
      } else {
        print("❌ Weather API error: ${response.body}");
      }
    } catch (e) {
      print("❌ Weather fetch failed: $e");
    }
  }
}
