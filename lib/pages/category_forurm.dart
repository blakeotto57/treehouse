import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/components/user_post.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
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
                          await FirebaseFirestore.instance
                              .collection(widget.firestoreCollection)
                              .doc(postTitle)
                              .set({
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
    final background =
        isDark ? const Color(0xFF181818) : const Color(0xFFF5FBF7);

    final GlobalKey<SlidingDrawerState> _drawerKey =
        GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context), // Use customDrawerContent from drawer.dart
      child: Scaffold(
        backgroundColor: background,
        drawer: customDrawer(context),
        appBar: Navbar(drawerKey: _drawerKey),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
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
                      controller: searchController,
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
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600]),
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
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(widget.firestoreCollection)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: widget.forumIconColor));
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'));
                        }

                        var docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.forum_outlined,
                                    size: 64,
                                    color: widget.forumIconColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No posts yet in ${widget.title}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Be the first to start a conversation!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final document = docs[index].data() as Map<String, dynamic>;

                            // Add section headers for date grouping if needed
                            Widget? dateHeader;
                            if (index == 0 ||
                                _shouldShowDateHeader(docs[index], docs[index - 1])) {
                              final timestamp = document['timestamp'] as Timestamp;
                              dateHeader = _buildDateHeader(timestamp.toDate());
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dateHeader != null) dateHeader,
                                UserPost(
                                  message: document['message'] ?? '',
                                  user: document['user'] ?? '',
                                  timestamp: document['timestamp'] ?? Timestamp.now(),
                                  likes: List<String>.from(document['likes'] ?? []),
                                  title: document['title'] ?? '',
                                  category: widget.firestoreCollection,
                                  forumIconColor: widget.forumIconColor,
                                ),
                                // Very subtle divider between posts
                                Container(
                                  height: 6,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.05),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add_circle, color: Colors.white),
                        label: Text(
                          'Create Post',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.forumIconColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: widget.forumIconColor.withOpacity(0.3),
                        ),
                        onPressed: _showCreatePostDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDateHeader(DocumentSnapshot current, DocumentSnapshot previous) {
    final currentData = current.data() as Map<String, dynamic>;
    final previousData = previous.data() as Map<String, dynamic>;

    final currentDate = (currentData['timestamp'] as Timestamp).toDate();
    final previousDate = (previousData['timestamp'] as Timestamp).toDate();

    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final headerDate = DateTime(date.year, date.month, date.day);

    String headerText;
    if (headerDate == today) {
      headerText = 'Today';
    } else if (headerDate == yesterday) {
      headerText = 'Yesterday';
    } else {
      headerText = DateFormat('EEEE, MMMM d').format(date);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.transparent,
      child: Row(
        children: [
          Text(
            headerText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}
