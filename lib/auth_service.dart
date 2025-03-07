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
    } catch (e) {
      print("Error in Email Sign-In: $e");
      return null;
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      // Attempt Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled login

      // Authenticate Google user
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Get the signed-in user
      User? user = userCredential.user;

      // Print user details for debugging
      print("Google Sign-In successful!");
      print("User ID: ${user?.uid}");
      print("User Email: ${user?.email}");
      print("User Name: ${user?.displayName}");
      print("User Photo: ${user?.photoURL}");

      return user;
    } catch (e, stacktrace) {
      print("Error in Google Sign-In: $e");
      print("Stacktrace: $stacktrace");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print("User successfully signed out.");
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user profile details
  Map<String, dynamic>? getUserProfile() {
    User? user = _auth.currentUser;
    if (user != null) {
      return {
        "uid": user.uid,
        "email": user.email,
        "displayName": user.displayName,
        "photoURL": user.photoURL,
      };
    }
    return null;
  }
}
