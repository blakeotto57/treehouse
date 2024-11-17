import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfilePage extends StatelessWidget {
  final String sellerId;

  // Ensure sellerId is passed correctly via the constructor
  const SellerProfilePage({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('sellers').doc(sellerId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Seller profile not found.'));
          }

          final sellerData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Profile Picture (if available)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: sellerData['profilePicture'] != null
                        ? NetworkImage(sellerData['profilePicture'])
                        : null,
                    child: sellerData['profilePicture'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Seller Name
                Text(
                  sellerData['name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Email
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(
                    sellerData['email'] ?? 'No Email',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Phone
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    sellerData['phone'] ?? 'No Phone',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Description
                const Text(
                  'About the Seller:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sellerData['description'] ?? 'No Description',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
