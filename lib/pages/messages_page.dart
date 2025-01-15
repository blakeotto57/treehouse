import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/pages/chat_page.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:treehouse/widgets/custom_drawer.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  // Add counter for new message requests
  Stream<int> get _newRequestsCount {
    return FirebaseFirestore.instance
        .collection('message_requests')
        .doc(_authService.currentUser?.email)
        .collection('requests')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Add function to handle user acceptance
  Future<void> _acceptUser(String userEmail) async {
    final currentUserEmail = _authService.currentUser?.email;
    if (currentUserEmail == null) return;

    // Add to accepted users collection
    await FirebaseFirestore.instance
        .collection('accepted_chats')
        .doc(currentUserEmail)
        .collection('users')
        .doc(userEmail)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
      'email': userEmail,
    });

    // Remove from requests
    await FirebaseFirestore.instance
        .collection('message_requests')
        .doc(currentUserEmail)
        .collection('requests')
        .doc(userEmail)
        .delete();
  }

  // Add function to handle user rejection
  Future<void> _rejectUser(String userEmail) async {
    final currentUserEmail = _authService.currentUser?.email;
    if (currentUserEmail == null) return;

    // Remove from requests
    await FirebaseFirestore.instance
        .collection('message_requests')
        .doc(currentUserEmail)
        .collection('requests')
        .doc(userEmail)
        .delete();
  }

  // Add function to show requests dialog
  void _showRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Requests'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('message_requests')
                .doc(_authService.currentUser?.email)
                .collection('requests')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = snapshot.data!.docs;
              
              if (requests.isEmpty) {
                return const Text('No pending requests');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index].data() as Map<String, dynamic>;
                  final userEmail = request['senderEmail'] as String;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(userEmail[0].toUpperCase()),
                    ),
                    title: Text(userEmail),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _acceptUser(userEmail);
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _rejectUser(userEmail);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        automaticallyImplyLeading: false,
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
        actions: [
          // Add request counter badge
          StreamBuilder<int>(
            stream: _newRequestsCount,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.white),
                    onPressed: _showRequestsDialog,
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc('user_id').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text('Error loading email');
              }
              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                final email = userData?['email'] ?? "";
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
          // Add more widgets here
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  // Build a list of users except currently logged-in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: Stream.fromFuture(_chatService.getUsersInChatRooms()),
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
        color: Theme.of(context).colorScheme.primary,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: Text(
          'Seller Profile',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: textColor,
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
      
          ],
        ),
      ),
    );
  }
}