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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "Messages",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF222222),
                    ),
                  ),
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
                                setState(() {
                                  selectedUserEmail = email;
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
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "$lastSender: $lastMessage",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 15,
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
                        // User info header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: selectedUserProfileUrl != null
                                    ? NetworkImage(selectedUserProfileUrl!)
                                    : null,
                                backgroundColor: Colors.green[200],
                                child: selectedUserProfileUrl == null
                                    ? const Icon(Icons.person, size: 32, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedUserName ?? selectedUserEmail!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF386A53),
                                    ),
                                  ),
                                  Text(
                                    "@${selectedUserEmail!.split('@').first}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Chat messages
                        Expanded(
                          child: _ChatMessagesWidget(
                            receiverEmail: selectedUserEmail!,
                            themeColor: const Color(0xFF386A53),
                          ),
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
          ),
        ],
      ),
    );
  }
}

// Chat messages widget (moved from ChatPage)
class _ChatMessagesWidget extends StatelessWidget {
  final String receiverEmail;
  final Color themeColor;

  const _ChatMessagesWidget({
    required this.receiverEmail,
    required this.themeColor,
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
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index].data() as Map<String, dynamic>;
            final isMe = msg['sender'] == currentUserEmail;
            final timestamp = (msg['timestamp'] as Timestamp?)?.toDate();
            String? dateLabel;

            // Show date/time if it's the first message or the date is different from the previous message
            if (timestamp != null) {
              final prevTimestamp = index > 0
                  ? (messages[index - 1].data() as Map<String, dynamic>)['timestamp'] as Timestamp?
                  : null;
              final prevDate = prevTimestamp?.toDate();
              if (index == 0 ||
                  prevDate == null ||
                  prevDate.day != timestamp.day ||
                  prevDate.month != timestamp.month ||
                  prevDate.year != timestamp.year) {
                dateLabel = "${timestamp.month}/${timestamp.day}/${timestamp.year}  "
                    "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
              }
            }

            return Column(
              children: [
                if (dateLabel != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          dateLabel,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                    ),
                    margin: EdgeInsets.only(
                      top: 6,
                      bottom: 6,
                      left: isMe ? 60 : 0,
                      right: isMe ? 0 : 60,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? themeColor : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white : themeColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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

// Helper to get a unique chat ID for two users
String _getChatId(String? user1, String user2) {
  final users = [user1, user2]..sort();
  return users.join('_');
}
