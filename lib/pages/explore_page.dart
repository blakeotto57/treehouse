import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/components/nav_bar.dart';

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
    final cutoff =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24)));
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
      final difference = now.difference(lastTimestamp);
      if (difference.inHours < 24) {
        setState(() {
          _canPost = false; // Prevent posting if within 24 hours
        });
        return;
      }
    }
    setState(() {
      _canPost = true; // Allow posting if more than 24 hours have passed
    });
  }

  Future<void> _showPostDialog() async {
    _messageController.clear();
    String? errorText;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                      borderSide: const BorderSide(
                          color: Color(0xFF386A53), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF386A53), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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
                      await FirebaseFirestore.instance
                          .collection('bulletin_posts')
                          .add({
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
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Post",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearch() {
    // Implement search logic
  }

  @override
  Widget build(BuildContext context) {
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkCard = const Color(0xFF232323);
    final darkBackground = const Color(0xFF181818);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final cutoff = Timestamp.fromDate(now.subtract(const Duration(hours: 24)));

    final GlobalKey<SlidingDrawerState> _drawerKey =
        GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context), // Use customDrawerContent from drawer.dart
      child: Scaffold(
        backgroundColor: isDark ? darkBackground : pastelGreen,
        drawer: customDrawer(context),
        appBar: Navbar(drawerKey: _drawerKey),
        body: Column(
          children: [
            const SizedBox(height: 20), // Space below the app bar
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                height: 40,
                width: 300,
                decoration: BoxDecoration(
                  color: isDark ? darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(24), // Pill shape
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.black,
                  cursorWidth: 1.2, // Thinner cursor
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.start,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Icon(
                        Icons.search,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 32,
                      minHeight: 23,
                    ),
                    hintText: "Search the explore page...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 0), // Increased for vertical centering
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: (isDark ? Colors.white! : const Color(0xFF386A53))
                          .withOpacity(0.3),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      return const Center(
                          child: Text("No posts on the explore page."));
                    }
                    final posts = snapshot.data!.docs;

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 10, // Horizontal spacing between posts
                        runSpacing:
                            5, // Reduced vertical spacing between rows of posts
                        children: posts.map((postDoc) {
                          final post = postDoc.data() as Map<String, dynamic>;
                          final timestamp =
                              (post['timestamp'] as Timestamp).toDate();
                          final formattedTime =
                              DateFormat('MMM d, h:mm a').format(timestamp);
                          final currentUser = FirebaseAuth.instance.currentUser;
                          final isCurrentUser = currentUser != null &&
                              post['userEmail'] == currentUser.email;

                          final screenWidth = MediaQuery.of(context).size.width;
                          final postsPerRow = screenWidth < 600 ? 3 : 5;
                          final postWidth = screenWidth / postsPerRow - 16;

                          return SizedBox(
                            width: postWidth, // Fit 5 posts in a row
                            child: Card(
                              color: isDark ? darkCard : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize:
                                      MainAxisSize.min, // Shrinkwrap the height
                                  children: [
                                    // Message
                                    Text(
                                      post['message'] ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Image
                                    if (post['imageUrl'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          post['imageUrl'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                        ),
                                      ),

                                    const SizedBox(height: 4),

                                    // Username
                                    if (post['username'] != null)
                                      Text(
                                        post['username'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF386A53),
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    const SizedBox(height: 4),

                                    // Timestamp + edit button — overflow fix
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth:
                                            150, // Adjust this value to fit the edit row properly
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                formattedTime,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey,
                                                ),
                                              ),
                                              if (isCurrentUser)
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color:
                                                        const Color(0xFF386A53),
                                                    size: 18,
                                                  ),
                                                  tooltip: "Edit this post",
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () async {
                                                    final confirm =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        backgroundColor: isDark
                                                            ? darkCard
                                                            : Colors.white,
                                                        title: const Text(
                                                            "Delete Post"),
                                                        content: const Text(
                                                            "Are you sure you want to delete this post?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    false),
                                                            child: const Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    true),
                                                            child: const Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      postDoc.reference
                                                          .delete();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                "Post deleted.")),
                                                      );
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
              final lastTimestamp =
                  (lastPost['timestamp'] as Timestamp).toDate();
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
                        child: const Text(
                          "OK",
                          style: TextStyle(color: Colors.blue),
                        ),
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
          label: const Text(
            "New Post",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
