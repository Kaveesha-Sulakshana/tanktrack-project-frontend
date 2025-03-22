import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetTheTeamScreen extends StatelessWidget {
  const MeetTheTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3C3B6E),
              Color(0xFF1B1A35),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeaderSection(),
                      _buildTeamGrid(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.group, color: Colors.white, size: 28),
          Text(
            "Meet The Team",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              "Our Development Team",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Meet the talented developers behind this application.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamGrid() {
    final List<Map<String, String>> developers = [
      {
        'name': 'Alex Chen',
        'role': 'Lead Developer',
        'github': 'https://github.com/alexchen',
        'linkedin': 'https://linkedin.com/in/alexchen',
        'avatar': 'assets/dev1.png',
      },
      {
        'name': 'Sophia Rodriguez',
        'role': 'UI/UX Designer',
        'github': 'https://github.com/sophiarodriguez',
        'linkedin': 'https://linkedin.com/in/sophiarodriguez',
        'avatar': 'assets/dev2.png',
      },
      {
        'name': 'Marcus Johnson',
        'role': 'Backend Developer',
        'github': 'https://github.com/marcusj',
        'linkedin': 'https://linkedin.com/in/marcusjohnson',
        'avatar': 'assets/dev3.png',
      },
      {
        'name': 'Priya Patel',
        'role': 'Mobile Developer',
        'github': 'https://github.com/priyapatel',
        'linkedin': 'https://linkedin.com/in/priyapatel',
        'avatar': 'assets/dev4.png',
      },
      {
        'name': 'David Kim',
        'role': 'Database Engineer',
        'github': 'https://github.com/davidkim',
        'linkedin': 'https://linkedin.com/in/davidkim',
        'avatar': 'assets/dev5.png',
      },
      {
        'name': 'Emma Wilson',
        'role': 'QA Engineer',
        'github': 'https://github.com/emmawilson',
        'linkedin': 'https://linkedin.com/in/emmawilson',
        'avatar': 'assets/dev6.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: developers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final dev = developers[index];
          return _buildDeveloperCard(
            name: dev['name']!,
            role: dev['role']!,
            githubUrl: dev['github']!,
            linkedinUrl: dev['linkedin']!,
            avatarPath: dev['avatar']!,
          );
        },
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required String githubUrl,
    required String linkedinUrl,
    required String avatarPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: ClipOval(
              child: Image.asset(
                avatarPath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 50, color: Colors.white70);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            role,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Icons.code, githubUrl),
              const SizedBox(width: 10),
              _buildIconButton(Icons.work, linkedinUrl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 20),
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
    );
  }
}
