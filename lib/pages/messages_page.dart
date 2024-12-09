import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/components/user_tile.dart';
import 'package:treehouse/models/chat_page.dart';
import 'package:treehouse/auth/chat_service.dart';

class MessagesPage extends StatelessWidget {
  MessagesPage({super.key});

  // Chat and Auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Chat with Friends",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),

          // List of users
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  // Build a list of users except currently logged-in user
  Widget _buildUserList() {
    return FutureBuilder(
      future: _chatService.getUsersInChatRooms(),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 10),
                Text(
                  "Error loading messages",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
          );
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if data exists and build the list
        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Text(
              "No users found to chat with!",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          );
        }

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
      return Container(); // Skip current user or invalid data
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.green[300],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Center(
            child: Text(
              email,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          onTap: () {
            // Navigate to the chat page with the user's email and UID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverEmail: email,
                  receiverID: email, // Use email for the receiver ID
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
