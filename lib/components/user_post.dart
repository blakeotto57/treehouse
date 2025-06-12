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
              borderRadius: BorderRadius.circular(16),
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
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: avatar, username, dot, timestamp
                      Row(
                        children: [
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
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Profile picture with fallback to initial
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
                                    return CircleAvatar(
                                      backgroundColor:
                                          forumIconColor.withOpacity(0.15),
                                      radius: 18,
                                      backgroundImage: photoUrl != null &&
                                              photoUrl.isNotEmpty
                                          ? NetworkImage(photoUrl)
                                          : null,
                                      child:
                                          (photoUrl == null || photoUrl.isEmpty)
                                              ? Text(
                                                  user.isNotEmpty
                                                      ? user[0].toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    color: forumIconColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                )
                                              : null,
                                    ); 
                                  },
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  user,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Dot divider
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateTimeString,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Post title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8), // Spacing between title and body
                      // Message body
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Like and comment row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => toggleLike(likes, isLiked),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isLiked ? Colors.redAccent : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  likes.length.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          // Show comment count if available, else 0
                          Text(
                            comments.length.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          // Category flair moved here
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  Color.lerp(forumIconColor, Colors.white, 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
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
