import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/pages/landing_page.dart';
import 'package:treehouse/pages/explore_page.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

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
                  // Email exists in Firestore -> Navigate to Explore Page
                  return const ExplorePage();
                } else {
                  // Email not found -> Show landing page
                  return const LandingPage();
                }
              },
            );
          } else {
            // User is not logged in -> Show Landing Page
            return const LandingPage();
          }
        },
      ),
    );
  }
}

