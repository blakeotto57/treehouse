import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/components/comment.dart';
import 'package:treehouse/components/delete_button.dart';
import 'package:treehouse/components/like_button.dart';

import '../helper/helper_methods.dart';

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
  bool isLiked = false;

  // comment
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    DocumentReference postRef = FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId);

    if (isLiked) {
      postRef.update({
        "likes": FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postRef.update({
        "likes": FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }


  //show comment list
  void showCommentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Comments List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("personal_care_posts")
                      .doc(widget.postId)
                      .collection("comments")
                      .orderBy("created on", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    //show loading circle if no data
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map((comment) {
                        //get comment data
                        final commentData =
                            comment.data() as Map<String, dynamic>;

                        // return the comment tile
                        return Comment(
                          comment: commentData["comment"],
                          user: commentData["comment by"],
                          time: formatDate(commentData["created on"]),
                          likes: List<String>.from(commentData["likes"] ?? []), // Fix: properly cast likes array
                          postId: widget.postId, 
                          commentId: commentData["comment"],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              // Comment Input Field
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentTextController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        addComment(_commentTextController.text);

                        // pop the box
                        Navigator.pop(context);

                        // clear the text field
                        _commentTextController.clear();
                      },
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  
  void addComment(String comment, {String? parentId}) {
    FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(comment)
        .set({
          "comment": comment,
          "comment by": currentUser.email,
          "created on": Timestamp.now(),
          "likes": [], // Initialize empty likes array
        });
  }

  // edit (delete) post logic
  void editPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // delete button
          TextButton(
            onPressed: () async {
              // delete from firebase
              final commentDocs = await FirebaseFirestore.instance
                  .collection("personal_care_posts")
                  .doc(widget.postId)
                  .collection("comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("personal_care_posts")
                    .doc(widget.postId)
                    .collection("comments")
                    .doc(doc.id)
                    .delete();
              }

              //then delete the post
              FirebaseFirestore.instance
                  .collection("personal_care_posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("Post deleted"))
                  .catchError(
                      (error) => print("Failed to delete post: $error"));

              // pop the box
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build your widget tree (unchanged, except for toggleLike usage).
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, user, date, delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.green,
                radius: 20,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),

              //user
              Text(
                widget.user,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),

              Text(
                "•",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              //date
              Text(
                DateFormat('MM/dd/yyyy').format(widget.timestamp.toDate()),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(width: 2),

              // delete button
              if (currentUser.email == widget.user)
                DeleteButton(
                  onTap: editPost,
                ),
            ],
          ),

          const SizedBox(height: 5),

          // Message
          Row(
            children: [
              const SizedBox(width: 50),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          // Like and Comment Buttons
          Row(
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

              // comment button
              IconButton(
                onPressed: showCommentDialog,
                icon: const Icon(Icons.comment),
                color: Colors.grey,
              ),

              // comment count (live from Firestore)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("personal_care_posts")
                    .doc(widget.postId)
                    .collection("comments")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      "0",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    );
                  }
                  return Text(
                    snapshot.data!.docs.length.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
