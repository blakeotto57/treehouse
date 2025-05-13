import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/auth/login_or_register.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<bool> checkUserEmailInFirestore(String email) async {
    // Query Firestore for a document where the 'email' matches
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // If at least one document exists, return true
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if the user is logged in
          if (snapshot.hasData && snapshot.data != null) {
            final userEmail = snapshot.data!.email;

            return FutureBuilder<bool>(
              future: checkUserEmailInFirestore(userEmail!),
              builder: (context, firestoreSnapshot) {
                if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (firestoreSnapshot.hasData && firestoreSnapshot.data == true) {
                  // Email exists in Firestore -> Navigate to Home Page
                  return ExplorePage();
                } else {
                  // Email not found -> Show error or redirect to Login/Register
                  return const LoginOrRegister();
                }
              },
            );
          } else {
            // User is not logged in -> Go to Login/Register
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
