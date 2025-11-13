import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/professional_navbar.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/components/profile_avatar.dart';

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
        backgroundColor: Colors.transparent,
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
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error,
                                color: Colors.white, size: 48),
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

  Future<void> onMessageButtonPressed(
      BuildContext context, String profileEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserEmail = currentUser.email!;
    if (currentUserEmail == profileEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't message yourself")),
      );
      return;
    }

    // Create chat ID using both emails
    List<String> ids = [currentUserEmail, profileEmail];
    ids.sort();
    String chatId = ids.join('_');

    // Create chat document if it doesn't exist
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatDoc.get();
    if (!chatSnapshot.exists) {
      await chatDoc.set({
        'participants': ids,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Add each user to the other's accepted_chats
    final batch = FirebaseFirestore.instance.batch();
    batch.set(
      FirebaseFirestore.instance
          .collection('accepted_chats')
          .doc(currentUserEmail)
          .collection('users')
          .doc(profileEmail),
      {'email': profileEmail, 'timestamp': Timestamp.now()},
    );
    batch.set(
      FirebaseFirestore.instance
          .collection('accepted_chats')
          .doc(profileEmail)
          .collection('users')
          .doc(currentUserEmail),
      {'email': currentUserEmail, 'timestamp': Timestamp.now()},
    );
    await batch.commit();

    // Navigate to MessagesPage and select the chat
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => MessagesPage(
          initialSelectedUserEmail: profileEmail, // Pass Bob's email
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkBackground = const Color(0xFF181818);
    final currentUsername = FirebaseAuth.instance.currentUser?.displayName;
    final GlobalKey<SlidingDrawerState> _drawerKey = GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: customDrawer(context),
        appBar: ProfessionalNavbar(drawerKey: _drawerKey),
        body: Stack(
        children: [
          FutureBuilder<QuerySnapshot>(
            future: usersCollection
                .where('username', isEqualTo: widget.username)
                .limit(1)
                .get(),
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
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the content vertically
                  mainAxisSize: MainAxisSize.min, // Shrink-wrap the content
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center-align the content
                  children: [
                    // Profile Card
                    Wrap(
                      alignment: WrapAlignment.center, // Center-align the content
                      children: [
                        //profile card
                        Card(
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(top: 16, bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ProfileAvatar(
                                  photoUrl: profileImageUrl,
                                  userEmail: userData['email'] as String?,
                                  displayName: userData['username'] ?? '',
                                  radius: 48,
                                  showOnlineStatus: true,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  userData['username'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF386A53),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userData['email'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (bio != null && bio.isNotEmpty)
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.grey[900]
                                          : Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      bio,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF386A53),
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
                                      color: isDarkMode
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: 160,
                                  height: 38,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.message, size: 20),
                                    label: const Text("Message"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF386A53),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      final profileEmail = userData['email'];
                                      onMessageButtonPressed(context, profileEmail);
                                    },
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            margin: const EdgeInsets.only(right: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("My Listings",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: usersCollection
                                        .doc(userDoc.id)
                                        .collection('products')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return const Text("No listings found.");
                                      }
                                      final products = snapshot.data!.docs
                                          .map((doc) =>
                                              doc.data() as Map<String, dynamic>)
                                          .toList();
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: products.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 0.8,
                                        ),
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          return Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: product['imageUrl'] !=
                                                              null
                                                          ? () =>
                                                              _showEnlargedImage(
                                                                  context,
                                                                  product[
                                                                      'imageUrl'])
                                                          : null,
                                                      child: Hero(
                                                        tag:
                                                            'image_${product['imageUrl']}',
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12),
                                                          child: product[
                                                                      'imageUrl'] !=
                                                                  null
                                                              ? Image.network(
                                                                  product[
                                                                      'imageUrl'],
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Container(
                                                                      color: Colors
                                                                              .grey[
                                                                          200],
                                                                      child: const Icon(
                                                                          Icons
                                                                              .broken_image,
                                                                          size: 56,
                                                                          color: Colors
                                                                              .grey),
                                                                    );
                                                                  },
                                                                )
                                                              : Container(
                                                                  color: Colors
                                                                      .grey[200],
                                                                  child: const Icon(
                                                                      Icons.image,
                                                                      size: 56,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    product['name'] ?? 'No Name',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  if (product['category'] != null)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blueGrey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8),
                                                      ),
                                                      child: Text(
                                                        product['category'],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blueGrey,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    product['price'] != null
                                                        ? '\$${product['price']}'
                                                        : '',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.green),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    product['description'] ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            margin: const EdgeInsets.only(left: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Ratings & Reviews",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Column(
                                    children: const [
                                      ListTile(
                                        title: Text("Maria L.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            "Great tutoring session, super helpful! ⭐⭐⭐⭐⭐"),
                                      ),
                                      ListTile(
                                        title: Text("Josh K.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            "Quick turnaround and great UI suggestions. ⭐⭐⭐⭐☆"),
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
              );
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF386A53),
              ),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous page
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
