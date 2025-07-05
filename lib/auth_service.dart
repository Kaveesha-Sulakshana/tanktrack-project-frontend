import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  
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

  
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); 

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

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

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        print("✅ Google Sign-In successful!");
        print("User ID: ${user.uid}");
        print("User Email: ${user.email}");
        print("User Name: ${user.displayName}");
        print("User Photo: ${user.photoURL}");

       
        String? firebaseToken = await getFirebaseToken();
        print("🔥 Firebase ID Token: $firebaseToken");

        return user; 
      } else {
        print(" Google Sign-In failed: No user found.");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("\ Firebase Auth Error (Google Sign-In): ${e.message}");
      return null;
    } catch (e) {
      print(" Unexpected error in Google Sign-In: $e");
      return null;
    }
  }

  
  Future<String?> getFirebaseToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String? token = await user.getIdToken(true);
      print(" Firebase ID Token (Separate Request): $token");
      return token;
    } else {
      print(" No user logged in.");
      return null;
    }
  }

 
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print(" User successfully signed out.");
    } catch (e) {
      print(" Error signing out: $e");
    }
  }

  
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  
  Future<bool> isUserLoggedIn() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return _auth.currentUser != null;
      }
    } catch (e) {
      print(" Error checking user login status: $e");
    }
    return false;
  }

 
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
