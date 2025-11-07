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
import 'package:treehouse/theme/theme.dart';

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
  String _sortBy = 'Newest';

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
          _canPost = false;
        });
        return;
      }
    }
    setState(() {
      _canPost = true;
    });
  }

  Future<void> _showPostDialog() async {
    _messageController.clear();
    String? errorText;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                Icon(Icons.edit_note, color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  "New Bulletin Post",
                  style: TextStyle(
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
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
                    cursorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    maxLength: 200,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      hintText: "What are you offering today?",
                      hintStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      errorText: errorText,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() {
                          errorText = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Keep it friendly and helpful! Posts are visible for 24 hours.",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: AppColors.errorRed)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
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
          );
        },
      ),
    );
  }

  void _onSearch() {
    // Implement search logic
  }

  String _getCategoryFromMessage(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('sell') || lowerMessage.contains('buy') || lowerMessage.contains('textbook')) {
      return 'For Sale';
    } else if (lowerMessage.contains('room') || lowerMessage.contains('apartment') || lowerMessage.contains('housing')) {
      return 'Housing';
    } else if (lowerMessage.contains('tutor') || lowerMessage.contains('service') || lowerMessage.contains('help')) {
      return 'Services';
    } else if (lowerMessage.contains('food') || lowerMessage.contains('meal')) {
      return 'Food';
    }
    return 'General';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final now = DateTime.now();
    final cutoff = Timestamp.fromDate(now.subtract(const Duration(hours: 24)));

    final GlobalKey<SlidingDrawerState> _drawerKey = GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context),
      child: Scaffold(
        backgroundColor: backgroundColor,
        drawer: customDrawer(context),
        appBar: Navbar(drawerKey: _drawerKey),
        body: Column(
          children: [
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Today's Posts" heading
                    Text(
                      "Today's Posts",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search bar and filter row
                    Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              cursorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontSize: 15,
                              ),
                              onSubmitted: (_) => _onSearch(),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  size: 20,
                                ),
                                hintText: "Search listings...",
                                hintStyle: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Sort/Filter dropdown
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: _sortBy,
                            isDense: true,
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontSize: 15,
                            ),
                            items: ['Newest', 'Oldest', 'Most Popular'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _sortBy = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Posts grid
                    StreamBuilder<QuerySnapshot>(
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
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(48.0),
                              child: Text(
                                "No posts available today.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          );
                        }
                        final posts = snapshot.data!.docs;

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = constraints.maxWidth;
                            final crossAxisCount = screenWidth > 1200 ? 3 : (screenWidth > 800 ? 2 : 1);
                            final spacing = 16.0;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final postDoc = posts[index];
                                final post = postDoc.data() as Map<String, dynamic>;
                                final timestamp = (post['timestamp'] as Timestamp).toDate();
                                final formattedTime = DateFormat('MMM d, h:mm a').format(timestamp);
                                final message = post['message'] ?? '';
                                final category = _getCategoryFromMessage(message);

                                // Extract title and description from message
                                final lines = message.split('\n');
                                final title = lines.isNotEmpty ? lines[0] : (message.length > 30 ? message.substring(0, 30) + '...' : message);
                                final description = lines.length > 1
                                    ? lines.sublist(1).join(' ')
                                    : (message.length > 30 ? message.substring(30) : '');

                                return Card(
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: cardColor,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      // Navigate to post details if needed
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Image placeholder or actual image
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                              color: isDark ? AppColors.surfaceDark : AppColors.borderLight,
                                            ),
                                            child: post['imageUrl'] != null
                                                ? ClipRRect(
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(16),
                                                      topRight: Radius.circular(16),
                                                    ),
                                                    child: Image.network(
                                                      post['imageUrl'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: isDark ? AppColors.surfaceDark : AppColors.borderLight,
                                                          child: Icon(
                                                            Icons.image,
                                                            size: 48,
                                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Container(
                                                    color: isDark ? AppColors.surfaceDark : AppColors.borderLight,
                                                    child: Icon(
                                                      Icons.image,
                                                      size: 48,
                                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        // Content section
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Title
                                                Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),

                                                // Description
                                                if (description.isNotEmpty)
                                                  Expanded(
                                                    child: Text(
                                                      description,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                const Spacer(),

                                                // Date and Category row
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      formattedTime,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        category,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                                        ),
                                                      ),
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
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
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
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return AlertDialog(
                      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                      title: Text(
                        "Already Posted",
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      content: Text(
                        "You already posted today.\nYou have ${hours}h ${minutes}m remaining before you can post again.",
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "OK",
                            style: TextStyle(color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                          ),
                        ),
                      ],
                    );
                  },
                );
                return;
              }
            }
            _showPostDialog();
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "New Post",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
