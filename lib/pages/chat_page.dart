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
                    backgroundColor: Colors.green[300],
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return CircleAvatar(
                    backgroundColor: Colors.green[300],
                    child: Icon(Icons.error, color: Colors.white),
                  );
                }
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                  final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    final profileImageUrl = userData['profileImageUrl'];
                    if (profileImageUrl != null) {
                      return CircleAvatar(
                        backgroundColor: Colors.green[300],
                        backgroundImage: NetworkImage(profileImageUrl),
                      );
                    } else {
                      return CircleAvatar(
                        backgroundColor: Colors.green[300],
                        child: Text(
                          receiverEmail[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  }
                }
                return CircleAvatar(
                  backgroundColor: Colors.green[300],
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input box
          _buildUserInput(),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(receiverID, _authService.currentUser!.email!),
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
  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text field for typing message
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message...",
              obscureText: false,
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          ElevatedButton(
            onPressed: sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[300],
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(15),
              elevation: 5,
            ),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Check if the message is sent by the current user
    bool isCurrentUser = data["senderID"] == _authService.currentUser!.email!;

    // Align the message to the right if sender, to the left otherwise
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

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
