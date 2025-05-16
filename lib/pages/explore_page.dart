import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isPosting = false;
  bool _canPost = true;

  @override
  void initState() {
    super.initState();
    _deleteOldPosts();
    _checkCanPost();
  }

  Future<void> _deleteOldPosts() async {
    final cutoff = Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24)));
    final query = await FirebaseFirestore.instance
        .collection('bulletin_posts')
        .where('timestamp', isLessThan: cutoff)
        .get();

    for (final doc in query.docs) {
      try {
        await doc.reference.delete();
      } catch (e) {
        // Optionally handle errors (e.g., permissions)
      }
    }
  }

  Future<void> _checkCanPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final query = await FirebaseFirestore.instance
        .collection('bulletin_posts')
        .where('userEmail', isEqualTo: user.email)
        .get();
    if (query.docs.isNotEmpty) {
      final lastPost = query.docs.first.data();
      final lastTimestamp = (lastPost['timestamp'] as Timestamp).toDate();
      final now = DateTime.now();
      setState(() {
        _canPost = now.difference(lastTimestamp).inHours >= 24;
      });
    } else {
      setState(() {
        _canPost = true;
      });
    }
  }

  Future<void> _showPostDialog() async {
    _messageController.clear();
    String? errorText;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: Color(0xFF386A53)),
              const SizedBox(width: 8),
              const Text(
                "New Bulletin Post",
                style: TextStyle(
                  color: Color(0xFF386A53),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  minLines: 2,
                  cursorColor: Colors.black,
                  maxLength: 200,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    hintText: "What are you offering today?",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5FBF7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF386A53), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF386A53), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    errorText: errorText,
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (_) {
                    if (errorText != null) {
                      setState(() {
                        errorText = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "Keep it friendly and helpful! Posts are visible for 24 hours.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386A53),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: _isPosting
                  ? null
                  : () async {
                      final message = _messageController.text.trim();
                      if (message.length < 20) {
                        setState(() {
                          errorText = "Post must be at least 20 characters.";
                        });
                        return;
                      }
                      setState(() => _isPosting = true);
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      await FirebaseFirestore.instance.collection('bulletin_posts').add({
                        'message': message,
                        'timestamp': Timestamp.now(),
                        'userEmail': user.email,
                      });
                      setState(() => _isPosting = false);
                      Navigator.pop(context);
                      _checkCanPost();
                    },
              child: _isPosting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Post", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkCard = const Color(0xFF232323);
    final darkBackground = const Color(0xFF181818);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final cutoff = Timestamp.fromDate(now.subtract(const Duration(hours: 24)));

    return Scaffold(
      backgroundColor: isDark ? darkBackground : pastelGreen,
      drawer: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User Account Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF386A53),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              accountName: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.email)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final userDocRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.email);

                    // If username is missing, create it and show the email prefix for now
                    if (data == null || data['username'] == null || data['username'].toString().trim().isEmpty) {
                      final emailPrefix = FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? "User";
                      // Use set with merge to ensure the username field is created if missing
                      userDocRef.set({'username': emailPrefix}, SetOptions(merge: true));
                      return Text(
                        emailPrefix,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      );
                    }

                    final username = data['username'];
                    return Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    );
                  }
                  // fallback
                  final emailPrefix = FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? "User";
                  // If the doc doesn't exist, create it with a username field
                  final userDocRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.email);
                  userDocRef.set({'username': emailPrefix}, SetOptions(merge: true));
                  return Text(
                    emailPrefix,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  );
                },
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? "",
                style: const TextStyle(fontSize: 14),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF386A53), size: 32),
              ),
            ),
           
            // Categories Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "Categories",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            // Categories List
            ...CategoryModel.getCategories().asMap().entries.map((entry) {
              final i = entry.key;
              final category = entry.value;
              final iconList = [
                Icons.spa, // Personal Care
                Icons.restaurant, // Food
                Icons.camera_alt, // Photography
                Icons.menu_book, // Academics
                Icons.build, // Technical
                Icons.local_shipping, // Errands & Moving
                Icons.pets, // Pet Care
                Icons.cleaning_services, // Cleaning
              ];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Card(
                  elevation: 0,
                  color: category.boxColor.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    dense: true,
                    minLeadingWidth: 0,
                    leading: CircleAvatar(
                      backgroundColor: category.boxColor.withOpacity(0.18),
                      radius: 16,
                      child: Icon(
                        iconList.length > i ? iconList[i] : category.icon,
                        color: category.boxColor,
                        size: 18,
                      ),
                    ),
                    title: DefaultTextStyle.merge(
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      child: category.name,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      category.onTap(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hoverColor: category.boxColor.withOpacity(0.10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Navigation Bar (updated)
          Container(
            color: const Color(0xFF386A53),
            padding: const EdgeInsets.symmetric(vertical: 0), // No horizontal padding
            height: 56,
            child: Row(
              children: [
                // Hamburger menu button with padding
                Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(6.0), // Padding around the icon
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: "Open navigation menu",
                    ),
                  ),
                ),
                // No space between drawer and title
                const Text(
                  "Treehouse Connect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
                // Add space between title and right-side navigation
                const SizedBox(width: 32),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ExplorePage()),
                            );
                          },
                          icon: const Icon(Icons.explore, color: Colors.white),
                          label: const Text("Explore", style: TextStyle(color: Colors.white)),
                        ),
                        // Vertical divider
                        Container(
                          height: 28,
                          width: 1.2,
                          color: Colors.white24,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MessagesPage()),
                            );
                          },
                          icon: const Icon(Icons.message, color: Colors.white),
                          label: const Text("Messages", style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          height: 28,
                          width: 1.2,
                          color: Colors.white24,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserProfilePage()),
                            );
                          },
                          icon: const Icon(Icons.person, color: Colors.white),
                          label: const Text("Profile", style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          height: 28,
                          width: 1.2,
                          color: Colors.white24,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserSettingsPage()),
                            );
                          },
                          icon: const Icon(Icons.settings, color: Colors.white),
                          label: const Text("Settings", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search the bulletin board...",
                      hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                      filled: true,
                      fillColor: isDark ? darkCard : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF386A53), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF386A53),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Implement search logic
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        "Search",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.campaign, color: isDark ? Colors.orange[200] : const Color(0xFF386A53)),
                const SizedBox(width: 10),
                Text(
                  "See what's new on the bulletin board",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.orange[200] : const Color(0xFF386A53),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: (isDark ? Colors.orange[200]! : const Color(0xFF386A53)).withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Bulletin board posts
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bulletin_posts')
                    .where('timestamp', isGreaterThan: cutoff)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No posts on the bulletin board."));
                  }
                  final posts = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final postDoc = posts[index]; // This is a DocumentSnapshot
                      final post = postDoc.data() as Map<String, dynamic>; // This is the map
                      final timestamp = (post['timestamp'] as Timestamp).toDate();
                      final formattedTime = DateFormat('MMM d, h:mm a').format(timestamp);
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final isCurrentUser = currentUser != null && post['userEmail'] == currentUser.email;

                      return Align(
                        alignment: Alignment.center, // Center the card horizontally
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 350,
                          ),
                          child: Card(
                            color: isDark ? darkCard : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Message
                                  Text(
                                    post['message'] ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Username (instead of email)
                                  if (post['username'] != null)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OtherUsersProfilePage(
                                              username: post['username'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        post['username'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isDark ? Colors.orange[200] : const Color(0xFF386A53),
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  // Timestamp and delete button row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey[400] : Colors.grey,
                                        ),
                                      ),
                                      if (isCurrentUser)
                                        IconButton(
                                          icon: Icon(Icons.edit, color: isDark ? Colors.orange[200] : const Color(0xFF386A53), size: 18),
                                          tooltip: "Delete this post",
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: isDark ? darkCard : Colors.white,
                                                title: const Text("Delete Post"),
                                                content: const Text("Are you sure you want to delete this post?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text("Cancel", style: TextStyle(color: Colors.blue),),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              postDoc.reference.delete();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Post deleted.")),
                                              );
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF386A53),
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          final query = await FirebaseFirestore.instance
              .collection('bulletin_posts')
              .where('userEmail', isEqualTo: user.email)
              .get();

          if (query.docs.isNotEmpty) {
            final lastPost = query.docs.first.data() as Map<String, dynamic>;
            final lastTimestamp = (lastPost['timestamp'] as Timestamp).toDate();
            final now = DateTime.now();
            final difference = now.difference(lastTimestamp);
            if (difference.inHours < 24) {
              final remaining = Duration(hours: 24) - difference;
              final hours = remaining.inHours;
              final minutes = remaining.inMinutes.remainder(60);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? darkCard : Colors.white,
                  title: const Text("Already Posted"),
                  content: Text(
                    "You already posted today.\nYou have ${hours}h ${minutes}m remaining before you can post again.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK", style: TextStyle(color: Colors.blue),),
                    ),
                  ],
                ),
              );
              return;
            }
          }
          _showPostDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text("New Post", 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
