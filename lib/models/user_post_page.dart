import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import '../components/user_post.dart';

class UserPostPage extends StatelessWidget {
  final String postId;
  final Color categoryColor;
  final String firestoreCollection;

  const UserPostPage({
    super.key,
    required this.postId,
    required this.categoryColor,
    required this.firestoreCollection,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkBackground = const Color(0xFF181818);

    final GlobalKey<SlidingDrawerState> _drawerKey =
        GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context),
      child: Scaffold(
        backgroundColor: isDark ? darkBackground : pastelGreen,
        drawer: customDrawer(context),
        appBar: Navbar(drawerKey: _drawerKey),
        body: FutureBuilder<DocumentSnapshot>(
          future: _getPostDocument(postId, firestoreCollection),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Post not found.'));
            }
            final postData = snapshot.data!.data() as Map<String, dynamic>;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    UserPost(
                      message: postData["body_text"] ?? '',
                      user: postData["username"] ?? '',
                      title: postData["title"] ?? '',
                      likes: List<String>.from(postData["likes"] ?? []),
                      timestamp: postData["timestamp"] ?? Timestamp.now(),
                      category: firestoreCollection,
                      forumIconColor: categoryColor,
                      documentId: postId,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection(firestoreCollection)
                                .doc(postId)
                                .collection("comments")
                                .snapshots(),
                            builder: (context, snapshot) {
                              final commentsCount = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;
                              return Text(
                                "Comments ($commentsCount)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : categoryColor,
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
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: categoryColor.withOpacity(0.2)),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(firestoreCollection)
                              .doc(postId)
                              .collection("comments")
                              .orderBy("created on", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final docs = snapshot.data!.docs;
                              if (docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No comments yet.",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                );
                              }
                              return ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: docs.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final commentData = docs[index].data()
                                      as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(commentData["comment"] ?? ''),
                                    subtitle: Text(commentData["comment by"] ?? ''),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 8, right: 8, top: 8),
                      child: _CommentInput(
                        postId: postId,
                        firestoreCollection: firestoreCollection,
                        accentColor: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  final String postId;
  final String firestoreCollection;
  final Color accentColor;

  const _CommentInput({
    required this.postId,
    required this.firestoreCollection,
    required this.accentColor,
  });

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _commentTextController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  void addComment(String comment) {
    if (comment.trim().isEmpty) return;
    FirebaseFirestore.instance
        .collection(widget.firestoreCollection)
        .doc(widget.postId)
        .collection("comments")
        .add({
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
                hintStyle:
                    TextStyle(color: widget.accentColor.withOpacity(0.7)),
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

Future<DocumentSnapshot> _getPostDocument(String postId, String firestoreCollection) async {
  // First try to get the document by ID (for new posts)
  final docSnapshot = await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(postId)
      .get();
  
  if (docSnapshot.exists) {
    return docSnapshot;
  }
  
  // If not found by ID, try to find by title (for old posts)
  // For posts with duplicate titles, we'll get the most recent one
  final querySnapshot = await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .where('title', isEqualTo: postId)
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();
  
  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first;
  }
  
  // If still not found, return the original empty snapshot
  return docSnapshot;
}
