import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Bulletin Post"),
        content: TextField(
          controller: _messageController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "What's on your mind?",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _isPosting
                ? null
                : () async {
                    setState(() => _isPosting = true);
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    await FirebaseFirestore.instance.collection('bulletin_posts').add({
                      'message': _messageController.text,
                      'timestamp': Timestamp.now(),
                      'userEmail': user.email,
                      // Add 'imageUrl': ... if you implement image upload
                    });
                    setState(() => _isPosting = false);
                    Navigator.pop(context);
                    _checkCanPost();
                  },
            child: _isPosting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pastelGreen = const Color(0xFFF5FBF7);
    final now = DateTime.now();
    final cutoff = Timestamp.fromDate(now.subtract(const Duration(hours: 24)));

    return Scaffold(
      backgroundColor: pastelGreen,
      // Add the Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF386A53),
              ),
              child: const Text(
                'Treehouse Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.explore, color: Color(0xFF386A53)),
              title: const Text('Explore'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ExplorePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Color(0xFF386A53)),
              title: const Text('Messages'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MessagesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF386A53)),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF386A53)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Navigation Bar with Drawer Icon
          Container(
            color: const Color(0xFF386A53),
            padding: const EdgeInsets.symmetric(vertical: 0), // No horizontal padding
            height: 56,
            child: Row(
              children: [
                // Drawer icon with a bit of padding
                Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(6.0),
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
                // Space between title and right-side navigation
                const SizedBox(width: 32),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Already on Explore, maybe scroll to top or do nothing
                          },
                          icon: const Icon(Icons.explore, color: Colors.white),
                          label: const Text("Explore", style: TextStyle(color: Colors.white)),
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search the bulletin board...",
                      filled: true,
                      fillColor: Colors.white,
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
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Search",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bulletin board posts
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                  return GridView.builder(
                    itemCount: posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final postDoc = posts[index];
                      final post = posts[index].data() as Map<String, dynamic>;
                      final timestamp = (post['timestamp'] as Timestamp).toDate();
                      final formattedTime = DateFormat('MMM d, h:mm a').format(timestamp);
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final isCurrentUser = currentUser != null && post['userEmail'] == currentUser.email;

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image if available
                                if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                    child: Image.network(
                                      post['imageUrl'],
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
                                      ),
                                    ),
                                  )
                                else
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                    child: Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.message, size: 60, color: Colors.grey[400]),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Message
                                      Text(
                                        post['message'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // User/email (optional)
                                      if (post['userEmail'] != null)
                                        Text(
                                          post['userEmail'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF386A53),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      // Timestamp
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit/Delete icon for current user's post
                          if (isCurrentUser)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF386A53)),
                                tooltip: "Delete this post",
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Delete Post"),
                                      content: const Text("Are you sure you want to delete this post?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Cancel"),
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
                            ),
                        ],
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
                  title: const Text("Already Posted"),
                  content: Text(
                    "You already posted today.\nYou have ${hours}h ${minutes}m remaining before you can post again.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
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
        label: const Text("New Post"),
      ),
    );
  }
}
