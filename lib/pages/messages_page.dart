import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    await FirebaseFirestore.instance.collection('chat_rooms').doc(chatId).delete();

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
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
    await storageRef.putData(await pickedFile.readAsBytes());
    final imageUrl = await storageRef.getDownloadURL();

    // Send message with image URL (and optional text)
    await _sendMessage(imageUrl: imageUrl);
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    // Your existing sendMessage logic, but add imageUrl
    await _chatService.sendMessage(
      selectedUserEmail!,
      text,
      imageUrl: imageUrl,
    );
    _messageController.clear();
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
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_horiz, color: isSelected ? Colors.black : Colors.grey[500]),
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          await _deleteChat(email);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete Chat'),
                                        ),
                                      ],
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
                                color: Colors.grey[300],
                                thickness: 1,
                                height: 1,
                              ),
                              // Message input
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
    if (messageDay == today.subtract(const Duration(days: 1))) return "Yesterday";

    return "${date.month}/${date.day}/${date.year}"; // Simple fallback
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
          _formatDate(date),
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
        return Expanded(
          child: ListView.builder(
            controller: scrollController,
            reverse: true, // This makes the list start from the bottom
            itemCount: messages.length,
            itemBuilder: (context, index) {
              // If your messages are oldest-to-newest, reverse the index:
              final message = messages[messages.length - 1 - index];
              return _MessageBubble(message: message);
            },
          ),
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

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    widget.sendMessage(imageUrl: null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[50],
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: widget.pickAndSendImage,
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
                fillColor: isFocused ? Colors.white : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: Colors.green[100]!, // Slightly darker green border
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: Colors.green[100]!, // Slightly darker green border
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: Colors.green[300]!, // Even darker green when focused
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: (text) => widget.sendMessage(imageUrl: null),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
            onPressed: () {},
            splashRadius: 22,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF386A53)),
            onPressed: _sendMessage,
            splashRadius: 22,
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

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = AuthService().currentUser?.email;
    final data = message.data() as Map<String, dynamic>;
    final isMe = data['sender'] == currentUserEmail;
    final text = data['text'] ?? '';
    final timestamp = data['timestamp'] is Timestamp
        ? (data['timestamp'] as Timestamp).toDate()
        : null;
    final imageUrl = data['imageUrl'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Image.network(imageUrl, width: 200),
            ),
          if (text.isNotEmpty)
            Container(
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
    );
  }
}

// Helper to get a unique chat ID for two users
String _getChatId(String? user1, String user2) {
  final users = [user1, user2]..sort();
  return users.join('_');
}
