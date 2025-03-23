import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 50, 45, 85),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),

              // Premium Features Text
              Text(
                "Premium Features",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Premium Image (Stars)
              Image.asset("assets/premium.png", width: 150),

              const SizedBox(height: 20),

              // Upgrade to Premium Text
              Text(
                "Upgrade to Premium",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                "Unlimited tank monitoring, Custom reports\nand so more!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),

              const SizedBox(height: 30),

              // Feature List Box
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem("Unlimited tank monitoring"),
                    _buildFeatureItem("Automated maintenance reminders"),
                    _buildFeatureItem("Customizable tank reports"),
                    const SizedBox(height: 20),
                    // Subscription Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B43D6),
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Monthly / \$9.99",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Feature List Item Builder
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
