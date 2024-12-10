import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/models/reviews_page.dart';
import 'chat_page.dart';
import 'reviews_page.dart'; // Import the SellerReviewsPage

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Seller Profile"),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            tooltip: 'Message Seller',
            onPressed: () {
              usersCollection.doc(widget.userId).get().then((doc) {
                if (doc.exists) {
                  final sellerData = doc.data() as Map<String, dynamic>;
                  final sellerEmail = sellerData['email'] ?? 'Unknown Email';

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
            return const Center(child: Text("Error loading seller data"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final sellerData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[300],
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seller Email
                  Text(
                    sellerData['email'] ?? 'Unknown Email',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),


                    // View Reviews Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewsPage(sellerId: widget.userId),
                        ),
                      );
                    },
                    child: const Text(
                      "View Reviews",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),


                  // Seller Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Seller Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          sellerData['description'] ?? 'No description provided.',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Previous Work Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Previous Work",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Placeholder for image gallery
                        sellerData['workImages'] != null
                            ? SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: (sellerData['workImages'] as List).length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          sellerData['workImages'][index],
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text(
                                "No previous work available.",
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }

          return const Center(
            child: Text("Seller data not available."),
          );
        },
      ),
    );
  }
}
