import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // <-- Add this import


class MessagesPage extends StatefulWidget {
  MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  String? selectedUserEmail;
  String? selectedUserName;
  String? selectedUserProfileUrl;

  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onChatSelected(String userEmail) {
    setState(() {
      selectedUserEmail = userEmail;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkCard = const Color(0xFF232323);
    final darkBackground = const Color(0xFF181818);

    return Scaffold(
      backgroundColor: Colors.green[50],
      drawer: customDrawer(context),
      appBar: const Navbar(),
      body: Row(
        children: [
          // Left: Conversations List
          Container(
            width: 320,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Messages",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _chatService.getAcceptedChatsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final users = snapshot.data!;
                      if (users.isEmpty) {
                        return const Center(child: Text('No conversations yet'));
                      }
                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[200],
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final email = user["email"];
                          final username = user["username"] ?? user["name"] ?? email;
                          final profileUrl = user["profileImageUrl"];
                          final isSelected = selectedUserEmail == email;

                          // Example: lastMessage = {'text': 'hello', 'sender': 'CoolKidCarsen'}
                          final lastMessage = user['lastMessage'] ?? {};
                          final lastSender = lastMessage['sender'] ?? username;
                          final lastMessageText = lastMessage['text'] ?? '';

                          return Material(
                            color: isSelected ? Colors.grey[200] : Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(0),
                              onTap: () {
                                _onChatSelected(email);
                                setState(() {
                                  selectedUserName = username;
                                  selectedUserProfileUrl = profileUrl;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage:
                                          profileUrl != null ? NetworkImage(profileUrl) : null,
                                      backgroundColor: Colors.grey[300],
                                      child: profileUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            username,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "$lastSender: $lastMessageText",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.more_horiz, color: isSelected ? Colors.black : Colors.grey[500]),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Edit Conversation'),
                                            content: const Text('Do you want to delete this conversation?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // _chatService.deleteConversation(email);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                              
                                            ],
                                          ),
                                        );
                                      },
                                      splashRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Right: Chat Page
          Expanded(
            child: selectedUserEmail == null
                ? Center(
                    child: Text(
                      "Select a conversation",
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                  )
                : Container(
                    color: Colors.green[50],
                    child: Column(
                      children: [
                        
                        // Chat messages
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: _ChatMessagesWidget(
                                  receiverEmail: selectedUserEmail!,
                                  themeColor: const Color(0xFF386A53),
                                  scrollController: _scrollController,
                                ),
                              ),
                              Divider(
                                color: Color(0xFF386A53),
                                thickness: 1,
                                height: 1,
                              ),
                              // Message input
                              _ChatInputWidget(
                                onSend: (text) {},
                                receiverEmail: selectedUserEmail!,
                                currentUserEmail: _authService.currentUser?.email ?? '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date, Key? key}) : super(key: key);

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);

    String dayString;
    if (messageDay == today) {
      dayString = "Today";
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      dayString = "Yesterday";
    } else {
      dayString = "${date.month}/${date.day}/${date.year}";
    }

    // Format time as h:mm a (e.g., 2:15 PM)
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? "PM" : "AM";
    final timeString = "$hour:$minute $ampm";

    return "$dayString · $timeString";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDateTime(date),
          style: const TextStyle(color: Colors.black87, fontSize: 13),
        ),
      ),
    );
  }
}


// Chat messages widget (moved from ChatPage)
class _ChatMessagesWidget extends StatelessWidget {
  final String receiverEmail;
  final Color themeColor;
  final ScrollController scrollController;

  const _ChatMessagesWidget({
    required this.receiverEmail,
    required this.themeColor,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = AuthService().currentUser?.email;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(_getChatId(currentUserEmail, receiverEmail))
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!.docs;

        // Build a list of widgets with date separators
        List<Widget> messageWidgets = [];
        DateTime? lastDate;

        for (int i = 0; i < messages.length; i++) {
          final message = messages[i];
          final data = message.data() as Map<String, dynamic>;
          final timestamp = data['timestamp'];
          DateTime? messageDate;
          if (timestamp is Timestamp) {
            messageDate = timestamp.toDate();
          }

          // Insert a date separator if it's the first message or a new day
          if (messageDate != null) {
            if (lastDate == null ||
                messageDate.year != lastDate.year ||
                messageDate.month != lastDate.month ||
                messageDate.day != lastDate.day) {
              messageWidgets.add(_DateSeparator(date: messageDate));
              lastDate = messageDate;
            }
          }

          messageWidgets.add(_MessageBubble(message: message));
        }

        return ListView.builder(
          controller: scrollController,
          reverse: true, // This makes the list start from the bottom
          itemCount: messageWidgets.length,
          itemBuilder: (context, index) {
            // Reverse the list so newest messages are at the bottom
            return messageWidgets[messageWidgets.length - 1 - index];
          },
        );
      },
    );
  }
}

// Message input widget
class _ChatInputWidget extends StatefulWidget {
  final void Function(String) onSend;
  final String receiverEmail;
  final String currentUserEmail;

  const _ChatInputWidget({
    required this.onSend,
    required this.receiverEmail,
    required this.currentUserEmail,
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<_ChatInputWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isFocused = false;
  bool showEmojiPicker = false;
  XFile? pickedImage; // Add this line

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
        if (isFocused) showEmojiPicker = false;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty && pickedImage == null) return;

    String? imageUrl;
    if (pickedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/${DateTime.now().millisecondsSinceEpoch}_${pickedImage!.name}');
      await storageRef.putData(await pickedImage!.readAsBytes());
      imageUrl = await storageRef.getDownloadURL();
    }

    final chatId = _getChatId(widget.currentUserEmail, widget.receiverEmail);
    final messageData = {
      'text': text.trim(), // Always include text, even if empty
      if (imageUrl != null) 'imageUrl': imageUrl,
      'sender': widget.currentUserEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'type': imageUrl != null ? 'image' : 'text',
    };
    final docRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    final sentMsg = await docRef.get();
    final sentData = sentMsg.data();

    if (sentData != null) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set({
            'lastMessage': {
              'text': text.trim(),
              'sender': widget.currentUserEmail,
              'timestamp': sentData['timestamp'],
            }
          }, SetOptions(merge: true));
    }
    controller.clear();
    setState(() {
      pickedImage = null;
    });
  }

  Future<void> pickAndPreviewImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        pickedImage = picked;
      });
    }
  }

  void onEmojiSelected(emoji_picker.Emoji emoji) {
    controller.text += emoji.emoji;
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pickedImage != null)
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          pickedImage!.path,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(pickedImage!.path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                right: 10,
                top: 2,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      pickedImage = null;
                    });
                  },
                ),
              ),
            ],
          ),
        if (showEmojiPicker)
          Stack(
            children: [
              // Dismiss area (optional, can keep or remove)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showEmojiPicker = false;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      emoji_picker.EmojiPicker(
                        onEmojiSelected: (category, emoji) => onEmojiSelected(emoji),
                        config: emoji_picker.Config(
                          columns: 9,
                          emojiSizeMax: 22,
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          gridPadding: EdgeInsets.zero,
                          initCategory: emoji_picker.Category.SMILEYS,
                          bgColor: const Color(0xFFF2F2F2),
                          indicatorColor: const Color(0xFF386A53),
                          iconColor: Colors.grey,
                          iconColorSelected: const Color(0xFF386A53),
                          backspaceColor: const Color(0xFF386A53),
                          recentsLimit: 28,
                          noRecents: const Text('No Recents'),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const emoji_picker.CategoryIcons(),
                          buttonMode: emoji_picker.ButtonMode.MATERIAL,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              showEmojiPicker = false;
                            });
                          },
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        Container(
          color: Colors.green[50],
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: Color(0xFF386A53)),
                onPressed: pickAndPreviewImage,
                splashRadius: 22,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  cursorColor: Colors.green[900],
                  style: TextStyle(
                    color: isFocused ? Colors.black : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(
                      color: isFocused ? Colors.grey[700] : Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: isFocused ? Colors.white : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: Colors.green[100]!,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: Colors.green[100]!,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: Colors.green[300]!,
                        width: 2,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      showEmojiPicker = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF386A53)),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    showEmojiPicker = !showEmojiPicker;
                  });
                },
                splashRadius: 22,
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF386A53)),
                onPressed: () => sendMessage(controller.text),
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final QueryDocumentSnapshot message;

  const _MessageBubble({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = AuthService().currentUser?.email;
    final data = message.data() as Map<String, dynamic>;
    final isMe = data['sender'] == currentUserEmail;
    final text = data['text'] ?? '';
    final imageUrl = data['imageUrl'];
    final type = data['type'] ?? 'text';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF386A53) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            if (text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: imageUrl != null ? 8 : 0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper to get a unique chat ID for two users
String _getChatId(String? user1, String user2) {
  final users = [user1, user2]..sort();
  return users.join('_');
}
