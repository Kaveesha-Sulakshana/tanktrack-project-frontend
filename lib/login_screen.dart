import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signInWithEmail() async {
    try {
      User? user = await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login failed. Check your credentials."),
          ),
        );
      }
    } catch (e) {
      print("Error logging in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error logging in. Please try again.")),
      );
    }
  }

  void _signInWithGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();

      if (user != null) {
        String? idToken = await user.getIdToken();
        print("Google Sign-In Token: $idToken");

        // Send token to backend
        await _sendTokenToBackend(idToken!);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Google Sign-In failed.")));
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    const String backendUrl = "http://10.0.2.2:8080/auth/google-login";
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Token successfully sent to backend.");
      } else {
        print("❌ Failed to send token. Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("🚨 Error sending token to backend: $e");
    }
  }

  // ✅ FUNCTION: Forgot Password Logic
  Future<void> _resetPassword() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset link sent to email.")),
      );

      // ✅ UPDATE PASSWORD IN MONGODB
      await _updateMongoDBPassword(email);
    } catch (e) {
      print("Error resetting password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error resetting password. Try again.")),
      );
    }
  }

  // ✅ FUNCTION: Update Password in MongoDB after Firebase Reset
  Future<void> _updateMongoDBPassword(String email) async {
    const String backendUrl = "http://10.0.2.2:8080/auth/update-password";

    try {
      final response = await http.put(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        print("✅ Password updated in MongoDB.");
      } else {
        print("❌ Failed to update MongoDB. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Error updating MongoDB: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 72, 66, 109),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  "LOGIN TO\nTANK TRACK",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset("assets/loginlogo.png", width: 120),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(110, 240, 194, 142),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Enter your login information",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _resetPassword,
                        child: const Text(
                          "Forgot Password ?",
                          style: TextStyle(
                            color: Color.fromARGB(255, 240, 194, 142),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 49, 44, 81),
                          minimumSize: const Size(350, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _signInWithEmail,
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(350, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _signInWithGoogle,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage('assets/google_logo.png'),
                              height: 52,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Sign in with Google",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register now",
                              style: TextStyle(
                                color: Color.fromARGB(255, 240, 194, 142),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
