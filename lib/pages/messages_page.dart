import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/pages/chat_page.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/pages/explore_page.dart';

class MessagesPage extends StatefulWidget {
  final List<CategoryModel> categories = CategoryModel.getCategories();
  MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkCard = const Color(0xFF232323);
    final darkBackground = const Color(0xFF181818);

    return Scaffold(
      backgroundColor: isDark ? darkBackground : pastelGreen,
      body: Column(
        children: [
          // Upper nav bar (matches ExplorePage)
          Container(
            color: const Color(0xFF386A53),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Treehouse Connect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExplorePage()),
                        );
                      },
                      icon: const Icon(Icons.explore, color: Colors.white),
                      label: const Text("Explore", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 28,
                      width: 1.2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MessagesPage()),
                        );
                      },
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text("Messages", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 28,
                      width: 1.2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserProfilePage()),
                        );
                      },
                      icon: const Icon(Icons.person, color: Colors.white),
                      label: const Text("Profile", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 28,
                      width: 1.2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserSettingsPage()),
                        );
                      },
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: const Text("Settings", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.message, color: isDark ? Colors.orange[200] : const Color(0xFF386A53)),
                const SizedBox(width: 10),
                Text(
                  "Your Conversations",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.orange[200] : const Color(0xFF386A53),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: (isDark ? Colors.orange[200] : const Color(0xFF386A53))?.withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          // Message list
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: _buildUserList(isDark, darkCard),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF386A53),
        onPressed: () {
          // Optionally, open a new message dialog or requests
        },
        icon: const Icon(Icons.add_comment),
        label: const Text("New Message"),
      ),
    );
  }

  // Build a list of users except currently logged-in user
  Widget _buildUserList(bool isDark, Color darkCard) {
    return StreamBuilder(
      stream: _chatService.getAcceptedChatsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data as List<Map<String, dynamic>>;

        if (users.isEmpty) {
          return const Center(
              child: Text('No conversations yet',
                  style: TextStyle(color: Colors.grey, fontSize: 18)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index];
            return _buildUserListItem(userData, context, isDark, darkCard);
          },
        );
      },
    );
  }

  // Build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context, bool isDark, Color darkCard) {
    final email = userData["email"];
    final profileImageUrl = userData["profileImageUrl"];

    if (email == null || email == _authService.currentUser?.email) {
      return Container(); // Skip current user or invalid data
    }

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          color: isDark ? darkCard : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            leading: CircleAvatar(
              radius: 18,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl)
                  : null,
              backgroundColor: Colors.green[800],
              child: profileImageUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              email,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.orange[200] : const Color(0xFF386A53),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.person_remove, color: Colors.red),
              onPressed: () => _showRemoveDialog(email),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverEmail: email,
                    receiverID: email,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(String userEmail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: const Text('Remove this user and delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeUserChat(userEmail);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeUserChat(String userEmail) async {
    try {
      final currentUserEmail = _authService.currentUser!.email!;

      // Create batch write
      final batch = FirebaseFirestore.instance.batch();

      // Delete chat room and messages
      final List<String> ids = [currentUserEmail, userEmail];
      ids.sort();
      final String chatRoomId = ids.join('_');

      // Get chat room reference
      final chatRoomRef =
          FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);

      // Delete all messages
      final messages = await chatRoomRef.collection('messages').get();
      for (var message in messages.docs) {
        batch.delete(message.reference);
      }

      // Delete chat room
      batch.delete(chatRoomRef);

      // Remove from accepted_chats collection
      batch.delete(FirebaseFirestore.instance
          .collection('accepted_chats')
          .doc(currentUserEmail)
          .collection('users')
          .doc(userEmail));

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User removed successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing user: $e')),
      );
    }
  }
}
