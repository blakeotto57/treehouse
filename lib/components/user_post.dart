import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/models/user_post_page.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:treehouse/theme/theme.dart';

class UserPost extends StatelessWidget {
  final String message;
  final String user; // username
  final List<String> likes;
  final Timestamp timestamp;
  final String category;
  final Color forumIconColor;
  final String title; // Added title property
  final String documentId; // Added document ID property

  const UserPost({
    Key? key,
    required this.message,
    required this.user,
    required this.likes,
    required this.timestamp,
    required this.category,
    required this.forumIconColor,
    required this.title, // Added title property
    required this.documentId, // Added document ID property
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isOwner = currentUser.email == user;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(category)
          .doc(documentId) // Use documentId instead of title
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final likes = List<String>.from(data['likes'] ?? []);
        final isLiked = likes.contains(currentUser.email);
        final comments =
            List<Map<String, dynamic>>.from(data['comments'] ?? []);

        // Format date and time
        final postDate = timestamp.toDate();
        final now = DateTime.now();
        String dateTimeString;
        if (postDate.year == now.year &&
            postDate.month == now.month &&
            postDate.day == now.day) {
          dateTimeString = DateFormat('h:mm a').format(postDate);
        } else {
          dateTimeString = DateFormat('MMM d, y').format(postDate);
        }

        return Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => UserPostPage(
                      postId: documentId,
                      categoryColor: forumIconColor,
                      firestoreCollection: category,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: forumIconColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                elevation: 3,
                shadowColor: forumIconColor.withOpacity(0.2),
                child: Column(
                  children: [
                    // Post content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with user info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // User profile picture and username wrapped in InkWell
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) =>
                                          OtherUsersProfilePage(username: user),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                hoverColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                child: Row(
                                  children: [
                                    // User profile picture
                                    FutureBuilder<QuerySnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .where('username', isEqualTo: user)
                                          .limit(1)
                                          .get(),
                                      builder: (context, userSnapshot) {
                                        String? photoUrl;
                                        if (userSnapshot.hasData &&
                                            userSnapshot
                                                .data!.docs.isNotEmpty) {
                                          final userData = userSnapshot
                                              .data!.docs.first
                                              .data() as Map<String, dynamic>;
                                          photoUrl = userData['profileImageUrl']
                                              as String?;
                                        }
                                        return CircleAvatar(
                                          backgroundColor:
                                              forumIconColor.withOpacity(0.2),
                                          radius: 12,
                                          backgroundImage: photoUrl != null &&
                                                  photoUrl.isNotEmpty
                                              ? NetworkImage(photoUrl)
                                              : null,
                                          child: (photoUrl == null ||
                                                  photoUrl.isEmpty)
                                              ? Text(
                                                  user.isNotEmpty
                                                      ? user[0].toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    color: forumIconColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    // Username and timestamp
                                    Row(
                                      children: [
                                        Text(
                                          user, // Username
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "•",
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeAgo(postDate), // Format the timestamp
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(), // Push the following items to the right side
                              // Category badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: forumIconColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: forumIconColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: forumIconColor,
                                  ),
                                ),
                              ),
                              // Replace the IconButton with PopupMenuButton
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                padding: EdgeInsets.zero,
                                onSelected: (value) {
                                  switch (value) {
                                    case 'send':
                                      _showSendToUserDialog(context);
                                      break;
                                    case 'delete':
                                      // Handle delete post
                                      break;
                                    case 'report':
                                      // Handle report post
                                      break;
                                    case 'save':
                                      // Handle save post
                                      break;
                                  }
                                },
                                itemBuilder: (context) {
                                  final List<PopupMenuEntry<String>> options = [
                                    const PopupMenuItem<String>(
                                      value: 'send',
                                      child: Row(
                                        children: [
                                          Icon(Icons.send, size: 20),
                                          SizedBox(width: 8),
                                          Text('Send to User'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(Icons.flag_outlined, size: 20),
                                          SizedBox(width: 8),
                                          Text('Report'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'save',
                                      child: Row(
                                        children: [
                                          Icon(Icons.bookmark_border, size: 20),
                                          SizedBox(width: 8),
                                          Text('Save'),
                                        ],
                                      ),
                                    ),
                                  ];

                                  // Add delete option only if current user is the post owner
                                  if (FirebaseAuth.instance.currentUser?.email == user) {
                                    options.insert(1, const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red, size: 20),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ));
                                  }

                                  return options;
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Post title in bold
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Post message/content
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),
                          // Actions row (likes, comments)
                          Row(
                            children: [
                              // Like button
                              InkWell(
                                onTap: () => toggleLike(likes, isLiked),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 18,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${likes.length}',
                                        style: TextStyle(
                                          color: isLiked
                                              ? Colors.red
                                              : Colors.grey,
                                          fontWeight: isLiked
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              // Comments count
                              Row(
                                children: [
                                  Icon(Icons.comment_outlined,
                                      size: 18, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    '${comments.length}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
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
            if (isOwner)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // handle delete logic here
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void toggleLike(List<String> likes, bool isLiked) {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection(category).doc(documentId);

    if (isLiked) {
      postRef.update({
        "likes":
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.email]),
      });
    } else {
      postRef.update({
        "likes":
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.email]),
      });
    }
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7)
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Text('Options menu content goes here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showShareLinkDialog(BuildContext context) {
    // Create a link for this specific post using documentId instead of title
    final String postLink = "https://treehouse.app/post/$documentId";
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Copy this link to share:'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    postLink,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Link'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: postLink));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSendToUserDialog(BuildContext context) {
    final postUrl = "https://treehouse.app/post/$documentId";
    final postTitle = title;
    final theme = Theme.of(context);
    final Color accent = forumIconColor;
    TextEditingController searchController = TextEditingController();
    ValueNotifier<List<Map<String, dynamic>>> searchResults = ValueNotifier([]);
    ValueNotifier<bool> loading = ValueNotifier(false);

    Future<void> searchUsers(String query) async {
      if (query.isEmpty) {
        searchResults.value = [];
        return;
      }
      loading.value = true;
      final usersByUsername = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get();
      final usersByEmail = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get();
      // Merge and deduplicate
      final allUsers = <String, Map<String, dynamic>>{};
      for (var doc in usersByUsername.docs) {
        allUsers[doc['email']] = doc.data();
      }
      for (var doc in usersByEmail.docs) {
        allUsers[doc['email']] = doc.data();
      }
      searchResults.value = allUsers.values.toList();
      loading.value = false;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            height: 500,
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.send, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Send Post to User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 20,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                // Post title preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    '"$postTitle"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: searchController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: 'Search users by username or email...',
                      prefixIcon: Icon(Icons.search, color: accent, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent, width: 1.5),
                      ),
                    ),
                    onChanged: (val) => searchUsers(val.trim()),
                  ),
                ),
                // User list
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: loading,
                    builder: (context, isLoading, _) {
                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: searchResults,
                        builder: (context, users, _) {
                          if (searchController.text.isEmpty) {
                            // Show recent chat users if search is empty
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 0, 4),
                                  child: Text(
                                    'Recent Chats',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: StreamBuilder<List<Map<String, dynamic>>>(
                                    stream: ChatService().getAcceptedChatsStream(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text(
                                            'Error loading users: \\${snapshot.error}',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        );
                                      }
                                      final recentUsers = snapshot.data ?? [];
                                      if (recentUsers.isEmpty) {
                                        return Center(
                                          child: Text(
                                            'No users to send to.\\nStart a conversation or search for any user!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }
                                      return ListView.separated(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        itemCount: recentUsers.length,
                                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                                        itemBuilder: (context, index) {
                                          final user = recentUsers[index];
                                          final userEmail = user['email'] as String;
                                          final username = user['username'] as String? ?? userEmail;
                                          final profileImageUrl = user['profileImageUrl'] as String?;
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: accent.withOpacity(0.15),
                                              backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                                  ? NetworkImage(profileImageUrl)
                                                  : null,
                                              child: profileImageUrl == null || profileImageUrl.isEmpty
                                                  ? Text(
                                                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                                                      style: TextStyle(
                                                        color: accent,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            title: Text(
                                              username,
                                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Text(
                                              userEmail,
                                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              _sendPostToUser(context, userEmail, postUrl, postTitle);
                                            },
                                            hoverColor: accent.withOpacity(0.08),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                          if (users.isEmpty) {
                            return Center(
                              child: Text(
                                'No users found.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 0, 4),
                                child: Text(
                                  'Search Results',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  itemCount: users.length,
                                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    final userEmail = user['email'] as String;
                                    final username = user['username'] as String? ?? userEmail;
                                    final profileImageUrl = user['profileImageUrl'] as String?;
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: accent.withOpacity(0.15),
                                        backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                            ? NetworkImage(profileImageUrl)
                                            : null,
                                        child: profileImageUrl == null || profileImageUrl.isEmpty
                                            ? Text(
                                                username.isNotEmpty ? username[0].toUpperCase() : '?',
                                                style: TextStyle(
                                                  color: accent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        username,
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        userEmail,
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                      ),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        _sendPostToUser(context, userEmail, postUrl, postTitle);
                                      },
                                      hoverColor: accent.withOpacity(0.08),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    );
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
                // Cancel button
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 10, top: 2),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendPostToUser(BuildContext context, String userEmail, String postUrl, String postTitle) async {
    try {
      final currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
      // Create chat ID
      List<String> ids = [currentUserEmail, userEmail]..sort();
      String chatId = ids.join('_');
      // Create the message with post information
      final messageData = {
        'text': 'Check out this post: "$postTitle"\n\n$postUrl',
        'sender': currentUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'isPostShare': true, // Flag to identify this as a shared post
        'postUrl': postUrl,
        'postTitle': postTitle,
        'postId': documentId,
        'category': category,
      };
      // Send the message
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post sent to ${userEmail.split('@')[0]}!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send post: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

class _CommentInput extends StatefulWidget {
  final String category;
  final String postTitle;
  const _CommentInput({required this.category, required this.postTitle});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _commentTextController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  void addComment(String comment) async {
    if (comment.trim().isEmpty) return;

    final postRef = FirebaseFirestore.instance
        .collection(widget.category) // e.g., "personal_care_posts"
        .doc(widget.postTitle);

    await postRef.collection("comments").add({
      "comment": comment,
      "comment by": currentUser.email,
      "created on": Timestamp.now(),
      "likes": [],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _commentTextController,
          decoration: InputDecoration(labelText: 'Add a comment'),
        ),
        ElevatedButton(
          onPressed: () {
            addComment(_commentTextController.text);
            _commentTextController.clear();
          },
          child: Text('Post Comment'),
        ),
      ],
    );
  }
}
