import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tank Track',
      theme: ThemeData.dark(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _checkUserExists(User? user) async {
    if (user == null) return false;
    try {
      // Reload user to check if it still exists in Firebase
      await user.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        // If FirebaseAuth doesn't return a user, it means the account was deleted
        await FirebaseAuth.instance.signOut();
        return false;
      }
      return true;
    } catch (e) {
      print("Error checking user existence: $e");
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _checkUserExists(snapshot.data),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (asyncSnapshot.hasData && asyncSnapshot.data == true) {
                return const HomeScreen();
              } else {
                return const SplashScreen();
              }
            },
          );
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}
