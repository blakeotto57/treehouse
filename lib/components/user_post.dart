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
  String? profileImageUrl;

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
                          likes: List<String>.from(commentData["likes"] ??
                              []), // Fix: properly cast likes array
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

                        // Close keyboard
                        FocusScope.of(context).unfocus();

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

  void deletePost() {
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

  Future<void> pickAndUploadImage() async {
    try {
      // Initialize Firebase App Check if not already done
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        // Use debug provider for development
        // androidProvider: AndroidProvider.debug,
      );

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw 'No user logged in';
      }

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      // Get reference to Firestore
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email);

      // Create user document if it doesn't exist
      if (!(await userDoc.get()).exists) {
        await userDoc.set({
          'email': currentUser.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${currentUser.email}');

      final File imageFile = File(image.path);
      await storageRef.putFile(imageFile);

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore with new image URL
      await userDoc.update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update UI
      setState(() {
        profileImageUrl = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green[800],
          ),
        );
      }

    } catch (e) {
      print('Error updating profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            children: [
              // Profile picture
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green[300],
                      child: const Icon(Icons.person, color: Colors.white),
                    );
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>?;
                  final profileImageUrl = userData?['profileImageUrl'] as String?;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to user profile or show details
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green[300],
                      backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null || profileImageUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              // Username
              widget.user == currentUser.email
                  ? Text(
                      widget.user.contains('@')
                          ? widget.user.split('@')[0]
                          : widget.user,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUsersProfilePage(username: widget.user),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        widget.user.contains('@')
                          ? widget.user.split('@')[0]
                          : widget.user,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,                          
                          color: Colors.blue,
                          fontSize: 16,
                          
                        ),
                      ),
                    ),
              const Spacer(),
              if (currentUser.email == widget.user)
                DeleteButton(
                  onTap: deletePost,
                ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),

          // Message
          Row(
            children: [
              const SizedBox(width: 50),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[800],
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