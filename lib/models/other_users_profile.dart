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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                final products = snapshot.data!.docs;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 2.5,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, idx) {
                                    final product = products[idx].data() as Map<String, dynamic>;
                                    return Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'],
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              product['price'].toString(),
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product['description'],
                                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (product['price'] != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  "\$${product['price']}",
                                                  style: const TextStyle(
                                                    color: Color(0xFF386A53),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
            ),
          );
        },
      ),
    );
  }
}