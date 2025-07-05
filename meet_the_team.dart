import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetTheTeamScreen extends StatelessWidget {
  const MeetTheTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 18, 82, 177),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildHeaderSection(),
              Expanded(
                child: _buildTeamGrid(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Top AppBar Section
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logomark.png', height: 40),
          const Text(
            "Meet The Team",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Header Section
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Text(
              "Our Development Team",
              style: TextStyle(
                color: Color.fromARGB(255, 2, 46, 111),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Meet the talented developers behind this application",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(1),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Team Grid Section
  Widget _buildTeamGrid() {
    final List<Map<String, String>> developers = [
      {
        'name': 'Alex Chen',
        'role': 'Lead Developer',
        'github': 'https://github.com/alexchen',
        'avatar': 'assets/dev1.png',
      },
      {
        'name': 'Sophia Rodriguez',
        'role': 'UI/UX Designer',
        'github': 'https://github.com/sophiarodriguez',
        'avatar': 'assets/dev2.png',
      },
      {
        'name': 'Marcus Johnson',
        'role': 'Backend Developer',
        'github': 'https://github.com/marcusj',
        'avatar': 'assets/dev3.png',
      },
      {
        'name': 'Priya Patel',
        'role': 'Mobile Developer',
        'github': 'https://github.com/priyapatel',
        'avatar': 'assets/dev4.png',
      },
      {
        'name': 'David Kim',
        'role': 'Database Engineer',
        'github': 'https://github.com/davidkim',
        'avatar': 'assets/dev5.png',
      },
      {
        'name': 'Emma Wilson',
        'role': 'QA Engineer',
        'github': 'https://github.com/emmawilson',
        'avatar': 'assets/dev6.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        itemCount: developers.length,
        itemBuilder: (context, index) {
          return _buildDeveloperCard(
            name: developers[index]['name']!,
            role: developers[index]['role']!,
            githubUrl: developers[index]['github']!,
            avatarPath: developers[index]['avatar']!,
          );
        },
      ),
    );
  }

  // Developer Card Widget
  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required String githubUrl,
    required String avatarPath,
  }) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(githubUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  avatarPath,
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 60, color: Color.fromARGB(255, 18, 82, 177));
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                color: Color.fromARGB(255, 2, 46, 111),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              role,
              style: TextStyle(
                color: Colors.white.withOpacity(1),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  "GitHub Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color.fromARGB(255, 9, 38, 82),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: 0,
      onTap: (index) {
        if (index != 0) {
          Navigator.pop(context);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Team"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}