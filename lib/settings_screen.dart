import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/about_us.dart';
import 'package:flutter_application_1/meet_the_team.dart';
import 'package:flutter_application_1/tank_configuration.dart';
import 'package:flutter_application_1/wifi_configuration.dart';
import 'home_screen.dart';
import 'account_settings_screen.dart';
import 'login_screen.dart';
import 'emergency_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final int _selectedIndex = 2; // 0 = Home, 1 = Alerts, 2 = Settings

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 50, 45, 85),
        child: SafeArea(
          child: Column(children: [_buildAppBar(), _buildSettingsList()]),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logomark.png', height: 40),
          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Icon(Icons.notifications, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSettingsTile(Icons.person, "Account Settings"),
          _buildSettingsTile(Icons.wifi, "Wi-Fi Configuration"),
          _buildSettingsTile(Icons.straighten, "Tank Configuration"),
          _buildSettingsTile(Icons.notifications, "Notification Settings"),
          _buildSettingsTile(Icons.star, "Premium Features"),
          _buildSettingsTile(Icons.call, "About Us"),
          _buildSettingsTile(Icons.group, "Meet the Team"),

          const SizedBox(height: 20),
          _buildLogoutButton(), // ✅ Logout button added
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        if (title == "Account Settings") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountSettingsScreen(),
            ),
          );
        } else if (title == "Tank Configuration") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TankConfigurationScreen(),
            ),
          );
        } else if (title == "Wi-Fi Configuration") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WiFiConfigurationScreen(),
            ),
          );
        } else if (title == "About Us") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutUsScreen()),
          );
        } else if (title == "Meet the Team") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeetTheTeamScreen()),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15, top: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color.fromARGB(156, 240, 194, 142),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 49, 44, 81), size: 28),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 72, 66, 109),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _logout, // ✅ Logout function call
        child: const Text(
          "LOGOUT",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 175, 73, 73),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // ✅ Ensure user is signed out

      // ✅ Immediately navigate to login screen and remove history
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ), // Redirect to Login
          (route) => false, // Removes all previous routes
        );
      });
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: const Color.fromARGB(
        255,
        49,
        44,
        81,
      ), // Solid background from #0A00C1
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 49, 44, 81),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(247, 240, 194, 142),
        unselectedItemColor: Colors.white54,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 30,
        currentIndex: _selectedIndex, // Highlight selected tab
        onTap: (index) {
          if (index == 0 && _selectedIndex != 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EmergencyScreen()),
            );
          }
        },
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
}
