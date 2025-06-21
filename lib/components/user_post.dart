import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/models/user_post_page.dart';

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
                Navigator.pushNamed(
                  context,
                  '/post/${documentId}',
                  arguments: {
                    'categoryColor': forumIconColor,
                    'firestoreCollection': category,
                  },
                );
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF252525)
                    : Colors.white,
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
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OtherUsersProfilePage(username: user),
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
                                      // Handle send to user
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
