import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:treehouse/models/seller_profile.dart';




class PersonalCareSellersPage extends StatelessWidget {
  const PersonalCareSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

          final sellers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index].data() as Map<String, dynamic>;
              final sellerId = sellers[index].id;
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
                    seller['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(seller['description'] ?? 'No description provided.'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to seller profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerProfilePage(
                          sellerId: sellerId,
                          currentUserId: '<CUSTOMER_ID>', // Pass customer ID dynamically
                        ),
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