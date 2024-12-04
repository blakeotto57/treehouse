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

  // Check if the current user's ID matches a document ID in the sellers collection
  Future<bool> isCurrentUserASeller() async {
    try {
      final sellerDoc = await sellersCollection.doc(currentUser.email).get();
      return sellerDoc.exists;
    } catch (e) {
      print('Error checking seller status: $e');
      return false;
    }
  }

  // Edit field for user data
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
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
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (newValue.trim().isNotEmpty) {
                usersCollection.doc(currentUser.uid).update({field: newValue});
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Seller Profile"),
        backgroundColor: Colors.white,
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

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.person, size: 72),
                    ),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        currentUser.email!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "My Details",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MyTextBox(
                      text: userData['username'] ?? '',
                      sectionName: "Username",
                      onPressed: () => editField("username"),
                    ),
                    MyTextBox(
                      text: userData['bio'] ?? '',
                      sectionName: "Bio",
                      onPressed: () => editField("bio"),
                    ),
                    const SizedBox(height: 25),

                    // Conditionally render the ElevatedButton based on seller status
                    if (!sellerSnapshot.data!)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Navigate to the SellerSetupPage
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerSetupPage(onTap: () {  },),
                            ),
                          );
                        },
                        child: const Text(
                          "Become a Seller",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          "You are already a seller!",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                  ],
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