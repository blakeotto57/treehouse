import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/components/comment.dart';
import 'package:treehouse/components/comment_button.dart';
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

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  // show dialog box for adding a comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(
            hintText: "Comment here",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          maxLines: null,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear the text field
              _commentTextController.clear();
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

          // add button
          TextButton(
            onPressed: () {
              //add the comment
              addComment(_commentTextController.text);

              // pop the box
              Navigator.pop(context);

              // clear the text field
              _commentTextController.clear();
            },
            child: const Text(
              "Post",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //add a comment to the post
  void addComment(String commentText, {String? parentId}) {
    FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId)
        .collection("comments")
        .add({
      "comment": commentText,
      "comment by": currentUser.email,
      "created on": Timestamp.now(),
      "parentId": parentId, // null for top-level comments
      "depth": parentId != null ? 1 : 0 // track nesting level
    });

    //access the document in FIrebase
    DocumentReference postRef = FirebaseFirestore.instance
        .collection("personal_care_posts")
        .doc(widget.postId);

    if (isLiked) {
      // add the user to the likes array
      postRef.update({
        "likes": FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      // remove the user from the likes array
      postRef.update({
        "likes": FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  // edit post
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

              const SizedBox(width: 2),

              //space
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

              // detele button
              if (currentUser.email == widget.user)
                DeleteButton(
                  onTap: editPost,
                ),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const SizedBox(width: 50),

              //message
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          // Like and comment buttons
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

              //comment button
              IconButton(
                onPressed: showCommentDialog,
                icon: const Icon(Icons.comment),
                color: Colors.grey,
              ),

              //comment count
              Text(
                "0",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          //coments under post
          StreamBuilder<QuerySnapshot>(
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
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((comment) {
                  //get comment data
                  final commentData = comment.data() as Map<String, dynamic>;

                  // return the comment tile
                  return Comment(
                    message: commentData["comment"],
                    user: commentData["comment by"],
                    time: formatDate(commentData["created on"]),
                    likes: [],
                    postId: widget.postId,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
