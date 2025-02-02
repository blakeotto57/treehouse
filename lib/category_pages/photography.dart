import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:treehouse/components/like_button.dart';
import 'package:treehouse/components/user_post.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/pages/user_profile.dart';

class PhotographySellersPage extends StatefulWidget {
  const PhotographySellersPage({Key? key}) : super(key: key);

  @override
  State<PhotographySellersPage> createState() => _PhotographySellersPageState();
}

class _PhotographySellersPageState extends State<PhotographySellersPage> {
  final textController = TextEditingController();
  final searchController = TextEditingController(); // Add search controller
  final currentUser = FirebaseAuth.instance.currentUser!;
  String searchQuery = ''; // Add search query state
  late Stream<QuerySnapshot> _sellersStream;

  @override
  void initState() {
    super.initState();
    _sellersStream = FirebaseFirestore.instance
        .collection('sellers')
        .where('category', isEqualTo: 'Photography')
        .snapshots();
  }

  Future<void> postMessage() async {
    if (textController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection("photography_posts").doc(textController.text).set({
        "email": FirebaseAuth.instance.currentUser?.email,
        "message": textController.text,
        "timestamp": Timestamp.now(),
        "likes": [],
      });
      setState(() {
        textController.clear();
      });
      FocusScope.of(context).unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(57, 210, 192, 1),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            // Reduced padding around the back button
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Expanded search bar with reduced horizontal content padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: TextField(
                    controller: searchController,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("photography_posts")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var filteredPosts = snapshot.data!.docs.where((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        return searchQuery.isEmpty || 
                               data["message"].toString().toLowerCase().contains(searchQuery);
                      }).toList();
                      
                      return ListView.builder(
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index].data() as Map<String, dynamic>;
                          return UserPost(
                            message: post["message"],
                            user: post["email"],
                            postId: post["message"],
                            likes: List<String>.from(post["likes"] ?? []),
                            timestamp: post["timestamp"],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error:${snapshot.error}"));
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "What do you need?",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: postMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    textController.dispose();
    super.dispose();
  }
}

class SellerCard extends StatelessWidget {
  final String userId;
  final String username;
  final String description;
  final String? profilePicture;

  const SellerCard({
    Key? key,
    required this.userId,
    required this.username, 
    required this.description,
    this.profilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.primary,
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.pink[300],
          backgroundImage: profilePicture != null && profilePicture!.isNotEmpty
              ? NetworkImage(profilePicture!)
              : null,
          child: profilePicture == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Text(
          username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.pink),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUsersProfilePage(userId: userId),
            ),
          );
        },
      ),
    );
  }
}
