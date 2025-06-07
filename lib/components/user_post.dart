import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/components/comment.dart';
import 'package:treehouse/components/delete_button.dart';
import 'package:treehouse/components/like_button.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:treehouse/models/user_post_page.dart';
import 'dart:io';

import '../helper/helper_methods.dart';

class UserPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final Timestamp timestamp;
  final String category; // Add this

  const UserPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.timestamp,
    required this.category, // Add this
  });

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void toggleLike(List<String> likes, bool isLiked) {
    DocumentReference postRef = FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId);

    if (isLiked) {
      postRef.update({
        "likes": FieldValue.arrayRemove([currentUser.email]),
      });
    } else {
      postRef.update({
        "likes": FieldValue.arrayUnion([currentUser.email]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername = currentUser.email?.split('@').first ?? '';
    final isOwner = currentUsername == widget.user;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("personal_care_posts")
          .doc(widget.postId)
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

        return Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        UserPostPage(
                      post: widget,
                      categoryColor: const Color(0xFF386A53),
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.user)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.data() != null) {
                                      final userData = snapshot.data!.data()
                                          as Map<String, dynamic>;
                                      final username = userData['username'] ??
                                          widget.user.split('@').first;
                                      final isDarkMode =
                                          Theme.of(context).brightness ==
                                              Brightness.dark;

                                      // Format date and time
                                      final dateTimeString = widget.timestamp !=
                                              null
                                          ? DateFormat('MMM d, h:mm a')
                                              .format(widget.timestamp.toDate())
                                          : '';

                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherUsersProfilePage(
                                                          username: username),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      userData[
                                                              'profileImageUrl'] ??
                                                          ''),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  username,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (dateTimeString.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            const Text('•',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey)),
                                            const SizedBox(width: 8),
                                            Text(
                                              dateTimeString,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: isDarkMode
                                                    ? Colors.grey[500]
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ],
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.message.split('\n').first,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.message.contains('\n'))
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            widget.message.split('\n').skip(1).join('\n'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Heart Icon with Like Count
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
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Comment Icon with Comment Count
                          const Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.grey,
                            size: 18,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("personal_care_posts")
                                .doc(widget.postId)
                                .collection("comments")
                                .snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 0),
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
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
  final String postId;
  const _CommentInput({required this.postId});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _commentTextController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  void addComment(String comment) {
    if (comment.trim().isEmpty) return;
    FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(comment)
        .set({
      "comment": comment,
      "comment by": currentUser.email,
      "created on": Timestamp.now(),
      "likes": [],
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentTextController,
              cursorColor: Colors.black,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send,
                color: isDark ? Colors.white : const Color(0xFF386A53)),
            onPressed: () {
              addComment(_commentTextController.text);
              FocusScope.of(context).unfocus();
              _commentTextController.clear();
            },
          ),
        ],
      ),
    );
  }
}

class _VerticalLinePainter extends CustomPainter {
  final Color color;
  _VerticalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0;
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget buildUserPost(BuildContext context, bool isPostAndCommentsPage) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.15),
      ),
    ),
  );
}
