//screen where you see individual messages between 2 people, message list
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/text_field.dart';
import 'package:treehouse/models/chat_service.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,

  });

  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat and auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();


  //send message
  void sendMessage() async {
    // if something inside the textbox
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(
        receiverID, 
        _messageController.text,
      );
      //after message sent clear controller
      _messageController.clear();
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
      ),
      body: Column(
        children: [
         //display all messages
         Expanded(
          child: _buildMessageList(),
          ),

         // user input box 
         _buildUserInput(),
        ],
      )
    );
  }
  //build list of users except the current logged in user
  Widget _buildMessageList() {
  String senderID = _authService.currentUser?.uid ?? '';
    return StreamBuilder(
      stream: _chatService.getMessages(receiverID, senderID), 
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //loading icon
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading...");
        }

        //return list view
        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      }
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Text(data["message"]);
  }

  // build message input
  Widget _buildUserInput() {
    return Row(
      children: [
        // textfield will take up most of the space
        Expanded(
          child: MyTextField(
            controller: _messageController, 
            hintText: "Type a message", 
            obscureText: false,
          ),
        ),

        // send button
        IconButton(
          onPressed: sendMessage,
          icon: Icon(Icons.send),
        ),
      ],
    );
  }
}
