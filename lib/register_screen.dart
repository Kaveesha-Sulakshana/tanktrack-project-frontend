import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Center(
                  child: Text(
                    "NEW USER\nREGISTRATION",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Column(
                      children: [
                        _buildLabel("Name"),
                        _buildTextField("First Name"),
                        const SizedBox(height: 15),
                        _buildTextField("Last Name"),
                        const SizedBox(height: 20),
                        _buildLabel("Email"),
                        _buildTextField("Email"),
                        const SizedBox(height: 20),
                        _buildLabel("Mobile Number"),
                        _buildTextField("Mobile Number"),
                        const SizedBox(height: 20),
                        _buildLabel("Password"),
                        _buildTextField("Password", isPassword: true),
                        const SizedBox(height: 15),
                        _buildTextField("Confirm Password", isPassword: true),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (value) {},
                              activeColor: Colors.white,
                            ),
                            Expanded(
                              child: Text(
                                "Allow location access for personalized updates. Manage preferences anytime in settings. View our Privacy Policy for details.",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B43D6),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("REGISTER", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Colors.white60),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
