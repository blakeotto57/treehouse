import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/text_box.dart';
import 'package:treehouse/models/reviews_page.dart';
import 'package:treehouse/pages/seller_calendar.dart'; // Import the seller calendar page
import 'package:treehouse/pages/seller_setup.dart'; // Import the seller setup page
import 'package:treehouse/pages/set_availibility.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("users");
  final sellersCollection = FirebaseFirestore.instance.collection("sellers");
  String? profileImageUrl;

  Future<void> pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        File imageFile = File(image.path);

        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profilePictures/${currentUser.uid}');
        await storageRef.putFile(imageFile);

        // Get the image URL
        String downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new profile image URL
        await usersCollection.doc(currentUser.uid).update({'profileImageUrl': downloadUrl});

        // Update the state to reflect the new profile picture
        setState(() {
          profileImageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Error selecting or uploading profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReviewsPage(sellerId: currentUser.email!),
                ),
              );
            },
          ),
        ],
        leading: FutureBuilder<QuerySnapshot>(
          future: sellersCollection.where('email', isEqualTo: currentUser.email).get(),
          builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailabilityPage(sellerId: currentUser.email!),
                    ),
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
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

            // Fetch profile image URL
            profileImageUrl = userData['profileImageUrl'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: pickAndUploadImage,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : null,
                            backgroundColor: Colors.green[300],
                            child: profileImageUrl == null
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.email!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MyTextBox(
                              text: userData['username'] ?? '',
                              sectionName: "Username",
                              onPressed: () => editField("username"),
                              width: 200,
                              height: 90,
                              margin: const EdgeInsets.all(10),
                            ),
                            MyTextBox(
                              text: userData['bio'] ?? '',
                              sectionName: "Bio",
                              onPressed: () => editField("bio"),
                              width: 200,
                              height: 90,
                              margin: const EdgeInsets.all(10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<QuerySnapshot>(
                    future: sellersCollection
                        .where('email', isEqualTo: currentUser.email)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Container(
                            width: 200, // Set the width of the button
                            child: MyButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerSetupPage(onTap: () {}),
                                  ),
                                );
                              },
                              text: "Become a Seller",
                              color: Colors.green[300], // Set the button color to green[300]
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Photos Submitted",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Add any other widgets as needed
                ],
              ),
            );
          }

          return const Center(
            child: Text("User data not available"),
          );
        },
      ),
    );
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
}


class UserProfile extends StatelessWidget {
  final currentUser;
  final usersCollection;
  final sellersCollection;

  UserProfile({required this.currentUser, required this.usersCollection, required this.sellersCollection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          FutureBuilder<QuerySnapshot>(
            future: sellersCollection.where('email', isEqualTo: currentUser.email).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailabilityPage(sellerId: currentUser.email!),
                      ),
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.where('email', isEqualTo: currentUser.email).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return const Center(child: Text("Error loading user data"));
          }

          if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.docs.isNotEmpty) {
            final userData = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;

            // Fetch profile image URL
            final profileImageUrl = userData['profileImageUrl'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: pickAndUploadImage,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl)
                                : null,
                            backgroundColor: Colors.green[300],
                            child: profileImageUrl == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.email!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MyTextBox(
                              text: userData['username'] ?? '',
                              sectionName: "Username",
                              onPressed: () => editField("username"),
                              width: 200,
                              height: 90,
                              margin: const EdgeInsets.all(10),
                            ),
                            MyTextBox(
                              text: userData['bio'] ?? '',
                              sectionName: "Bio",
                              onPressed: () => editField("bio"),
                              width: 200,
                              height: 90,
                              margin: const EdgeInsets.all(10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<QuerySnapshot>(
                    future: sellersCollection
                        .where('email', isEqualTo: currentUser.email)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Container(
                            width: 150, // Adjust the width as needed
                            child: MyButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerSetupPage(onTap: () {}),
                                  ),
                                );
                              },
                              text: "Become a Seller",
                              color: Colors.green[300], // Set the button color to green[300]
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Add more widgets here
                ],
              ),
            );
          }

          return const Center(child: Text("No user data found"));
        },
      ),
    );
  }

  void pickAndUploadImage() {
    // Implement the function to pick and upload image
  }

  void editField(String field) {
    // Implement the function to edit field
  }
}
