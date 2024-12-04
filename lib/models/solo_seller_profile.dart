import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/components/text_box.dart';

class SoloSellerProfilePage extends StatefulWidget {
  final String userId;

  const SoloSellerProfilePage({super.key, required this.userId});

  @override
  State<SoloSellerProfilePage> createState() => _SoloSellerProfilePageState();
}

class _SoloSellerProfilePageState extends State<SoloSellerProfilePage> {
  final usersCollection = FirebaseFirestore.instance.collection("sellers");

  // Edit field for user data
  Future<void> editField(String field, String userId) async {
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
                usersCollection.doc(userId).update({field: newValue});
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading user data"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

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
                    userData['email'] ?? 'Unknown Email',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Seller Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                MyTextBox(
                  text: userData['username'] ?? '',
                  sectionName: "Username",
                  onPressed: () => editField("username", widget.userId),
                ),
                MyTextBox(
                  text: userData['bio'] ?? '',
                  sectionName: "Bio",
                  onPressed: () => editField("bio", widget.userId),
                ),
                const SizedBox(height: 25),
              ],
            );
          }

          return const Center(
            child: Text("User data not available"),
          );
        },
      ),
    );
  }
}
