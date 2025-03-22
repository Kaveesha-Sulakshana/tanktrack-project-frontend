import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isChecked = false;
  bool showErrorMessage = false;
  bool isLoading = false;
  String errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        showErrorMessage = true;
        errorMessage = "Fill all fields correctly";
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Register user in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Send data to MongoDB
      await _sendDataToMongoDB(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Navigate to home screen or show success message
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        errorMessage = "Registration failed: ${error.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendDataToMongoDB(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    const String apiUrl =
        "http://10.0.2.2:8080/auth/register"; // Use this for emulator

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("User registered successfully in MongoDB");
      } else {
        print("Failed to register user in MongoDB: ${response.body}");
      }
    } catch (e) {
      print("Error sending data to MongoDB: $e");
    }
  }

  bool _isFormFilled() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 72, 66, 109),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Center(
                    child: Text(
                      "TANK TRACK USER\nREGISTRATION",
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
                        color: const Color.fromARGB(110, 240, 194, 142),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Column(
                        children: [
                          _buildLabel("Name"),
                          _buildTextField("First Name", firstNameController),
                          const SizedBox(height: 15),
                          _buildTextField("Last Name", lastNameController),
                          const SizedBox(height: 20),
                          _buildLabel("Email"),
                          _buildTextField("Email", emailController),
                          const SizedBox(height: 20),
                          _buildLabel("Mobile Number"),
                          _buildTextField("Mobile Number", mobileController),
                          const SizedBox(height: 20),
                          _buildLabel("Password"),
                          _buildTextField(
                            "Password",
                            passwordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            "Confirm Password",
                            confirmPasswordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value!;
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
                          if (errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                49,
                                44,
                                81,
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            onPressed: _isFormFilled() ? _registerUser : null,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      "REGISTER",
                                      style: TextStyle(color: Colors.white),
                                    ),
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
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Colors.white60),
        ),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? "This field is required" : null,
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
