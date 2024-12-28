import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Initialize GoogleSignIn with clientId
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '526021589495-5l2ljdaccum9digjrfnhqoalbos47qot.apps.googleusercontent.com',
  );
  // Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the Google Sign-In
        return null;
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Log In
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Log Out
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
