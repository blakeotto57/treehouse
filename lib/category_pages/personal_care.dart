import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/solo_seller_profile.dart';

class PersonalCareSellersPage extends StatelessWidget {
  const PersonalCareSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Care Sellers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[300],
        centerTitle: true,
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
            return const Center(
              child: Text(
                'No sellers found in this category.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final sellers = snapshot.data!.docs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['email'] != currentUserEmail;
              })
              .toList();

          if (sellers.isEmpty) {
            return const Center(
              child: Text(
                'No other sellers found in this category.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index].data() as Map<String, dynamic>;
              final userId = sellers[index].id;
              final email = seller['email'] ?? 'Unknown';
              final username = email.contains('@') ? email.split('@')[0] : email;

              return SellerCard(
                userId: userId,
                username: username,
                description: seller['description'] ?? 'No description provided.',
                profilePicture: seller['profilePicture'],
              );
            },
          );
        },
      ),
    );
  }
}

class SellerCard extends StatelessWidget {
  final String userId;
  final String username;
  final String description;
  final String? profilePicture;

  const SellerCard({
    Key? key,
    required this.userId,
    required this.username,
    required this.description,
    this.profilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: profilePicture != null ? NetworkImage(profilePicture!) : null,
          child: profilePicture == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
          backgroundColor: profilePicture == null ? Colors.green[300] : null,
        ),
        title: Text(
          username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SoloSellerProfilePage(userId: userId),
            ),
          );
        },
      ),
    );
  }
}
