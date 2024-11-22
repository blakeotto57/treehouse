import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Global user ID
String? globaluserid;

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (globaluserid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Seller Profile')),
        body: const Center(
          child: Text('No user logged in. Please log in to view the profile.'),
          
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(title: const Text('Seller Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future: loadSellerProfile(globaluserid!), // Fetch the profile data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading indicator
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            ); // Display error message
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Seller profile not found.'),
            ); // No data found
          }

          // Extracting data from the seller profile document
          final sellerData = snapshot.data!.data() as Map<String, dynamic>?;

          if (sellerData == null) {
            return const Center(
              child: Text('No profile data available.'),
            );
          }

          // Extract individual fields with null checks
          final String name = sellerData['name'] ?? 'No Name Provided';
          final String email = sellerData['email'] ?? 'No Email Provided';
          final String bio = sellerData['bio'] ?? 'No Bio Provided';
          final String profilePicture = sellerData['profilePicture'] ?? ''; // Empty if not available

          // Display seller profile information
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePicture.isNotEmpty
                        ? NetworkImage(profilePicture)
                        : null,
                    child: profilePicture.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('Email: $email'),
                const SizedBox(height: 16),
                Text('Bio: $bio'),
                const SizedBox(height: 16),
                // Add additional profile fields or features as needed
              ],
            ),
          );
        },
      ),
    );
  }

  // Fetch the seller profile based on the userId
  Future<DocumentSnapshot> loadSellerProfile(String userId) async {
    try {
      final DocumentSnapshot sellerProfile = await FirebaseFirestore.instance
          .collection('sellers') // Ensure the collection name matches your database
          .doc(userId) // Fetch the document using the userId
          .get();
      return sellerProfile;
    } catch (e) {
      print('Error loading seller profile: $e');
      rethrow; // Propagate the error to FutureBuilder for display
    }
  }
}
