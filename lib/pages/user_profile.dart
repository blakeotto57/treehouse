import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/components/text_box.dart';
import 'package:treehouse/pages/seller_setup.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("users");
  final sellersCollection = FirebaseFirestore.instance.collection("sellers");

  Future<bool> isCurrentUserASeller() async {
    try {
      final sellerDoc = await sellersCollection.doc(currentUser.email).get();
      return sellerDoc.exists;
    } catch (e) {
      print('Error checking seller status: $e');
      return false;
    }
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.black),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (newValue.trim().isNotEmpty) {
                usersCollection.doc(currentUser.uid).update({field: newValue});
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      body: FutureBuilder<bool>(
        future: isCurrentUserASeller(),
        builder: (context, sellerSnapshot) {
          if (sellerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sellerSnapshot.hasError) {
            return const Center(child: Text("Error loading seller status"));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: usersCollection.doc(currentUser.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return const Center(child: Text("Error loading user data"));
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.green[300],
                        child: const Icon(Icons.person, size: 80, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentUser.email!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MyTextBox(
                              text: userData['username'] ?? '',
                              sectionName: "Username",
                              onPressed: () => editField("username"),
                            ),
                            const SizedBox(height: 10),
                            MyTextBox(
                              text: userData['bio'] ?? '',
                              sectionName: "Bio",
                              onPressed: () => editField("bio"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (!sellerSnapshot.data!)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[300],
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerSetupPage(onTap: () {}),
                              ),
                            );
                          },
                          child: const Text(
                            "Become a Seller",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return const Center(
                child: Text("User data not available"),
              );
            },
          );
        },
      ),
    );
  }
}
