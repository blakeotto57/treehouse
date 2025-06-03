import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import '../components/user_post.dart';
import '../components/comment.dart';

class UserPostPage extends StatelessWidget {
  final UserPost post;
  final Color categoryColor;

  const UserPostPage({
    super.key,
    required this.post,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkCard = const Color(0xFF232323);
    final darkBackground = const Color(0xFF181818);
   

    return Scaffold(
      backgroundColor: isDark ? darkBackground : pastelGreen,
      drawer: customDrawer(context),
      appBar: const Navbar(),   
      body: Center(
        
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              
              const SizedBox(height: 10),
              
              post,
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.comment, color: categoryColor),
                    const SizedBox(width: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("personal_care_posts")
                          .doc(post.postId)
                          .collection("comments")
                          .snapshots(),
                      builder: (context, snapshot) {
                        final commentsCount =
                            snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          "Comments ($commentsCount)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark
                                ? Colors.white
                                : categoryColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(
                        color: categoryColor.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[900]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: categoryColor.withOpacity(0.2)),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("personal_care_posts")
                        .doc(post.postId)
                        .collection("comments")
                        .orderBy("created on", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data!.docs;
                      if (comments.isEmpty) {
                        return Center(
                          child: Text(
                            "No comments yet.",
                            style: TextStyle(color: categoryColor),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: comments.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: categoryColor.withOpacity(0.1)),
                        itemBuilder: (context, index) {
                          final commentData = comments[index].data() as Map<String, dynamic>;
                          final commentText = commentData['comment'] ?? '';
                          final commentBy = commentData['comment by'] ?? 'Unknown';
                          final timestamp = commentData['created on'] as Timestamp?;
                          final date = timestamp != null
                              ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
                              : null;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? categoryColor.withOpacity(0.10)
                                  : categoryColor.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commentText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 16, color: categoryColor.withOpacity(0.7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      commentBy,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: categoryColor.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.access_time, size: 14, color: categoryColor.withOpacity(0.6)),
                                    const SizedBox(width: 2),
                                    Text(
                                      date != null
                                          ? "${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
                                          : "",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: categoryColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 16, left: 8, right: 8, top: 8),
                child: _CommentInput(
                  postId: post.postId,
                  accentColor: categoryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  final String postId;
  final Color accentColor;
  const _CommentInput({required this.postId, required this.accentColor});

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
            color: widget.accentColor.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: widget.accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentTextController,
              cursorColor: widget.accentColor,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: widget.accentColor.withOpacity(0.7)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: widget.accentColor),
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