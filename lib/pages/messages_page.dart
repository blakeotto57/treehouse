import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth_service.dart';
import 'package:treehouse/pages/chat_page.dart';
import 'package:treehouse/auth/chat_service.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/models/category_model.dart';  // Add this import

class MessagesPage extends StatefulWidget {
  final List<CategoryModel> categories = CategoryModel.getCategories();
  MessagesPage({super.key});

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
              ...widget.categories.map((category) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Icon(
                      category.icon,
                      size: 30,
                      color: category.boxColor, // Match icon color to category color
                    ),
                    title: Text(
                      (category.name as Text).data ?? '', // Extract string from Text widget
                      style: TextStyle(
                        fontSize: 14,
                        color: category.boxColor, // Use category's boxColor for text
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
              )).toList(),
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
                    MaterialPageRoute(builder: (context) => const UserSettingsPage()),
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
            backgroundColor: Colors.green[800],
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
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
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