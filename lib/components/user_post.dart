import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  const UserPost({
    Key? key,
    required this.message,
    required this.user,
    required this.likes,
    required this.timestamp,
    required this.category,
    required this.forumIconColor,
    required this.title, // Added title property
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isOwner = currentUser.email == user;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(category)
          .doc(title) // Use title as the document ID
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
                    pageBuilder: (context, animation1, animation2) =>
                        UserPostPage(
                      post: this,
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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Forum header with category indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: forumIconColor.withOpacity(0.08),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Title area with better typography
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Post metadata badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: forumIconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dateTimeString,
                              style: TextStyle(
                                fontSize: 12,
                                color: forumIconColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Message content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        message,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[800],
                        ),
                      ),
                    ),
                    
                    // Post footer with user info and interaction stats
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          // User info section
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          OtherUsersProfilePage(
                                    username: user,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                // Profile picture
                                FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .where('username', isEqualTo: user)
                                      .limit(1)
                                      .get(),
                                  builder: (context, userSnapshot) {
                                    String? photoUrl;
                                    if (userSnapshot.hasData &&
                                        userSnapshot.data!.docs.isNotEmpty) {
                                      final userData =
                                          userSnapshot.data!.docs.first.data()
                                              as Map<String, dynamic>;
                                      photoUrl = userData['profileImageUrl']
                                          as String?;
                                    }
                                    return Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: forumIconColor.withOpacity(0.2),
                                        border: Border.all(
                                          color: forumIconColor.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: photoUrl != null
                                            ? Image.network(
                                                photoUrl,
                                                fit: BoxFit.cover,
                                                width: 32,
                                                height: 32,
                                              )
                                            : Icon(
                                                Icons.person,
                                                color: forumIconColor.withOpacity(0.7),
                                                size: 18,
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  user,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: forumIconColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Post stats and actions
                          Row(
                            children: [
                              // Comments count
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    comments.length.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Like button and count
                              GestureDetector(
                                onTap: () async {
                                  String postId = title;
                                  DocumentReference docRef = FirebaseFirestore.instance
                                      .collection(category)
                                      .doc(postId);
                                  
                                  if (isLiked) {
                                    await docRef.update({
                                      'likes': FieldValue.arrayRemove([currentUser.email])
                                    });
                                  } else {
                                    await docRef.update({
                                      'likes': FieldValue.arrayUnion([currentUser.email])
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.redAccent : Colors.grey[600],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      likes.length.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isLiked ? Colors.redAccent : Colors.grey[600],
                                      ),
                                    ),
                                  ],
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
        FirebaseFirestore.instance.collection(category).doc(title);

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
