import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/chat_bubble.dart';
import 'package:treehouse/components/text_field.dart';
import 'package:treehouse/auth/chat_service.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat and Auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? Colors.grey[900] ?? Colors.black : Colors.white;
    final boxShadowColor = isDarkMode
        ? Colors.black54 ?? Colors.black
        : Colors.grey.shade300 ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: receiverEmail)
                  .limit(1)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    backgroundColor: Colors.green[800],
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return CircleAvatar(
                    backgroundColor: Colors.green[800],
                    child: Icon(Icons.error, color: Colors.white),
                  );
                }
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.docs.isNotEmpty) {
                  final userData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    final profileImageUrl = userData['profileImageUrl'];
                    if (profileImageUrl != null) {
                      return CircleAvatar(
                        backgroundColor: Colors.green[800],
                        backgroundImage: NetworkImage(profileImageUrl),
                      );
                    } else {
                      return CircleAvatar(
                        backgroundColor: Colors.green[800],
                        child: Text(
                          receiverEmail[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  }
                }
                return CircleAvatar(
                  backgroundColor: Colors.green[800],
                  child: Text(
                    receiverEmail[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              receiverEmail,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input box
          _buildUserInput(backgroundColor, boxShadowColor, isDarkMode),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          receiverID, _authService.currentUser!.email!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // Build user input area
  Widget _buildUserInput(
      Color backgroundColor, Color boxShadowColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: boxShadowColor,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Text field for typing message
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  hintText: "Type a message...",
                  hintStyle: TextStyle(
                    color: Colors.grey
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                controller: _messageController,
                obscureText: false,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Send button
            IconButton(
              icon: Icon(Icons.send,
                  color: isDarkMode ? Colors.white : Colors.black),
              onPressed: sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Check if the message is sent by the current user
    bool isCurrentUser = data["senderID"] == _authService.currentUser!.email!;

    // Align the message to the right if sender, to the left otherwise
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }
}
