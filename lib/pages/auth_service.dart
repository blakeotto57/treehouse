import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/models/seller_profile.dart'; // Import your profile page
import 'package:treehouse/pages/login_page.dart'; // Import the login page

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Handle login with email and password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Handle logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Decide whether to show the login or profile page based on user authentication
  Widget handleAuth(BuildContext context) {
    User? user = _auth.currentUser;
    if (user != null) {
      // Pass user information to the profile page
      return SellerProfilePage(
        userId: user.uid,
      );
    } else {
      return LoginPage(); // Show login page if user is not authenticated
    }
  }
}
