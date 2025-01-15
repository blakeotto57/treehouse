import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/text_box.dart';
import 'package:treehouse/models/reviews_page.dart';
import 'package:treehouse/pages/seller_setup.dart'; // Import the seller setup page
import 'package:flutter/services.dart';
import 'package:treehouse/widgets/custom_drawer.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('sellers')
                .where('email', isEqualTo: currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewsPage(sellerId: currentUser.email!),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink(); // Returns empty widget if user is not a seller
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(currentUser.email).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return const Center(child: Text("Error loading user data"));
          }

          if (userSnapshot.hasData && userSnapshot.data != null) {
            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            if (userData == null) {
              return const Center(child: Text("User data is null"));
            }

            if (userData == null) {
              return const Center(child: Text("User data is null"));
            }

            // Fetch profile image URL
            profileImageUrl = userData['profileImageUrl'] ?? "";

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
                            backgroundImage: profileImageUrl!.isNotEmpty
                                ? NetworkImage(profileImageUrl!)
                                : null,
                            backgroundColor: Colors.green[300],
                            child: profileImageUrl!.isEmpty
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
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            MyTextBox(
                              text: userData['username'] ?? '',
                              sectionName: "Username",
                              onPressed: () => editField("username"),
                              width: 200,
                              margin: const EdgeInsets.all(10),
                            ),
                            
                            MyTextBox(
                              text: userData['bio'] ?? '',
                              sectionName: "Bio",
                              onPressed: () => editField("bio"),
                              width: 200,
                              margin: const EdgeInsets.all(10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sellers')
                        .doc(currentUser.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Hide button if seller document exists
                      if (snapshot.hasData && snapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }
                      
                      // Show button if user is not a seller
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellerSetupPage(onTap: () {}),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[300],
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text(
                              'Become a Seller',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Additional Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Add more widgets here
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
    int charLimit = field == "username" ? 20 : 200;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Edit $field",
            style: const TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter new $field",
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(charLimit),
                  ],
                  maxLines: field == "bio" ? null : 1,
                  keyboardType: field == "bio" ? TextInputType.multiline : TextInputType.text,
                  onChanged: (value) {
                    setState(() {
                      newValue = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '${newValue.length}/$charLimit characters',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (newValue.trim().isNotEmpty) {
                  usersCollection.doc(currentUser.uid).update({field: newValue});
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
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
                              margin: const EdgeInsets.all(10),
                            ),
                            MyTextBox(
                              text: userData['bio'] ?? '',
                              sectionName: "Bio",
                              onPressed: () => editField("bio"),
                              width: 200,
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
                            width: 250, // Adjust the width to ensure the text is all on one line
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
                              color: Colors.green.shade300, // Set the button color to green.shade300
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
