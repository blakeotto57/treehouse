import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:treehouse/models/reviews_page.dart';
import 'package:treehouse/pages/messages_page.dart';

class OtherUsersProfilePage extends StatefulWidget {
  final String username;

  const OtherUsersProfilePage({super.key, required this.username});

  @override
  State<OtherUsersProfilePage> createState() => _OtherUsersProfilePageState();
}

class _OtherUsersProfilePageState extends State<OtherUsersProfilePage> {
  final usersCollection = FirebaseFirestore.instance.collection("users");

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black54,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent dismissal when tapping on image
                child: Hero(
                  tag: 'image_$imageUrl',
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.white, size: 48),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrink-wrap the content
                crossAxisAlignment: CrossAxisAlignment.center, // Center-align the content
                children: [
                  // Profile Card
                  Wrap(
                    alignment: WrapAlignment.center, // Center-align the content
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Shrink-wrap the content
                            crossAxisAlignment: CrossAxisAlignment.center, // Center-align the content
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                                backgroundColor: Colors.green[800],
                                child: profileImageUrl == null
                                    ? const Icon(Icons.person, size: 48, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                userData['username'] ?? widget.username,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              if (bio.isNotEmpty)
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 300), // Limit the width of the bio
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[900] : Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    bio,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53),
                                    ),
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              if (bio == null || bio.isEmpty)
                                Text(
                                  "No bio yet. Add one!",
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final currentUser = FirebaseAuth.instance.currentUser;
                                    final currentUserEmail = currentUser?.email;
                                    final profileUserEmail = userData['email'];

                                    if (currentUserEmail == profileUserEmail) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("You can't message yourself."),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MessagesPage(),
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
                      ),
                    ],
                  ),
                  // Listings and Reviews Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Listings Section
                      Expanded(
                        flex: 2,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          margin: const EdgeInsets.only(right: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                    final products = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: products.length,
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 200,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.8,
                                      ),
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        return Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: product['imageUrl'] != null
                                                        ? () => _showEnlargedImage(context, product['imageUrl'])
                                                        : null,
                                                    child: Hero(
                                                      tag: 'image_${product['imageUrl']}',
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: product['imageUrl'] != null
                                                            ? Image.network(
                                                                product['imageUrl'],
                                                                width: double.infinity,
                                                                height: double.infinity,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return Container(
                                                                    color: Colors.grey[200],
                                                                    child: const Icon(Icons.broken_image, size: 56, color: Colors.grey),
                                                                  );
                                                                },
                                                              )
                                                            : Container(
                                                                color: Colors.grey[200],
                                                                child: const Icon(Icons.image, size: 56, color: Colors.grey),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  product['name'] ?? 'No Name',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 4),
                                                if (product['category'] != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueGrey[50],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      product['category'],
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blueGrey,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  product['price'] != null ? '\$${product['price']}' : '',
                                                  style: const TextStyle(fontSize: 13, color: Colors.green),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  product['description'] ?? '',
                                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
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
                      ),
                      // Reviews Section
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          margin: const EdgeInsets.only(left: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Ratings & Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
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
                      ),
                    ],
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