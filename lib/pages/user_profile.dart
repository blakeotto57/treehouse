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
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/pages/user_settings.dart';

class UserProfilePage extends StatefulWidget {
  final List<CategoryModel> categories = CategoryModel.getCategories();
  
  UserProfilePage({Key? key}) : super(key: key);

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
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
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
          "Profile",
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
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: pickAndUploadImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.green[800],
                                  child: profileImageUrl == null 
                                      ? null 
                                      : const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                  backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.grey, // Changed from Colors.green[300] to Colors.grey
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentUser.email!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // User Info Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person, color: Colors.green[800]),
                          title: const Text("Username"),
                          subtitle: Text(userData['username'] ?? ''),
                          trailing: Icon(Icons.edit, color: Colors.green[800]),
                          onTap: () => editField("username"),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.info, color: Colors.green[800]),
                          title: const Text("Bio"),
                          subtitle: Text(userData['bio'] ?? ''),
                          trailing: Icon(Icons.edit, color: Colors.green[800]),
                          onTap: () => editField("bio"),
                        ),
                      ],
                    ),
                  ),

                  // Seller Button Section
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
                              backgroundColor: Colors.green[800],
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
    String currentValue = '';
    final userDoc = await usersCollection.doc(currentUser.email).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      currentValue = userData[field] ?? '';
    }

    final TextEditingController controller = TextEditingController(text: currentValue);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${field.substring(0, 1).toUpperCase() + field.substring(1)}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your ${field.toLowerCase()}',
          ),
          maxLines: field == 'bio' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Update Firestore
                await usersCollection.doc(currentUser.email).update({
                  field: controller.text.trim(),
                });

                // Close loading indicator and edit dialog
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$field updated successfully!'),
                      backgroundColor: Colors.green[800],
                    ),
                  );
                }
              } catch (e) {
                // Close loading indicator
                if (mounted) Navigator.pop(context);
                
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating $field: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
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
                            backgroundColor: Colors.green[800],
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
                              color: Colors.green.shade800, // Set the button color to green.shade300
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
