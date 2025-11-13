import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/components/professional_navbar.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/models/user_post_page.dart';
import 'package:treehouse/components/profile_avatar.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final GlobalKey<SlidingDrawerState> _drawerKey = GlobalKey<SlidingDrawerState>();
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.edit_note, size: 20,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  "New Bulletin Post",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    minLines: 2,
                    cursorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    maxLength: 200,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      hintText: "What are you offering today?",
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      errorText: errorText,
                    ),
                    style: TextStyle(
                      fontSize: 14,
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
                  const SizedBox(height: 8),
                  Text(
                    "Keep it friendly and helpful! Posts are visible for 24 hours.",
                    style: TextStyle(
                      fontSize: 12,
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
                child: Text("Cancel", style: TextStyle(fontSize: 14, color: AppColors.errorRed)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        // Create the post and get the document ID
                        final docRef = await FirebaseFirestore.instance.collection('bulletin_posts').add({
                          'message': message,
                          'timestamp': Timestamp.now(),
                          'userEmail': user.email,
                          'imageUrl': null, // Can be added later with image upload
                          'likes': [], // Initialize empty likes array
                          'comments': [], // Initialize empty comments array
                        });
                        setState(() => _isPosting = false);
                        Navigator.pop(context);
                        _checkCanPost();
                        // Navigate to the new post URL
                        context.go('/post/${docRef.id}');
                      },
                child: _isPosting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Post", style: TextStyle(fontSize: 14, color: Colors.white)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navbar = ProfessionalNavbar(drawerKey: _drawerKey);
    final headerHeight = navbar.preferredSize.height;

    final topPadding = MediaQuery.of(context).padding.top;
    final headerTotalHeight = topPadding + headerHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Sliding drawer and content - full screen
          SlidingDrawer(
            key: _drawerKey,
            drawer: customDrawer(context),
            appBarHeight: headerTotalHeight,
            child: Column(
              children: [
                // Spacer for header (SafeArea + navbar)
                SizedBox(height: headerTotalHeight),
                // Content area
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with title and New Post button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // "Today's Posts" heading
                              Text(
                                "Today's Posts",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  fontFamily: 'Roboto',
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Spacer(),
                              // New Post button
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text(
                                  'New Post',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                  shadowColor: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.3),
                                ),
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
                                            backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                            title: Text(
                                              "Already Posted",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                            content: Text(
                                              "You already posted today.\nYou have ${hours}h ${minutes}m remaining before you can post again.",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(
                                                  "OK",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                                  ),
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Search + Sort row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 720),
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search listings...',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? AppColors.textSecondaryDark : Colors.grey[500],
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        size: 20,
                                        color: isDark ? AppColors.textSecondaryDark : Colors.grey[500],
                                      ),
                                      filled: true,
                                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _sortBy,
                                    isDense: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                    items: ['Newest', 'Oldest', 'Most Popular']
                                        .map((s) => DropdownMenuItem(
                                          value: s, 
                                          child: Text(
                                            s,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                        ))
                                        .toList(),
                                    onChanged: (v) => setState(() => _sortBy = v ?? 'Newest'),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: isDark ? AppColors.textSecondaryDark : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

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
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        "No posts available today.",
                                        style: TextStyle(
                                          fontSize: 14,
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
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        "No posts match your search.",
                                        style: TextStyle(
                                          fontSize: 14,
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
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.5, // Adjusted for Reddit-style layout
                                      ),
                                      itemBuilder: (context, idx) {
                                        final postDoc = filteredPosts[idx];
                                        final post = postDoc.data() as Map<String, dynamic>;
                                        final timestamp = (post['timestamp'] as Timestamp).toDate();
                                        final message = post['message'] ?? '';
                                        final category = _getCategoryFromMessage(message);
                                        final imageUrl = post['imageUrl'] as String?;
                                        final userEmail = post['userEmail'] ?? '';
                                        final postId = postDoc.id;
                                        
                                        // Get likes and comments from post data
                                        final likes = List<String>.from(post['likes'] ?? []);
                                        final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);

                                        // Extract title and description from message
                                        final lines = message.split('\n');
                                        final title = lines.isNotEmpty
                                            ? lines[0]
                                            : (message.length > 30 ? message.substring(0, 30) + '...' : message);
                                        final description = lines.length > 1
                                            ? lines.sublist(1).join(' ')
                                            : (message.length > 30 ? message.substring(30) : '');

                                        return PostCard(
                                          postId: postId,
                                          title: title,
                                          description: description.isEmpty ? message : description,
                                          imageUrl: imageUrl,
                                          date: timestamp,
                                          category: category,
                                          userEmail: userEmail,
                                          likes: likes,
                                          commentCount: comments.length,
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
                ),
              ],
            ),
          ),
          // Fixed header on top - always visible above drawer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: headerHeight,
                child: navbar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String postId;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final String category;
  final String userEmail;
  final List<String> likes;
  final int commentCount;

  const PostCard({
    Key? key,
    required this.postId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
    required this.category,
    required this.userEmail,
    required this.likes,
    required this.commentCount,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _isLiked = currentUser != null && widget.likes.contains(currentUser.email);
    _likeCount = widget.likes.length;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update like state if widget data changes
    if (oldWidget.likes != widget.likes) {
      final currentUser = FirebaseAuth.instance.currentUser;
      _isLiked = currentUser != null && widget.likes.contains(currentUser.email);
      _likeCount = widget.likes.length;
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });

    try {
      final postRef = FirebaseFirestore.instance
          .collection('bulletin_posts')
          .doc(widget.postId);

      if (_isLiked) {
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUser.email]),
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUser.email]),
        });
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (_isLiked) {
          _isLiked = false;
          _likeCount--;
        } else {
          _isLiked = true;
          _likeCount++;
        }
      });
    }
  }

  void _sharePost() {
    // Generate post URL for bulletin posts
    final baseUrl = Uri.base.origin;
    final postUrl = '$baseUrl/post/${widget.postId}';
    Clipboard.setData(ClipboardData(text: postUrl));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post URL copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
      ),
    );
  }

  void _navigateToComments() {
    context.go('/post/${widget.postId}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('MMM d, h:mm a').format(widget.date);
    final timeAgo = _getTimeAgo(widget.date);

    // Listen to both user data and post data for real-time updates
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bulletin_posts')
          .doc(widget.postId)
          .snapshots(),
      builder: (context, postSnapshot) {
        // Get updated likes and comments from post
        List<String> currentLikes = widget.likes;
        int currentCommentCount = widget.commentCount;
        
        if (postSnapshot.hasData && postSnapshot.data!.exists) {
          final postData = postSnapshot.data!.data() as Map<String, dynamic>;
          currentLikes = List<String>.from(postData['likes'] ?? []);
          final comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);
          currentCommentCount = comments.length;
          
          // Update local state if changed
          final currentUser = FirebaseAuth.instance.currentUser;
          if (mounted) {
            final newIsLiked = currentUser != null && currentLikes.contains(currentUser.email);
            if (newIsLiked != _isLiked || currentLikes.length != _likeCount) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isLiked = newIsLiked;
                    _likeCount = currentLikes.length;
                  });
                }
              });
            }
          }
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userEmail)
              .snapshots(),
          builder: (context, userSnapshot) {
            String username = widget.userEmail.split('@')[0];
            String? profileImageUrl;
            
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              username = userData?['username'] ?? username;
              profileImageUrl = userData?['profileImageUrl'] as String?;
            }

            // Get user initials for avatar
            final parts = username.split(' ');
            String initials = '';
            if (parts.length >= 2) {
              initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
            } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
              initials = parts[0][0].toUpperCase();
            }

            return Material(
              borderRadius: BorderRadius.circular(8),
              elevation: 0,
              color: isDark ? AppColors.cardDark : Colors.white,
              child: InkWell(
                onTap: _navigateToComments, // Make entire card clickable
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark 
                          ? AppColors.borderDark.withOpacity(0.2)
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Profile picture, username, time, menu
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: Row(
                          children: [
                            // Profile picture
                            ProfileAvatar(
                              photoUrl: profileImageUrl,
                              userEmail: widget.userEmail,
                              displayName: username,
                              radius: 16,
                              showOnlineStatus: true,
                            ),
                            const SizedBox(width: 8),
                            // Username and time
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'u/$username',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark 
                                          ? AppColors.textPrimaryDark 
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark 
                                          ? AppColors.textSecondaryDark 
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Menu dots (optional)
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                size: 18,
                                color: isDark 
                                    ? AppColors.textSecondaryDark 
                                    : AppColors.textSecondaryLight,
                              ),
                              onPressed: () {
                                // Menu functionality can be added here
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      // Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark 
                                ? AppColors.textPrimaryDark 
                                : AppColors.textPrimaryLight,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),

                      // Description/Content
                      if (widget.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                              fontFamily: 'Roboto',
                              height: 1.4,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Category flair
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),

                      // Footer: Likes, Comments, Share
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark 
                                  ? AppColors.borderDark.withOpacity(0.2)
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Like button
                            GestureDetector(
                              onTap: _toggleLike,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isLiked ? Icons.arrow_upward : Icons.arrow_upward_outlined,
                                      size: 18,
                                      color: _isLiked 
                                          ? AppColors.primaryGreen
                                          : (isDark 
                                              ? AppColors.textSecondaryDark 
                                              : AppColors.textSecondaryLight),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_likeCount',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _isLiked 
                                            ? AppColors.primaryGreen
                                            : (isDark 
                                                ? AppColors.textSecondaryDark 
                                                : AppColors.textSecondaryLight),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Comments button
                            GestureDetector(
                              onTap: _navigateToComments,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 18,
                                      color: isDark 
                                          ? AppColors.textSecondaryDark 
                                          : AppColors.textSecondaryLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$currentCommentCount',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark 
                                            ? AppColors.textSecondaryDark 
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Share button
                            GestureDetector(
                              onTap: _sharePost,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.share_outlined,
                                      size: 18,
                                      color: isDark 
                                          ? AppColors.textSecondaryDark 
                                          : AppColors.textSecondaryLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Share',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark 
                                            ? AppColors.textSecondaryDark 
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}hr ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
