import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/components/delete_button.dart';
import 'package:treehouse/components/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment extends StatefulWidget {
  final String comment; // Changed from message
  final String user;
  final String time;
  final List<String> likes;
  final String postId;
  final String commentId;

  Comment({
    super.key,
    required this.comment, // Changed from message
    required this.user,
    required this.time,
    required this.likes,
    required this.postId,
    required this.commentId,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _commentTextController = TextEditingController();
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Get reference to the comment document
    DocumentReference commentRef = FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(widget.comment);

    if (isLiked) {
      // Add user's email to likes array
      commentRef.update({
        "likes": FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // Remove user's email from likes array
      commentRef.update({
        "likes": FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with username and collapse button
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                widget.user,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Comment content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 8),

                // comment
                child: Text(
                  widget.comment, // Changed from message
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Only show delete icon for comment owner
              if (currentUser.email == widget.user)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: deleteComment,
                  color: Colors.grey,
                  iconSize: 20,
                  padding: EdgeInsets.zero, // Tighter padding for comments
                  constraints: const BoxConstraints(), // Minimize constraints
                ),
            ],
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 8),
            child: Row(
              children: [
                LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLike,
                ),

                const SizedBox(width: 5),
                // like count
                Text(
                  widget.likes.length.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteComment() async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('personal_care_posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .delete();

      if (context.mounted) {
        showSnackBar('Comment deleted successfully', context);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(e.toString(), context);
      }
    }
  }

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }
}
