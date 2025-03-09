import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'emergency_screen.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 2; // Settings is selected by default

  // Navigation function
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmergencyScreen()),
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
              _buildSettingsList(),
            ],
          ),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
          _buildSettingsTile(Icons.person, "Account settings", null),
          _buildSettingsTile(Icons.wifi, "Wi-Fi configuration", null),
          _buildSettingsTile(Icons.notifications, "Notification settings", null),
          _buildSettingsTile(Icons.star, "Premium features", PremiumScreen()),
          _buildSettingsTile(Icons.call, "Contact us", null),
          _buildSettingsTile(Icons.group, "Meet the team", null),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 24),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black, // Full-width background color
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent, // Keep container color
        type: BottomNavigationBarType.fixed, // Equal spacing for icons
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 30, // Increase icon size
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0, // Remove shadow
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10), // Padding to lift the button
              child: const Icon(
                Icons.warning_amber_rounded, // Emergency icon
                color: Colors.white,
                size: 32, // Bigger size for prominence
              ),
            ),
            label: "",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
      ),
    );
  }
}