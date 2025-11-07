import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/components/professional_navbar.dart';
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _deleteOldPosts();
    _checkCanPost();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
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
                Icon(Icons.edit_note,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
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
                      hintStyle: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            width: 2),
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
                          'imageUrl': null, // Can be added later with image upload
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

  String _getCategoryFromMessage(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('sell') ||
        lowerMessage.contains('buy') ||
        lowerMessage.contains('textbook')) {
      return 'For Sale';
    } else if (lowerMessage.contains('room') ||
        lowerMessage.contains('apartment') ||
        lowerMessage.contains('housing')) {
      return 'Housing';
    } else if (lowerMessage.contains('tutor') ||
        lowerMessage.contains('service') ||
        lowerMessage.contains('help')) {
      return 'Services';
    } else if (lowerMessage.contains('food') || lowerMessage.contains('meal')) {
      return 'Food';
    }
    return 'General';
  }

  List<QueryDocumentSnapshot> _filterAndSortPosts(List<QueryDocumentSnapshot> posts) {
    // Filter by search query
    List<QueryDocumentSnapshot> filtered = posts;
    if (_searchQuery.isNotEmpty) {
      filtered = posts.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final message = (data['message'] ?? '').toLowerCase();
        final category = _getCategoryFromMessage(message).toLowerCase();
        return message.contains(_searchQuery) || category.contains(_searchQuery);
      }).toList();
    }

    // Sort posts
    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aTimestamp = (aData['timestamp'] as Timestamp).toDate();
      final bTimestamp = (bData['timestamp'] as Timestamp).toDate();

      if (_sortBy == 'Newest') {
        return bTimestamp.compareTo(aTimestamp);
      } else if (_sortBy == 'Oldest') {
        return aTimestamp.compareTo(bTimestamp);
      } else {
        // Most Popular - can be based on views or likes if added later
        return bTimestamp.compareTo(aTimestamp);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<SlidingDrawerState> _drawerKey = GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: ProfessionalNavbar(drawerKey: _drawerKey),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Today's Posts" heading
                const Text(
                  "Today's Posts",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    fontFamily: 'Roboto',
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 18),

                // Search + Sort row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search listings...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          items: ['Newest', 'Oldest', 'Most Popular']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => _sortBy = v ?? 'Newest'),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Cards grid
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bulletin_posts')
                        .where('timestamp',
                            isGreaterThan: Timestamp.fromDate(
                                DateTime.now().subtract(const Duration(hours: 24))))
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
                                color: Colors.grey[600],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        );
                      }

                      final allPosts = snapshot.data!.docs;
                      final filteredPosts = _filterAndSortPosts(allPosts);

                      if (filteredPosts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: Text(
                              "No posts match your search.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 1;
                          double width = constraints.maxWidth;
                          if (width >= 1100) {
                            crossAxisCount = 3;
                          } else if (width >= 700) {
                            crossAxisCount = 2;
                          } else {
                            crossAxisCount = 1;
                          }

                          return GridView.builder(
                            itemCount: filteredPosts.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 3 / 4,
                            ),
                            itemBuilder: (context, idx) {
                              final postDoc = filteredPosts[idx];
                              final post = postDoc.data() as Map<String, dynamic>;
                              final timestamp = (post['timestamp'] as Timestamp).toDate();
                              final message = post['message'] ?? '';
                              final category = _getCategoryFromMessage(message);
                              final imageUrl = post['imageUrl'] as String?;

                              // Extract title and description from message
                              final lines = message.split('\n');
                              final title = lines.isNotEmpty
                                  ? lines[0]
                                  : (message.length > 30 ? message.substring(0, 30) + '...' : message);
                              final description = lines.length > 1
                                  ? lines.sublist(1).join(' ')
                                  : (message.length > 30 ? message.substring(30) : '');

                              return PostCard(
                                title: title,
                                description: description.isEmpty ? message : description,
                                imageUrl: imageUrl,
                                date: timestamp,
                                category: category,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
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
                    return AlertDialog(
                      backgroundColor: AppColors.cardLight,
                      title: const Text(
                        "Already Posted",
                        style: TextStyle(color: AppColors.textPrimaryLight),
                      ),
                      content: Text(
                        "You already posted today.\nYou have ${hours}h ${minutes}m remaining before you can post again.",
                        style: const TextStyle(color: AppColors.textSecondaryLight),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: AppColors.primaryGreen),
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
          label: const Text(
            'New Post',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: AppColors.buttonGreen,
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final String category;

  const PostCard({
    Key? key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, h:mm a').format(date);

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Roboto',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}