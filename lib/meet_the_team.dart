import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetTheTeamScreen extends StatelessWidget {
  const MeetTheTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 50, 45, 85)),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "TEAM TANK TRACK",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Icon(Icons.group, color: Colors.white, size: 28),
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
          color: const Color.fromARGB(108, 240, 194, 142),
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
              "Meet the talented developers behind project TANK TRACK.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamGrid() {
    final List<Map<String, String>> developers = [
      {
        'name': 'ASHEN',
        'role': '#THE_CHIEF',
        'github': 'https://github.com/alexchen',
        'linkedin': 'https://linkedin.com/in/alexchen',
      },
      {
        'name': 'MADUKA',
        'role': '#BACKEND_PHANTOM',
        'github': 'https://github.com/sophiarodriguez',
        'linkedin': 'https://linkedin.com/in/sophiarodriguez',
      },
      {
        'name': 'KAVEESHA',
        'role': '#UI_WIZARD',
        'github': 'https://github.com/marcusj',
        'linkedin': 'https://linkedin.com/in/marcusjohnson',
      },
      {
        'name': 'SHAVANTHA',
        'role': '#QUERY_MASTER',
        'github': 'https://github.com/priyapatel',
        'linkedin': 'https://linkedin.com/in/priyapatel',
      },
      {
        'name': 'HIRUSHI',
        'role': '#FRONTEND_DIVA',
        'github': 'https://github.com/davidkim',
        'linkedin': 'https://linkedin.com/in/davidkim',
      },
      {
        'name': 'SHARADHEE',
        'role': '#TECH_ENCHANTRESS',
        'github': 'https://github.com/kawyajayarathna',
        'linkedin':
            'https://www.linkedin.com/in/sharadee-jayarathna-9a0500337/',
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
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(108, 240, 194, 142),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: const Color.fromARGB(255, 50, 45, 85),
            child: Text(
              name[0],
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 240, 194, 142),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 50, 45, 85),
            ),
          ),
          Text(
            role,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color.fromARGB(255, 50, 45, 85),
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
      icon: Icon(
        icon,
        color: const Color.fromARGB(255, 240, 194, 142),
        size: 20,
      ),
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
    );
  }
}
