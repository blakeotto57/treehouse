import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:treehouse/components/like_button.dart';
import 'package:treehouse/components/user_post.dart';
import 'package:treehouse/models/solo_seller_profile.dart';
import 'package:intl/intl.dart';
import 'package:treehouse/pages/user_profile.dart';

class PhotographySellersPage extends StatefulWidget {
  const PhotographySellersPage({Key? key}) : super(key: key);

  @override
  State<PhotographySellersPage> createState() => _PhotographySellersPageState();
}

class _PhotographySellersPageState extends State<PhotographySellersPage> {
  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
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
        title: const Text("Photography Services"),
        backgroundColor: Color.fromRGBO(57, 210, 192, 1),
      ),
      body: Center(
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
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index].data() as Map<String, dynamic>;

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
                      return Center(
                        child: Text("Error:${snapshot.error}"),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: "What photography services do you need?",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
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
    );
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
              builder: (context) => SoloSellerProfilePage(userId: userId),
            ),
          );
        },
      ),
    );
  }
}
