import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email & Password Login
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error (Email Sign-In): ${e.message}");
      return null;
    } catch (e) {
      print("❌ Unexpected error in Email Sign-In: $e");
      return null;
    }
  }

  // Google Sign-In (Fixed Type Mismatch Error)
  Future<User?> signInWithGoogle() async {
    try {
      // Ensure previous sessions are signed out
      await _googleSignIn.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("⚠️ Google Sign-In was cancelled by the user.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        print("✅ Google Sign-In successful!");
        print("User ID: ${user.uid}");
        print("User Email: ${user.email}");
        print("User Name: ${user.displayName}");
        print("User Photo: ${user.photoURL}");

        // Reload user to confirm existence in Firebase
        await user.reload();
        User? refreshedUser = FirebaseAuth.instance.currentUser;

        if (refreshedUser == null) {
          print(
            "❌ User record not found in Firebase after sign-in. Signing out.",
          );
          await signOut();
          return null;
        }

        return refreshedUser;
      } else {
        print("❌ Google Sign-In failed: No user found.");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error (Google Sign-In): ${e.message}");
      return null;
    } catch (e) {
      print("❌ Unexpected error in Google Sign-In: $e");
      return null;
    }
  }

  // Logout (Ensures Google & Firebase sign out)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("✅ User successfully signed out.");
    } catch (e) {
      print("❌ Error signing out: $e");
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in (Handles session reload properly)
  Future<bool> isUserLoggedIn() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Only reload if user exists
        return _auth.currentUser != null;
      }
    } catch (e) {
      print("❌ Error checking user login status: $e");
    }
    return false;
  }

  // Get user profile details safely
  Map<String, dynamic>? getUserProfile() {
    User? user = _auth.currentUser;
    if (user != null) {
      return {
        "uid": user.uid,
        "email": user.email ?? "No email",
        "displayName": user.displayName ?? "No name",
        "photoURL": user.photoURL ?? "No profile picture",
      };
    }
    return null;
  }
}
