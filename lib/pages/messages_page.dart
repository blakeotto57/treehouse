import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/pages/chat_page.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/models/category_model.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';

class MessagesPage extends StatefulWidget {
  final List<CategoryModel> categories = CategoryModel.getCategories();
  MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  bool _isDeleting = false;

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
        title: const Center(
          child: Text(
            'Message Requests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
                return Text(
                  'No message requests',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                );
              }

              final requests = snapshot.data!.docs;

              if (requests.isEmpty) {
                return const Text('No pending requests');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request =
                      requests[index].data() as Map<String, dynamic>;
                  final userEmail = request['senderEmail'] as String;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(userEmail[0].toUpperCase()),
                    ),
                    title: Text(
                      userEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green[800]),
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
      final chatRoomRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId);
  
      // Delete all messages
      final messages = await chatRoomRef.collection('messages').get();
      for (var message in messages.docs) {
        batch.delete(message.reference);
      }
  
      // Delete chat room
      batch.delete(chatRoomRef);
  
      // Remove from accepted_chats collection
      batch.delete(
        FirebaseFirestore.instance
            .collection('accepted_chats')
            .doc(currentUserEmail)
            .collection('users')
            .doc(userEmail)
      );
  
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.green[800],
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Messages",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pending_messages')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection('requests')
                .snapshots(),
            builder: (context, snapshot) {
              return IconButton(
                icon: Badge(
                  isLabelVisible:
                      snapshot.hasData && snapshot.data!.docs.isNotEmpty,
                  label: Text(
                    snapshot.hasData
                        ? snapshot.data!.docs.length.toString()
                        : '0',
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: Icon(
                    Icons.notification_important,
                    color: Colors.green[800],
                  ),
                ),
                onPressed: () => _showPendingRequests(context),
              );
            },
          ),
        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.green[800],
            height: 1.0,
          ),
        ),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.65, // Reduced width
        child: Drawer(
          backgroundColor: Colors.white,
          elevation: 1,
          child: ListView(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              ...widget.categories
                  .map((category) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            leading: Icon(
                              category.icon,
                              size: 30,
                              color: category
                                  .boxColor, // Match icon color to category color
                            ),
                            title: Text(
                              (category.name as Text).data ??
                                  '', // Extract string from Text widget
                              style: TextStyle(
                                fontSize: 14,
                                color: category
                                    .boxColor, // Use category's boxColor for text
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              category.onTap(context);
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                        ],
                      ))
                  .toList(),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  Icons.settings,
                  size: 20,
                  color: Colors.grey[700],
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserSettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('user_id')
                .snapshots(),
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
          return const Center(child: Text('No conversations yet'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index];
            return _buildUserListItem(userData, context);
          },
        );
      },
    );
  }

  // Build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: CircleAvatar(
            radius: 15,
            backgroundImage: profileImageUrl != null
                ? NetworkImage(
                    profileImageUrl) // Display the user's profile picture
                : null, // If no image URL, show a default icon
            backgroundColor: Colors.green[800],
            child: profileImageUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null, // Show placeholder icon if no image
          ),
          title: Center(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.person_remove),
            onPressed: () => _showRemoveDialog(email),
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

  void _showPendingRequests(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<QuerySnapshot>(
        // Update the collection path to match where requests are being stored
        stream: FirebaseFirestore.instance
            .collection('pending_messages')
            .doc(_authService.currentUser!.email)
            .collection('requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return AlertDialog(
              title: Text(
                'Pending Messages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              content: const Text(
                'No pending messages',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          return AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            title: Text(
              'Pending Messages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final message = snapshot.data!.docs[index];
                  final senderEmail = message['senderEmail'];
                  final messageText = message['message'];
                  final timestamp = message['timestamp'] as Timestamp;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side: User info and message
                            Expanded(
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    backgroundColor: Colors.green[800],
                                    radius: 20,
                                    child: Text(
                                      senderEmail[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Message content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          senderEmail,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          messageText,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right side: Action buttons
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      icon: Icon(Icons.check,
                                          color: Colors.blue[600]),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.blue[50],
                                      ),
                                      onPressed: () async {
                                        try {
                                          // Show loading
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          );

                                          final currentUserEmail = FirebaseAuth
                                              .instance.currentUser!.email!;
                                          final messageData = {
                                            'senderEmail': senderEmail,
                                            'message': message['message'],
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                          };

                                          // Add message to both users' collections and add to accepted chats
                                          await FirebaseFirestore.instance
                                              .batch()
                                            // Set chat for current user
                                            ..set(
                                                FirebaseFirestore.instance
                                                    .collection('messages')
                                                    .doc(currentUserEmail)
                                                    .collection('chats')
                                                    .doc(senderEmail),
                                                {
                                                  'lastMessage':
                                                      message['message'],
                                                  'timestamp': FieldValue
                                                      .serverTimestamp()
                                                })
                                            // Add message to current user's messages
                                            ..set(
                                                FirebaseFirestore.instance
                                                    .collection('messages')
                                                    .doc(currentUserEmail)
                                                    .collection('chats')
                                                    .doc(senderEmail)
                                                    .collection('messages')
                                                    .doc(),
                                                messageData)
                                            // Set chat for sender
                                            ..set(
                                                FirebaseFirestore.instance
                                                    .collection('messages')
                                                    .doc(senderEmail)
                                                    .collection('chats')
                                                    .doc(currentUserEmail),
                                                {
                                                  'lastMessage':
                                                      message['message'],
                                                  'timestamp': FieldValue
                                                      .serverTimestamp()
                                                })
                                            // Add message to sender's messages
                                            ..set(
                                                FirebaseFirestore.instance
                                                    .collection('messages')
                                                    .doc(senderEmail)
                                                    .collection('chats')
                                                    .doc(currentUserEmail)
                                                    .collection('messages')
                                                    .doc(),
                                                messageData)
                                            // Add to current user's accepted chats
                                            ..set(
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'accepted_chats')
                                                    .doc(currentUserEmail)
                                                    .collection('users')
                                                    .doc(senderEmail),
                                                {
                                                  'email': senderEmail,
                                                  'timestamp': FieldValue
                                                      .serverTimestamp()
                                                })
                                            // Add to sender's accepted chats
                                            ..set(
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'accepted_chats')
                                                    .doc(senderEmail)
                                                    .collection('users')
                                                    .doc(currentUserEmail),
                                                {
                                                  'email': currentUserEmail,
                                                  'timestamp': FieldValue
                                                      .serverTimestamp()
                                                })
                                            // Delete the pending message
                                            ..delete(message.reference)
                                            ..commit();

                                          // Close dialogs
                                          if (context.mounted) {
                                            Navigator.pop(
                                                context); // Loading dialog
                                            Navigator.pop(
                                                context); // Pending messages dialog
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error: ${e.toString()}')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      icon: Icon(Icons.close,
                                          color: Colors.red[600]),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red[50],
                                      ),
                                      onPressed: () {
                                        // existing decline logic
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _acceptPendingMessage(DocumentSnapshot message) async {
    final currentUserEmail = _authService.currentUser!.email!;
    final senderEmail = message['senderEmail'];
    final messageData = {
      'message': message['message'],
      'senderEmail': senderEmail,
      'timestamp': message['timestamp'],
    };

    // Add message to both users' chat collections
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(currentUserEmail)
        .collection('chats')
        .doc(senderEmail)
        .collection('messages')
        .add(messageData);

    // Delete pending message
    await message.reference.delete();
  }

  Future<void> _acceptRequest(DocumentSnapshot request) async {
    // Add to messages collection for both users
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('chats')
        .doc(request['senderEmail'])
        .set({'lastMessage': '', 'timestamp': DateTime.now()});

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(request['senderEmail'])
        .collection('chats')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .set({'lastMessage': '', 'timestamp': DateTime.now()});

    // Delete request
    await request.reference.delete();
    Navigator.pop(context);
  }

  Future<void> _denyRequest(DocumentSnapshot request) async {
    await request.reference.delete();
    Navigator.pop(context);
  }
}

class SoloSellerProfilePage extends StatelessWidget {
  final String userId;

  const SoloSellerProfilePage({Key? key, required this.userId})
      : super(key: key);

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
        backgroundColor: Colors.green[800],
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
                    backgroundColor: Colors.green[800],
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[800],
                    child: Icon(Icons.error, color: Colors.white),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final profileImageUrl = userData['profileImageUrl'];
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[800],
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
                  backgroundColor: Colors.green[800],
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
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
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
