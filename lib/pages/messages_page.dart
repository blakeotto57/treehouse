import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/pages/chat_page.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:treehouse/pages/appointment_booking.dart'; // Import the new booking page
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,

        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
         
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
    final email = userData["email"];
    final profileImageUrl = userData["profileImageUrl"];

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
            radius: 25,
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl) // Display the user's profile picture
                : null, // If no image URL, show a default icon
            backgroundColor: Colors.green[300],
            child: profileImageUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null, // Show placeholder icon if no image
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

class SoloSellerProfilePage extends StatelessWidget {
  final String userId;

  const SoloSellerProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Profile',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[300],
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[300],
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[300],
                    child: Icon(Icons.error, color: Colors.white),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final profileImageUrl = userData['profileImageUrl'];
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[300],
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                        : null,
                  );
                }
                return CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green[300],
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Seller Email
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('Error loading email');
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final email = userData['email'] ?? 'Unknown Email';
                  return Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  );
                }
                return const Text('Unknown Email');
              },
            ),
            const SizedBox(height: 20),

            // View Reviews Button
            ElevatedButton(
              onPressed: () {
                // Navigate to reviews page
              },
              child: const Text('View Reviews'),
            ),
            const SizedBox(height: 10),

            // Appointment Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentBookingPage(sellerId: userId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
              ),
              child: const Text('Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}