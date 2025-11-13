import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/components/user_post.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/professional_navbar.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/router/app_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  final GlobalKey<SlidingDrawerState> _drawerKey = GlobalKey<SlidingDrawerState>();
  final searchController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  late TextEditingController titleController;
  late TextEditingController bodyController;
  String searchQuery = "";
  bool posting = false;
  List<String> uploadedImages = [];
  bool isBoldMode = false; // Track whether bold mode is active
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isPostButtonEnabled =>
      titleController.text.trim().isNotEmpty &&
      bodyController.text.trim().isNotEmpty &&
      !posting;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    bodyController = TextEditingController();

    // Add listener to update button visibility
    titleController.addListener(() {
      setState(() {}); // Triggers rebuild to update button state
    });

    // Ensure drawer opens immediately if it should be open (no animation delay)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && DrawerState.shouldBeOpen && !(_drawerKey.currentState?.isOpen ?? false)) {
        _drawerKey.currentState?.open();
      }
    });

    // Add listener to apply bold mode to future text
    bodyController.addListener(() {
      if (isBoldMode) {
        final selection = bodyController.selection;
        final text = bodyController.text;

        // Only apply bold tags to new text typed after the cursor
        if (selection.isValid && selection.start == selection.end) {
          final before = selection.textBefore(text);
          final after = selection.textAfter(text);

          // Check if the last typed character is already wrapped in bold tags
          if (!before.endsWith('**')) {
            setState(() {
              bodyController.text = '$before**$after';
              bodyController.selection = TextSelection.collapsed(
                offset: before.length + 2, // Place cursor inside the bold tags
              );
            });
          }
        }
      }
    });
  }


  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  /// === NEW: Helper Function for Formatting ===
  void _applyTextFormat({
    required String leftTag,
    required String rightTag,
  }) {
    final selection = bodyController.selection;
    final text = bodyController.text;

    if (selection.isValid) {
      final selectedText = selection.textInside(text);
      final before = selection.textBefore(text);
      final after = selection.textAfter(text);

      // If nothing selected, just insert the tags at the cursor
      if (selection.start == selection.end) {
        final newText = '$before$leftTag$rightTag$after';
        bodyController.text = newText;
        final cursorPos = (before + leftTag).length;
        bodyController.selection = TextSelection.collapsed(offset: cursorPos);
      } else {
        // Replace selected text with formatted
        final newText = '$before$leftTag$selectedText$rightTag$after';
        bodyController.text = newText;
        // Reselect formatted text
        bodyController.selection = TextSelection(
          baseOffset: before.length + leftTag.length,
          extentOffset: before.length + leftTag.length + selectedText.length,
        );
      }
    }
  }


  void _showCreatePostDialog() async {
    bool posting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _dialogTitleListener() => setState(() {});
            titleController.addListener(_dialogTitleListener);

            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              contentPadding: EdgeInsets.all(24),
              backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                          Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: widget.forumIconColor,
                            selectionColor:
                                isDark ? Colors.grey[700] : Colors.grey[500],
                            selectionHandleColor: widget.forumIconColor,
                          ),
                        ),
                        child: TextField(
                          controller: titleController,
                          cursorColor: widget.forumIconColor,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                                color:
                                    isDark ? Colors.white70 : Colors.black54),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[850] : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color:
                                      isDark ? Colors.white12 : Colors.black12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color:
                                      isDark ? Colors.white12 : Colors.black12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color:
                                      isDark ? Colors.white12 : Colors.black12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12),
                      // Rich text editor row (fake icons, real textfield)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FORMAT BUTTONS ROW
                            Row(
                              children: [
                                  IconButton(
                                  icon: Icon(Icons.format_bold),
                                  color: isBoldMode
                                      ? widget.forumIconColor
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
                                  tooltip: "Bold",
                                  onPressed: () {
                                    setState(() {
                                      isBoldMode =
                                          !isBoldMode; // Toggle bold mode
                                    });

                                    final selection = bodyController.selection;
                                    final text = bodyController.text;

                                    if (selection.isValid) {
                                      final selectedText =
                                          selection.textInside(text);
                                      final before = selection.textBefore(text);
                                      final after = selection.textAfter(text);

                                      setState(() {
                                        if (selection.start == selection.end) {
                                          // No text selected, toggle bold mode for future text
                                          bodyController.text =
                                              '$before**$after';
                                          bodyController.selection =
                                              TextSelection.collapsed(
                                            offset: before.length +
                                                2, // Place cursor inside the bold tags
                                          );
                                        } else {
                                          // Wrap selected text with bold tags
                                          bodyController.text =
                                              '$before**$selectedText**$after';
                                          bodyController.selection =
                                              TextSelection(
                                            baseOffset: before.length + 2,
                                            extentOffset: before.length +
                                                2 +
                                                selectedText.length,
                                          );
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.format_italic),
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  tooltip: "Italic",
                                  onPressed: () {
                                    setState(() {
                                      _applyTextFormat(
                                          leftTag: '*', rightTag: '*');
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.format_underline),
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  tooltip: "Underline",
                                  onPressed: () {
                                    setState(() {
                                      _applyTextFormat(
                                          leftTag: '__', rightTag: '__');
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.image),
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final pickedFile = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (pickedFile != null) {
                                      final storageRef =
                                          FirebaseStorage.instance.ref().child(
                                              'forum_images/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
                                      final uploadTask =
                                          await storageRef.putData(
                                              await pickedFile.readAsBytes());
                                      final downloadUrl =
                                          await storageRef.getDownloadURL();
                                      setState(() {
                                        uploadedImages.add(downloadUrl);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (uploadedImages.isNotEmpty)
                                    Column(
                                      children: uploadedImages
                                          .map((url) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Image.network(url,
                                                    height: 120),
                                              ))
                                          .toList(),
                                    ),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      textSelectionTheme:
                                          TextSelectionThemeData(
                                        cursorColor: widget.forumIconColor,
                                        selectionColor: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[500],
                                        selectionHandleColor:
                                            widget.forumIconColor,
                                      ),
                                    ),
                                    child: SizedBox(
                                      height: 150,
                                      child: TextField(
                                        controller: bodyController,
                                        cursorColor: widget.forumIconColor,
                                        expands: true,
                                        minLines: null,
                                        maxLines: null,
                                        scrollPhysics:
                                            AlwaysScrollableScrollPhysics(),
                                        decoration: InputDecoration(
                                          hintText: 'Body text',
                                          hintStyle: TextStyle(
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.black38),
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              title: Row(
                children: [
                  Icon(Icons.create, color: widget.forumIconColor),
                  SizedBox(width: 8),
                  Text(
                    'Create a Post',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    titleController.clear();
                    bodyController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: widget.forumIconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.forumIconColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: titleController.text.trim().isNotEmpty
                      ? () async {
                          setState(() => posting = true);
                          final postTitle = titleController.text.trim();
                          final postBody = bodyController.text.trim();
                          // Fetch username from Firestore
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.email)
                              .get();
                          final username =
                              userDoc.data()?['username'] ?? 'Unknown';
                          // Create the post and get the document ID
                          final docRef = await FirebaseFirestore.instance
                              .collection(widget.firestoreCollection)
                              .add({
                            "username": username,
                            "title": postTitle,
                            "body_text": postBody,
                            "images":
                                uploadedImages.isNotEmpty ? uploadedImages : [],
                            "timestamp": Timestamp.now(),
                            "likes": [],
                          });
                          // Clear the controllers and uploaded images
                          titleController.clear();
                          bodyController.clear();
                          uploadedImages.clear();
                          setState(() => posting = false);
                          Navigator.pop(context);
                          // Navigate to the new post URL
                          final categoryRoute = AppRouter.getCategoryRouteName(widget.firestoreCollection);
                          context.go('/forum/$categoryRoute/${docRef.id}');
                        }
                      : null, // Disable button if titleController is empty
                  child: posting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navbar = ProfessionalNavbar(drawerKey: _drawerKey);
    final headerHeight = navbar.preferredSize.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final headerTotalHeight = topPadding + headerHeight;

    // Match the header background color exactly
    final background = isDark 
        ? AppColors.backgroundDark 
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Sliding drawer and content - full screen
          SlidingDrawer(
            key: _drawerKey,
            drawer: customDrawer(context),
            appBarHeight: headerTotalHeight,
            child: Column(
              children: [
                // Spacer for header (SafeArea + navbar)
                SizedBox(height: headerTotalHeight),
                // Content area
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Page title
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: widget.forumIconColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Search bar
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  cursorColor: widget.forumIconColor,
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
                                        color:
                                            isDark ? Colors.grey[400] : Colors.grey[600]),
                                    prefixIcon: Icon(Icons.search, color: widget.forumIconColor),
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
                                          color: widget.forumIconColor, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection(widget.firestoreCollection)
                                      .orderBy("timestamp", descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final docs = snapshot.data!.docs;
                                      if (docs.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.forum_outlined,
                                                size: 64,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                "No posts yet.",
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Be the first to start a discussion!",
                                                style: TextStyle(
                                                    color: Colors.grey[500], fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // Filter posts by search query
                                      final filteredPosts = docs.where((doc) {
                                        final data = doc.data() as Map<String, dynamic>;
                                        return searchQuery.isEmpty ||
                                            (data["body_text"] ?? "")
                                                .toString()
                                                .toLowerCase()
                                                .contains(searchQuery.toLowerCase()) ||
                                            (data["title"] ?? "")
                                                .toString()
                                                .toLowerCase()
                                                .contains(searchQuery.toLowerCase());
                                      }).toList();

                                      if (filteredPosts.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.search_off,
                                                size: 64,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                "No posts found.",
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Try a different search term.",
                                                style: TextStyle(
                                                    color: Colors.grey[500], fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return ListView.separated(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        itemCount: filteredPosts.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final post = filteredPosts[index].data()
                                              as Map<String, dynamic>;
                                          return UserPost(
                                            message: post["body_text"] ?? '',
                                            user: post["username"] ?? '',
                                            title: post["title"] ?? '',
                                            likes: List<String>.from(post["likes"] ?? []),
                                            timestamp: post["timestamp"] ?? Timestamp.now(),
                                            category: widget.firestoreCollection,
                                            forumIconColor: widget.forumIconColor,
                                            documentId: filteredPosts[index].id,
                                          );
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 64,
                                              color: Colors.red[300],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Error loading posts",
                                              style: TextStyle(
                                                  color: Colors.red[600],
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${snapshot.error}",
                                              style: TextStyle(
                                                  color: Colors.grey[500], fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Fixed header on top - always visible above drawer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: headerHeight,
                child: navbar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
