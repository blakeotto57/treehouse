import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfilePage extends StatelessWidget {
  final String userId;  // Passed as an argument to the page

  const SellerProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seller Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future: loadSellerProfile(userId),  // Fetch the profile data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading indicator
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Seller profile not found."));  // No data found
          }

          // Extracting data from the seller profile document
          var sellerData = snapshot.data!.data() as Map<String, dynamic>?;

          if (sellerData == null) {
            return Center(child: Text('No profile data available.'));
          }

          // Print the seller data to debug and ensure it's correctly loaded
          print("Seller data: $sellerData");

          // Extract individual fields with null checks
          String name = sellerData['name'] ?? 'No Name Provided';
          String email = sellerData['email'] ?? 'No Email Provided';
          String bio = sellerData['bio'] ?? 'No Bio Provided';
          String profilePicture = sellerData['profilePicture'] ?? ''; // Empty string if not available

          // Displaying seller profile information
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
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text('Email: $email'),
                SizedBox(height: 16),
                Text('Bio: $bio'),
                SizedBox(height: 16),
                // Add other profile fields as needed
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
      DocumentSnapshot sellerProfile = await FirebaseFirestore.instance
          .collection('sellers') // Make sure the collection name is correct
          .doc(userId)  // Use the username or userId to fetch the document
          .get();
      return sellerProfile;
    } catch (e) {
      print("Error loading seller profile: $e");
      throw e;
    }
  }
}
