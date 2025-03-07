import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool agreeToTerms = false;

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
                    onPressed: () => Navigator.pop(context), // Navigate back to Login
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
                        _buildLabel("First Name"),
                        _buildTextField("First Name", controller: firstNameController),
                        const SizedBox(height: 15),
                        _buildLabel("Last Name"),
                        _buildTextField("Last Name", controller: lastNameController),
                        const SizedBox(height: 20),
                        _buildLabel("Email"),
                        _buildTextField("Email", controller: emailController),
                        const SizedBox(height: 20),
                        _buildLabel("Mobile Number"),
                        _buildTextField("Mobile Number", controller: phoneController),
                        const SizedBox(height: 20),
                        _buildLabel("Password"),
                        _buildTextField("Password", controller: passwordController, isPassword: true),
                        const SizedBox(height: 15),
                        _buildTextField("Confirm Password", controller: confirmPasswordController, isPassword: true),
                        const SizedBox(height: 10),

                        // ✅ Checkbox for Terms and Conditions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  agreeToTerms = value ?? false;
                                });
                              },
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

                        // ✅ Register Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B43D6),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          onPressed: () {
                            if (agreeToTerms) {
                              _registerUser();
                            } else {
                              _showMessage("Please accept the terms and conditions.");
                            }
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

  /// **Handles User Registration**
  void _registerUser() {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("All fields are required.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match.");
      return;
    }

    // ✅ Simulating registration (Replace with Firebase Auth)
    _showMessage("Registered successfully! Redirecting...");
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Redirect to Login
    });
  }

  /// **Displays a SnackBar Message**
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: const Color.fromARGB(255, 0, 255, 34),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// **Reusable Text Field Widget**
  Widget _buildTextField(String hint, {bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
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

  /// **Reusable Label Widget**
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
