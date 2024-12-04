import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/user_tile.dart';
import 'package:treehouse/models/chat_page.dart';
import 'package:treehouse/models/chat_service.dart';

class MessagesPage extends StatelessWidget {
  MessagesPage({super.key});

  // chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: _buildUserList(),
    );
  }

  // build a list of users except currently logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // Check if data exists and build the list
        final users = snapshot.data ?? [];

        return ListView(
          children: users.map<Widget>((userData) {
            return _buildUserListItem(userData, context);
          }).toList(),
        );
      },
    );
  }

  // Build individual list tile for user
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    // Check if email exists in userData
    final email = userData["email"];
    
    if (email == null || email == _authService.currentUser?.email) {
      return Container();  // Skip current user or invalid data
    }

    return UserTile(
      text: email, // Use email directly, as it has been checked
      onTap: () {
        // Navigate to the chat page with the user's email and UID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: email,  // Ensure receiver email is valid
              receiverID: userData["uid"] ?? "",  // Use an empty string if "uid" is null
            ),
          ),
        );
      },
    );
  }
}
