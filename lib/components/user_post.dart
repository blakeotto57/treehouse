import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/components/comment.dart';
import 'package:treehouse/components/delete_button.dart';
import 'package:treehouse/components/like_button.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../helper/helper_methods.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _sortBy = 'Most Recent'; // or 'Most Liked'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), // Adjust width as needed
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Sort by:", style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(value: 'Most Recent', child: Text('Most Recent')),
                        DropdownMenuItem(value: 'Most Liked', child: Text('Most Liked')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      underline: Container(),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: 400, // Constrain search bar width
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ),
              // Posts list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("personal_care_posts").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    List<Post> posts = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Post(
                        message: data['message'],
                        user: data['user'],
                        postId: doc.id,
                        likes: List<String>.from(data['likes'] ?? []),
                        timestamp: data['timestamp'],
                      );
                    }).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final sortedPosts = [...posts];
                        if (_sortBy == 'Most Recent') {
                          sortedPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                        } else {
                          sortedPosts.sort((a, b) => b.likes.length.compareTo(a.likes.length));
                        }
                        final post = sortedPosts[index];
                        return Center(
                          child: SizedBox(
                            width: 500, // Constrain post width
                            child: UserPost(
                              message: post.message,
                              user: post.user,
                              postId: post.postId,
                              likes: post.likes,
                              timestamp: post.timestamp,
                            ),
                          ),
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
    );
  }
}

class Post {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final Timestamp timestamp;

  Post({
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.timestamp,
  });
}

class UserPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final Timestamp timestamp;

  const UserPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.timestamp,
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

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(post: widget),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String? profileImageUrl;
                          if (snapshot.hasData && snapshot.data!.data() != null) {
                            final data = snapshot.data!.data() as Map<String, dynamic>;
                            profileImageUrl = data['profileImageUrl'] as String?;
                          } else {
                            profileImageUrl = null;
                          }
                          return CircleAvatar(
                            radius: 16,
                            backgroundColor: (profileImageUrl == null || profileImageUrl.isEmpty)
                                ? const Color(0xFF386A53)
                                : Colors.grey[300],
                            backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                                ? NetworkImage(profileImageUrl)
                                : null,
                            child: (profileImageUrl == null || profileImageUrl.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white, size: 18)
                                : null,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
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
                                if (snapshot.hasData && snapshot.data!.data() != null) {
                                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                                  final username = userData['username'] ?? widget.user.split('@').first;
                                  return Text(
                                    username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  );
                                } else {
                                  // Fallback to email prefix if username not found
                                  return Text(
                                    widget.user.split('@').first,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  );
                                }
                              },
                            ),
                            Text(
                              timeAgo(widget.timestamp.toDate()),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentUser.email == widget.user)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          tooltip: "Delete Post",
                          onPressed: () {
                            // TODO: Implement delete functionality
                          },
                          splashRadius: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message.split('\n').first,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.redAccent : Colors.grey,
                          size: 18,
                        ),
                        tooltip: "Like",
                        onPressed: () => toggleLike(likes, isLiked),
                        splashRadius: 16,
                      ),
                      Text(
                        likes.length.toString(),
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(width: 18),
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
                          final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4, right: 0),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 18),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.grey, size: 18),
                        tooltip: "Share",
                        onPressed: () {
                          // TODO: Implement share functionality
                        },
                        splashRadius: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class PostDetailPage extends StatelessWidget {
  final UserPost post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF181818) : const Color(0xFFF5FBF7);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Post & Comments"),
        backgroundColor: const Color(0xFF386A53),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const SizedBox(height: 16),
              post,
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.comment, color: Color(0xFF386A53)),
                    const SizedBox(width: 8),
                    Text(
                      "Comments",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : const Color(0xFF386A53),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.white24 : const Color(0xFF386A53).withOpacity(0.2),
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
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                        return const Center(
                          child: Text("No comments yet.", style: TextStyle(color: Colors.grey)),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: comments.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final commentData = comments[index].data() as Map<String, dynamic>;
                          return TreeComment(
                            commentData: commentData,
                            postId: post.postId,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8, top: 8),
                child: _CommentInput(postId: post.postId),
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
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 20),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: isDark ? Colors.white : const Color(0xFF386A53)),
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

class TreeComment extends StatefulWidget {
  final Map<String, dynamic> commentData;
  final String postId;
  final int depth;

  const TreeComment({
    super.key,
    required this.commentData,
    required this.postId,
    this.depth = 0,
  });

  @override
  State<TreeComment> createState() => _TreeCommentState();
}

class _TreeCommentState extends State<TreeComment> {
  late List likes;
  late bool isLiked;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    likes = widget.commentData['likes'] ?? [];
    isLiked = currentUser != null && likes.contains(currentUser!.email);
  }

  void toggleLike() async {
    final commentRef = FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(widget.commentData['comment']);

    setState(() {
      if (isLiked) {
        likes.remove(currentUser!.email);
      } else {
        likes.add(currentUser!.email);
      }
      isLiked = !isLiked;
    });

    await commentRef.update({
      "likes": isLiked
          ? FieldValue.arrayUnion([currentUser!.email])
          : FieldValue.arrayRemove([currentUser!.email]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commentId = widget.commentData['id'] ?? widget.commentData['comment'];
    final children = widget.commentData['children'] as List<Map<String, dynamic>>? ?? [];

    return Padding(
      padding: EdgeInsets.only(left: widget.depth * 18.0, right: 4, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.depth > 0)
            Container(
              width: 12,
              child: CustomPaint(
                painter: _VerticalLinePainter(
                  color: isDark ? Colors.white24 : Colors.grey[300]!,
                ),
                size: const Size(12, 48),
              ),
            ),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.commentData['comment by']?.split('@').first ?? 'user',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(widget.commentData['created on']),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.commentData['comment'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isLiked ? Colors.redAccent : Colors.grey[600],
                          ),
                          onPressed: toggleLike,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 14,
                        ),
                        Text(
                          likes.length.toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement reply functionality
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(30, 24),
                          ),
                          child: const Text('Reply', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    if (children.isNotEmpty)
                      ...children.map((child) => TreeComment(
                            commentData: child,
                            postId: widget.postId,
                            depth: widget.depth + 1,
                          )),
                  ],
                ),
              ),
            ),
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
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}