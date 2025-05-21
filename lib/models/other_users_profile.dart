import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:treehouse/models/reviews_page.dart';
import '../pages/chat_page.dart';

class OtherUsersProfilePage extends StatefulWidget {
  final String username;

  const OtherUsersProfilePage({super.key, required this.username});

  @override
  State<OtherUsersProfilePage> createState() => _OtherUsersProfilePageState();
}

class _OtherUsersProfilePageState extends State<OtherUsersProfilePage> {
  final usersCollection = FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkBackground = const Color(0xFF181818);

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : pastelGreen,
      drawer: customDrawer(context),
      appBar: const Navbar(),
      body: FutureBuilder<QuerySnapshot>(
        future: usersCollection.where('username', isEqualTo: widget.username).limit(1).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return const Center(child: Text("Error loading user"));
          }
          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("User not found"));
          }

          final userDoc = userSnapshot.data!.docs.first;
          final userData = userDoc.data() as Map<String, dynamic>;
          final profileImageUrl = userData['profileImageUrl'];
          final email = userData['email'] ?? '';
          final bio = userData['bio'] ?? 'No bio available';
          final tags = userData['tags'] ?? ['App Development', 'Tutoring', 'UI/UX Design'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                            backgroundColor: Colors.green[800],
                            child: profileImageUrl == null
                                ? const Icon(Icons.person, size: 48, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userData['username'] ?? widget.username,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(bio, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: List.generate(
                                    tags.length,
                                    (i) => Chip(
                                      label: Text(tags[i], style: const TextStyle(fontSize: 13)),
                                      backgroundColor: Colors.green[50],
                                      labelStyle: const TextStyle(color: Color(0xFF386A53)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            receiverEmail: userData['email'] ?? '',
                                            receiverID: userDoc.id,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF386A53),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                    ),
                                    child: const Text("Message", style: TextStyle(fontSize: 16, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Listings Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("My Listings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: usersCollection.doc(userDoc.id).collection('products').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Text("No listings found.");
                              }
                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final imageUrl = data['imageUrl'] as String?;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 220, // Set your desired card width here
                                        child: Card(
                                          margin: const EdgeInsets.symmetric(vertical: 12),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (imageUrl != null && imageUrl.isNotEmpty)
                                                  Container(
                                                    height: 140,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.contain,
                                                        alignment: Alignment.center,
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  data['name'] ?? '',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  data['description'] ?? '',
                                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "\$${(data['price'] is num) ? (data['price'] as num).toStringAsFixed(2) : data['price'] ?? '0.00'}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Reviews Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ratings & Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          // TODO: Replace with actual reviews
                          Column(
                            children: const [
                              ListTile(
                                title: Text("Maria L.", style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Great tutoring session, super helpful! ⭐⭐⭐⭐⭐"),
                              ),
                              ListTile(
                                title: Text("Josh K.", style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Quick turnaround and great UI suggestions. ⭐⭐⭐⭐☆"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}