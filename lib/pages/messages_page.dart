import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb

import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class MessagesPage extends StatefulWidget {
  final String? initialSelectedUserEmail; // Add this

  MessagesPage({Key? key, this.initialSelectedUserEmail}) : super(key: key);

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
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedUserEmail != null) {
      selectedUserEmail = widget.initialSelectedUserEmail;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
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

  Future<void> _deleteChat(String otherUserEmail) async {
    final currentUserEmail = await _authService.getCurrentUserEmail();
    List<String> ids = [currentUserEmail, otherUserEmail]..sort();
    String chatId = ids.join('_');

    // Delete chat document
    await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();

    // Optionally delete chat_room and messages
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatId)
        .delete();

    // Remove from accepted_chats for both users
    await FirebaseFirestore.instance
        .collection('accepted_chats')
        .doc(currentUserEmail)
        .collection('users')
        .doc(otherUserEmail)
        .delete();

    await FirebaseFirestore.instance
        .collection('accepted_chats')
        .doc(otherUserEmail)
        .collection('users')
        .doc(currentUserEmail)
        .delete();

    // Deselect if this chat was selected
    if (selectedUserEmail == otherUserEmail) {
      setState(() {
        selectedUserEmail = null;
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child(
        'chat_images/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
    await storageRef.putData(await pickedFile.readAsBytes());
    final imageUrl = await storageRef.getDownloadURL();

    // Send message with image URL (and optional text)
    await _sendMessage(imageUrl: imageUrl);
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    final currentUserEmail = await _authService.getCurrentUserEmail();
    final chatId = _getChatId(currentUserEmail, selectedUserEmail!);

    final messageData = {
      'text': text,
      'imageUrl': imageUrl,
      'sender': currentUserEmail,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Save the message to Firestore
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF181818) : Colors.green[50];
    final cardColor = isDarkMode ? const Color(0xFF232323) : Colors.white;
    final dividerColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDarkMode ? Colors.white : const Color(0xFF222222);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: customDrawer(context),
      appBar: const Navbar(),
      body: screenWidth < 600 // Adjust layout for phone screens
          ? selectedUserEmail == null
              ? Column(
                  children: [
                    // Messages Stream
                    Expanded(
                      child: Container(
                        color: cardColor,
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
                              color: dividerColor,
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
                                    return Center(
                                      child: Text(
                                        'Error: ${snapshot.error}',
                                        style: TextStyle(color: textColor),
                                      ),
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final users = snapshot.data!;
                                  if (users.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No conversations yet',
                                        style: TextStyle(color: textColor),
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    itemCount: users.length,
                                    separatorBuilder: (context, index) => Divider(
                                      color: dividerColor,
                                      height: 1,
                                      thickness: 1,
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                    itemBuilder: (context, index) {
                                      final user = users[index];
                                      final email = user["email"];
                                      final username =
                                          user["username"] ?? user["name"] ?? email;
                                      final profileUrl = user["profileImageUrl"];
                                      final isSelected = selectedUserEmail == email;

                                      final lastMessage = user['lastMessage'] ?? {};
                                      final lastSender =
                                          lastMessage['sender'] ?? username;
                                      final lastMessageText =
                                          lastMessage['text'] ?? '';

                                      return Material(
                                        color: isSelected
                                            ? (isDarkMode
                                                ? Colors.grey[800]
                                                : Colors.grey[200])
                                            : cardColor,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage:
                                                      profileUrl != null
                                                          ? NetworkImage(profileUrl)
                                                          : null,
                                                  backgroundColor: Colors.grey[300],
                                                  child: profileUrl == null
                                                      ? const Icon(Icons.person,
                                                          color: Colors.white)
                                                      : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        username,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: textColor,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        "$lastSender: $lastMessageText",
                                                        style: TextStyle(
                                                          color: isDarkMode
                                                              ? Colors.grey[400]
                                                              : Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
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
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Chat Page
                    Expanded(
                      child: Container(
                        color: backgroundColor,
                        child: Column(
                          children: [
                            // Back Button
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: Color(0xFF386A53)),
                                    onPressed: () {
                                      setState(() {
                                        selectedUserEmail = null;
                                      });
                                    },
                                  ),
                                  Text(
                                    selectedUserName ?? "Chat",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF386A53),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                  const SizedBox(height: 8),
                                  Divider(
                                    color: Color(0xFF386A53),
                                    thickness: 1,
                                    height: 1,
                                  ),
                                  _ChatInputWidget(
                                    onSend: (text) {},
                                    receiverEmail: selectedUserEmail!,
                                    currentUserEmail:
                                        _authService.currentUser?.email ?? '',
                                    messageController: _messageController,
                                    pickAndSendImage: _pickAndSendImage,
                                    sendMessage: _sendMessage,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
          : Row(
              children: [
                // Left: Conversations List
                Container(
                  width: 320,
                  color: cardColor,
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
                        color: dividerColor,
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
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final users = snapshot.data!;
                            if (users.isEmpty) {
                              return Center(
                                child: Text(
                                  'No conversations yet',
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: users.length,
                              separatorBuilder: (context, index) => Divider(
                                color: dividerColor,
                                height: 1,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final email = user["email"];
                                final username =
                                    user["username"] ?? user["name"] ?? email;
                                final profileUrl = user["profileImageUrl"];
                                final isSelected = selectedUserEmail == email;

                                final lastMessage = user['lastMessage'] ?? {};
                                final lastSender =
                                    lastMessage['sender'] ?? username;
                                final lastMessageText =
                                    lastMessage['text'] ?? '';

                                return Material(
                                  color: isSelected
                                      ? (isDarkMode ? Colors.grey[800] : Colors.grey[200])
                                      : cardColor,
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
                                            backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                                            backgroundColor: Colors.grey[300],
                                            child: profileUrl == null
                                                ? const Icon(Icons.person, color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  username,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: textColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "$lastSender: $lastMessageText",
                                                  style: TextStyle(
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
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
                            style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 18),
                          ),
                        )
                      : Container(
                          color: backgroundColor,
                          child: Column(
                            children: [
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
                                    const SizedBox(height: 8),
                                    Divider(
                                      color: Color(0xFF386A53),
                                      thickness: 1,
                                      height: 1,
                                    ),
                                    _ChatInputWidget(
                                      onSend: (text) {},
                                      receiverEmail: selectedUserEmail!,
                                      currentUserEmail: _authService.currentUser?.email ?? '',
                                      messageController: _messageController,
                                      pickAndSendImage: _pickAndSendImage,
                                      sendMessage: _sendMessage,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay == today) return "Today";
    if (messageDay == today.subtract(const Duration(days: 1)))
      return "Yesterday";

    return "${date.month}/${date.day}/${date.year}"; // Simple fallback
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(date),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(date),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
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

        if (messages.isEmpty) {
          return Center(
            child: Text(
              "Let's have a chat",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          reverse: true, // Start from the bottom
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            final previousMessage = index < messages.length - 1
                ? messages[messages.length - 2 - index]
                : null;

            final currentTimestamp =
                (message['timestamp'] as Timestamp?)?.toDate();
            final previousTimestamp = previousMessage != null
                ? (previousMessage['timestamp'] as Timestamp?)?.toDate()
                : null;

            final showDateSeparator = previousTimestamp == null ||
                currentTimestamp == null ||
                currentTimestamp.difference(previousTimestamp).inMinutes > 5;

            return Column(
              children: [
                if (showDateSeparator && currentTimestamp != null)
                  _DateSeparator(date: currentTimestamp), // Centered timestamp
                _MessageBubble(message: message),
              ],
            );
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
  final TextEditingController messageController;
  final Future<void> Function() pickAndSendImage;
  final Future<void> Function({String? imageUrl}) sendMessage;

  const _ChatInputWidget({
    required this.onSend,
    required this.receiverEmail,
    required this.currentUserEmail,
    required this.messageController,
    required this.pickAndSendImage,
    required this.sendMessage,
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<_ChatInputWidget> {
  final FocusNode focusNode = FocusNode();
  bool isFocused = false;
  bool isEmojiPickerVisible = false; // Track emoji picker visibility
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
        if (isFocused) {
          isEmojiPickerVisible =
              false; // Hide emoji picker when input is focused
        }
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    setState(() {
      isEmojiPickerVisible = !isEmojiPickerVisible;
      if (isEmojiPickerVisible) {
        focusNode
            .unfocus(); // Unfocus the text field when emoji picker is shown
      }
    });
  }

  void _onEmojiSelected(Emoji emoji) {
    widget.messageController.text += emoji.emoji; // Add emoji to the text field
    widget.messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.messageController.text.length),
    );
  }

  void _dismissEmojiPicker() {
    setState(() {
      isEmojiPickerVisible = false;
    });
  }

  void _sendMessage() async {
    await widget.sendMessage();
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
      // Optionally, send the image immediately:
      await widget.sendMessage(
          imageUrl: null); // You may want to upload and send the image here
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEmojiPickerVisible) {
          _dismissEmojiPicker(); // Dismiss emoji picker when tapping outside
        }
      },
      child: Column(
        children: [
          if (selectedImage !=
              null) // Show image preview if an image is selected
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  kIsWeb
                      ? FutureBuilder<Uint8List>(
                          future: selectedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 80,
                                width: 80,
                                color: Colors.grey[200],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Container(
                                height: 80,
                                width: 80,
                                color: Colors.grey[200],
                                child: const Center(
                                    child: Icon(Icons.broken_image)),
                              );
                            }
                            return Image.memory(
                              snapshot.data!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.file(
                          File(selectedImage!.path),
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          selectedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: const Color(0xFF386A53)),
                  onPressed: _pickImage, // Use the new _pickImage method
                ),
                Expanded(
                  child: TextField(
                    controller: widget.messageController,
                    focusNode: focusNode,
                    cursorColor: Colors.green[900],
                    style: TextStyle(
                      color: isFocused ? Colors.black : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(
                        color: isFocused ? Colors.grey[700] : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : (isFocused ? Colors.white : Colors.grey[100]),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20), // Added vertical padding
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (text) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined,
                      color: const Color(0xFF386A53)),
                  onPressed: _toggleEmojiPicker, // Toggle emoji picker
                  splashRadius: 22,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF386A53)),
                  onPressed: _sendMessage,
                  splashRadius: 22,
                ),
              ],
            ),
          ),
          if (isEmojiPickerVisible)
            GestureDetector(
              onTap: () {}, // Prevent dismissing when tapping inside the picker
              child: SizedBox(
                height: 250, // Adjust height as needed
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) => _onEmojiSelected(emoji),
                  config: const Config(
                    columns: 7,
                    emojiSizeMax: 32,
                    verticalSpacing: 8,
                    horizontalSpacing: 8,
                    gridPadding: EdgeInsets.all(8),
                    bgColor: Color(0xFFF2F2F2),
                    indicatorColor: Color(0xFF386A53),
                    iconColor: Colors.grey,
                    iconColorSelected: Color(0xFF386A53),
                    backspaceColor: Color(0xFF386A53),
                    skinToneDialogBgColor: Colors.white,
                    enableSkinTones: true,
                    recentsLimit: 28,
                    noRecents: Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final QueryDocumentSnapshot message;

  const _MessageBubble({required this.message, Key? key}) : super(key: key);

  void showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Close the dialog on tap
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = AuthService().currentUser?.email;
    final data = message.data() as Map<String, dynamic>;
    final isMe = data['sender'] == currentUserEmail;
    final text = data['text'] ?? '';
    final imageUrl = data['imageUrl'] ?? null; // Get the image URL if it exists

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
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (imageUrl != null) // Display the image if it exists
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => showEnlargedImage(
                      context, imageUrl), // Enlarge image on tap
                  child: Image.network(
                    imageUrl,
                    height: 150, // Adjust the height as needed
                    width: 150, // Adjust the width as needed
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50);
                    },
                  ),
                ),
              ),
            if (text.isNotEmpty) // Display the text if it exists
              Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
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
