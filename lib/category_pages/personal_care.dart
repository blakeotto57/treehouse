import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/solo_seller_profile.dart';

class PersonalCareSellersPage extends StatelessWidget {
  const PersonalCareSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Current user email
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Care Sellers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sellers')
            .where('category', isEqualTo: 'Personal Care')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No sellers found in this category.'));
          }

          // Filter out the current user's document based on email
          final sellers = snapshot.data!.docs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['email'] != currentUserEmail;
              })
              .toList();

          if (sellers.isEmpty) {
            return const Center(
              child: Text('No other sellers found in this category.'),
            );
          }

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index].data() as Map<String, dynamic>;
              final userId = sellers[index].id;
              final email = seller['email'] ?? 'Unknown';
              final username = email.contains('@') ? email.split('@')[0] : email;
              

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: seller['profilePicture'] != null
                        ? NetworkImage(seller['profilePicture'])
                        : null,
                    child: seller['profilePicture'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(seller['description'] ?? 'No description provided.'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to SoloSellerProfilePage and pass the seller's userId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SoloSellerProfilePage(userId: userId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
