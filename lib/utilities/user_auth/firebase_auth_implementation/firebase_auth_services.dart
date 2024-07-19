import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in a user with the provided email and password.
  ///
  /// Returns the signed-in [User] if successful, or `null` if an error occurs.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign in with email and password: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('An unknown error occurred: $e');
      return null;
    }
  }

  /// Signs up a new user with the provided email and password.
  ///
  /// Returns the created [User] if successful, or `null` if an error occurs.
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign up with email and password: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('An unknown error occurred: $e');
      return null;
    }
  }

  /// Signs out the currently signed-in user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Failed to sign out: $e');
    }
  }

  /// Returns the currently signed-in [User], or `null` if no user is signed in.
  Future<User?> getCurrentUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Failed to get current user: $e');
      return null;
    }
  }
}
