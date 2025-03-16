import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String email = user.email ?? "";
    String oldPassword = oldPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackbar("⚠️ All fields are required!");
      return;
    }

    if (newPassword.length < 6) {
      _showErrorSnackbar("⚠️ Password must be at least 6 characters!");
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackbar("⚠️ New passwords do not match!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Update Password in MongoDB
      final response = await http.put(
        Uri.parse(
          "http://10.0.2.2:8080/auth/update-password?"
          "email=$email&Password=$oldPassword&newPassword=$newPassword",
        ),
        headers: {"Content-Type": "application/json"},
      );

      print("🔹 Response Status Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Step 2: Reauthenticate User in Firebase
        await _reauthenticateUser(email, oldPassword);

        // Step 3: Update Firebase Password
        await _updateFirebasePassword(newPassword);

        _showSuccessSnackbar("✅ Password successfully changed!");
        Navigator.pop(context); // Navigate back on success
      } else {
        final responseBody = jsonDecode(response.body);
        _showErrorSnackbar("❌ ${responseBody['message']}");
      }
    } catch (e) {
      print("❌ Error: $e");
      _showErrorSnackbar("❌ Network error! Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _reauthenticateUser(String email, String oldPassword) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        credential,
      );
      print("✅ User reauthenticated successfully.");
    } catch (e) {
      print("❌ Reauthentication error: $e");
      _showErrorSnackbar("❌ Old password is incorrect (Firebase).");
      throw e;
    }
  }

  Future<void> _updateFirebasePassword(String newPassword) async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      print("✅ Firebase password updated successfully.");
    } catch (e) {
      print("❌ Firebase password update error: $e");
      _showErrorSnackbar("❌ Failed to update password in Firebase.");
      throw e;
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              "Old Password",
              oldPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              "New Password",
              newPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              "Confirm Password",
              confirmPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isLoading
                ? null
                : () async {
                  await _changePassword();
                },
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save Password"),
      ),
    );
  }
}
