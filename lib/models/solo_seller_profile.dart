import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/models/reviews_page.dart';
import '../pages/chat_page.dart';

class SoloSellerProfilePage extends StatefulWidget {
  final String userId;

  const SoloSellerProfilePage({super.key, required this.userId});

  @override
  State<SoloSellerProfilePage> createState() => _SoloSellerProfilePageState();
}

class _SoloSellerProfilePageState extends State<SoloSellerProfilePage> {
  final sellersCollection = FirebaseFirestore.instance.collection("sellers");
  final usersCollection = FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Seller Profile",
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            tooltip: 'Message Seller',
            onPressed: () {
              sellersCollection.doc(widget.userId).get().then((doc) {
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
        stream: sellersCollection.doc(widget.userId).snapshots(),
        builder: (context, sellerSnapshot) {
          if (sellerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sellerSnapshot.hasError) {
            return const Center(child: Text("Error loading seller data"));
          }

          if (sellerSnapshot.hasData && sellerSnapshot.data != null) {
            final sellerData = sellerSnapshot.data!.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: usersCollection
                  .where("email", isEqualTo: sellerData['email'])
                  .limit(1)
                  .get()
                  .then((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : throw Exception('No user found')),
              builder: (context, userSnapshot) {
                String? profileImageUrl;

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasData && userSnapshot.data != null) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  profileImageUrl = userData['profileImageUrl'];
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.green[300],
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Seller Email
                      Text(
                        sellerData['email'] ?? 'Unknown Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                           
                
                          // View Reviews Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                              "Reviews",
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                          ),
                        ],
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
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
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
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
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
              },
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
