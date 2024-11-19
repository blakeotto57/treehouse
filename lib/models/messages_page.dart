import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/models/chat_page.dart'; // Your ChatPage widget

class MessagesList extends StatelessWidget {
  final String currentUserId;

  const MessagesList({required this.currentUserId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet.',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[300],
              indent: 70,
            ),
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              final chatRoomId = chatRooms[index].id;

              // Get other participant's details
              final otherParticipant = chatRoom['participants']
                  .firstWhere((id) => id != currentUserId, orElse: () => 'Unknown');
              final participantNames = chatRoom['participantNames'] as Map<String, dynamic>?;
              final otherParticipantName = participantNames?[otherParticipant] ?? 'Unknown User';

              final lastMessage = chatRoom['lastMessage'] ?? 'No messages yet';
              final lastUpdated = chatRoom['lastUpdated'] != null
                  ? (chatRoom['lastUpdated'] as Timestamp).toDate()
                  : null;

              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Replace with actual profile URL
                  backgroundColor: Colors.grey[300],
                ),
                title: Text(
                  otherParticipantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: lastUpdated != null
                    ? Text(
                        _formatTime(lastUpdated),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        currentUserId: currentUserId,
                        chatRoomId: chatRoomId,
                        recipientId: otherParticipant,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Format time for the trailing timestamp
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (now.difference(dateTime).inDays == 0) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (now.difference(dateTime).inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
