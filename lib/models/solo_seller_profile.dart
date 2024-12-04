import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart'; // Import the ChatPage here

class SoloSellerProfilePage extends StatefulWidget {
  final String userId;

  const SoloSellerProfilePage({super.key, required this.userId});

  @override
  State<SoloSellerProfilePage> createState() => _SoloSellerProfilePageState();
}

class _SoloSellerProfilePageState extends State<SoloSellerProfilePage> {
  final usersCollection = FirebaseFirestore.instance.collection("sellers");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Seller Profile"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // Fetch seller's email and pass it to the ChatPage
              usersCollection.doc(widget.userId).get().then((doc) {
                if (doc.exists) {
                  final sellerData = doc.data() as Map<String, dynamic>;
                  final sellerEmail = sellerData['email'] ?? 'Unknown Email';

                  // Navigate to the ChatPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverEmail: sellerEmail,
                        receiverID: widget.userId,
                      ),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading user data"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.person, size: 72),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    userData['email'] ?? 'Unknown Email',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Seller Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData['description'] ?? 'No description available.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Previous Work",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Add image gallery or other components as required
              ],
            );
          }

          return const Center(
            child: Text("User data not available"),
          );
        },
      ),
    );
  }
}
