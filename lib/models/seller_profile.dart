import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/models/seller_setup.dart';

class SellerProfilePage extends StatelessWidget {
  final String sellerId;

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
            // If seller profile is not found
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Seller profile not found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Seller Setup Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SellerSetupPage()),
                      );
                    },
                    child: const Text('Become a Seller'),
                  ),
                ],
              ),
            );
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
