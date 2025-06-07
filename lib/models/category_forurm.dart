import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:treehouse/components/user_post.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';

class CategoryForumPage extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color appBarColor;
  final Color forumIconColor;
  final String firestoreCollection;

  const CategoryForumPage({
    Key? key,
    required this.title,
    required this.icon,
    required this.appBarColor,
    required this.forumIconColor,
    required this.firestoreCollection,
  }) : super(key: key);

  @override
  State<CategoryForumPage> createState() => _CategoryForumPageState();
}

class _CategoryForumPageState extends State<CategoryForumPage> {
  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  String searchQuery = "";

  Future<void> postMessage() async {
    if (textController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection(widget.firestoreCollection)
          .doc(textController.text)
          .set({
        "email": FirebaseAuth.instance.currentUser?.email,
        "message": textController.text,
        "timestamp": Timestamp.now(),
        "likes": [],
      });
      setState(() {
        textController.clear();
      });
      FocusScope.of(context).unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF181818) : const Color(0xFFF5FBF7);

    return Scaffold(
      backgroundColor: background,
      drawer: customDrawer(context),
      appBar: const Navbar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: textController,
                    cursorColor: Colors.black,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search posts...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF386A53)),
                      
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFF386A53), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Section header
                Row(
                  children: [
                    Icon(widget.icon, color: widget.forumIconColor),
                    const SizedBox(width: 8),
                    Text(
                      "${widget.title} Forum",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: widget.forumIconColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? Colors.white24
                            : widget.forumIconColor.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(widget.firestoreCollection)
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var filteredPosts = snapshot.data!.docs.where((doc) {
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;
                          return searchQuery.isEmpty ||
                              data["message"]
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase());
                        }).toList();

                        if (filteredPosts.isEmpty) {
                          return const Center(
                            child: Text(
                              "No posts found.",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredPosts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index].data()
                                as Map<String, dynamic>;
                            return UserPost(
                              message: post["message"],
                              user: post["email"],
                              postId: post["message"],
                              likes: List<String>.from(post["likes"] ?? []),
                              timestamp: post["timestamp"],
                              category: widget.title,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                // Message Input
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 16, left: 8, right: 8, top: 8),
                  child: Container(
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
                            controller: textController,
                            cursorColor: Colors.black54,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: "Type your message...",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send,
                              color: isDark
                                  ? Colors.white
                                  : widget.forumIconColor),
                          onPressed: postMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
