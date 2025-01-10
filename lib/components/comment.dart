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
              GestureDetector(
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                onTap: () =>
                    editComment(widget.comment), // Changed from message
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

                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // edit comment
  void editComment(String comment) {
    final TextEditingController _editingController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit Comment'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: TextField(
            controller: _editingController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Edit your comment...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editingController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment cannot be empty')),
                  );
                  return;
                }
                // TODO: Implement comment update logic here
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }
}
