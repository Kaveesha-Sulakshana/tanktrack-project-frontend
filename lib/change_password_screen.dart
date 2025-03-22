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
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  String errorMessage = "";

  Future<void> _changePassword() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "New password and confirm password do not match!";
        isLoading = false;
      });
      return;
    }

    try {
      // Re-authenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPasswordController.text,
      );

      await user!.reauthenticateWithCredential(credential);

      // Update Firebase Password
      await user!.updatePassword(newPasswordController.text);

      // 🔹 Call MongoDB API to update password in backend
      await _updateMongoDBPassword();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _getFirebaseErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error updating password: $e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  /// 🔹 Function to update the password in MongoDB
  Future<void> _updateMongoDBPassword() async {
    try {
      print("Updating password in MongoDB...");
      String? token = await user?.getIdToken();
      final response = await http.put(
        Uri.parse("http://localhost:8080/auth/update-password?"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "email": user?.email,
          "newPassword": newPasswordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);
      print("MongoDB Response: ${response.body}");

      if (response.statusCode != 200 || responseData['status'] != 'success') {
        throw Exception(
          responseData['message'] ?? "Failed to update MongoDB password.",
        );
      }
    } catch (e) {
      print("MongoDB Update Failed: $e");
      setState(() {
        errorMessage = "MongoDB update failed: $e";
      });
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'wrong-password':
        return "The old password is incorrect.";
      case 'user-not-found':
        return "User not found. Please log in again.";
      case 'requires-recent-login':
        return "Please log in again before changing your password.";
      default:
        return "An error occurred. Please try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 50, 45, 85),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPasswordField(
                          "Old Password",
                          oldPasswordController,
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          "New Password",
                          newPasswordController,
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          "Confirm Password",
                          confirmPasswordController,
                        ),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                        const SizedBox(height: 15),
                        if (errorMessage.isNotEmpty) _buildErrorMessage(),
                      ],
                    ),
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            "Change Password",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(247, 240, 194, 142),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : _changePassword,
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  "Save Password",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 72, 66, 109),
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
