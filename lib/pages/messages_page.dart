import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                                color: Colors.grey[300],
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });
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
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final chatId = _getChatId(widget.currentUserEmail, widget.receiverEmail);
    final messageData = {
      'text': text.trim(),
      'sender': widget.currentUserEmail,
      'timestamp': FieldValue.serverTimestamp(),
    };
    // Add to messages subcollection and get the reference
    final docRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Fetch the message with the actual timestamp
    final sentMsg = await docRef.get();
    final sentData = sentMsg.data();

    if (sentData != null) {
      // Set lastMessage to the text just sent
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[50],
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
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
              onSubmitted: (text) => sendMessage(text),
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
            onPressed: () => sendMessage(controller.text),
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
