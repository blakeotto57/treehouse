import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:treehouse/components/user_post.dart';

class CategoryForumPage extends StatefulWidget {
  final String collectionName;
  final String forumTitle;
  final Color appBarColor;
  final Color iconColor;
  final IconData forumIcon;

  const CategoryForumPage({
    Key? key,
    required this.collectionName,
    required this.forumTitle,
    required this.appBarColor,
    required this.iconColor,
    required this.forumIcon,
  }) : super(key: key);

  @override
  State<CategoryForumPage> createState() => _CategoryForumPageState();
}

class _CategoryForumPageState extends State<CategoryForumPage> {
  final textController = TextEditingController();
  final searchController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  String searchQuery = '';

  Future<void> postMessage() async {
    if (textController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
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
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search posts",
                      hintStyle: const TextStyle(
                        color: Colors.grey, // Customize hint text color
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12), // Adjust vertical padding
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Section header
                Row(
                  children: [
                    Icon(widget.forumIcon, color: widget.iconColor),
                    const SizedBox(width: 8),
                    Text(
                      widget.forumTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDark ? Colors.white : widget.iconColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? Colors.white24
                            : widget.iconColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(widget.collectionName)
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
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white // Text color for dark mode
                                  : Colors.black, // Text color for light mode
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter your text here...",
                              hintStyle: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400] // Hint text color for dark mode
                                    : Colors.grey[600], // Hint text color for light mode
                              ),
                            ),
                          ),
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