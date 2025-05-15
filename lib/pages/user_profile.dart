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
        await usersCollection
            .doc(currentUser.uid)
            .update({'profileImageUrl': downloadUrl});

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
      body: Column(
        children: [
          // Top nav bar (matches Explore/Messages)
          Container(
            color: const Color(0xFF386A53),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Treehouse Connect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/explore');
                      },
                      icon: const Icon(Icons.explore, color: Colors.white),
                      label: const Text("Explore", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 28,
                      width: 1.2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/messages');
                      },
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text("Messages", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 28,
                      width: 1.2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person, color: Colors.white),
                      label: const Text("Profile", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 28,
                      width: 1.2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserSettingsPage()),
                        );
                      },
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: const Text("Settings", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.person, color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53)),
                const SizedBox(width: 10),
                Text(
                  "Your Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: (isDarkMode ? Colors.orange[200]! : const Color(0xFF386A53)).withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          // Profile content
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
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
                  profileImageUrl =
                      (userData?['profileImageUrl']?.toString().trim().isEmpty ?? true)
                          ? null
                          : userData?['profileImageUrl'];

                  final username =
                      (userData?['username']?.toString().trim().isEmpty ?? true)
                          ? null
                          : userData?['username'];

                  final bio = (userData?['bio']?.toString().trim().isEmpty ?? true)
                      ? null
                      : userData?['bio'];

                  final currentUserAuth = FirebaseAuth.instance.currentUser;
                  final computedUsername = (userData?['username'] == null || userData!['username'].toString().trim().isEmpty)
                      ? (currentUserAuth?.email != null ? currentUserAuth!.email!.split('@')[0] : '')
                      : userData?['username'];

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 400),
                                child: Card(
                                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            GestureDetector(
                                              onTap: pickAndUploadImage,
                                              child: CircleAvatar(
                                                radius: 54,
                                                backgroundColor: Colors.green[800],
                                                backgroundImage: profileImageUrl != null
                                                    ? NetworkImage(profileImageUrl!)
                                                    : null,
                                                child: profileImageUrl == null
                                                    ? const Icon(Icons.person, size: 54, color: Colors.white)
                                                    : null,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              right: 4,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: isDarkMode ? Colors.grey[700] : Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(Icons.edit, size: 20, color: Colors.green[800]),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          computedUsername ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currentUser.email!,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (bio != null && bio.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isDarkMode ? Colors.grey[900] : Colors.green[50],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              bio,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        if (bio == null || bio.isEmpty)
                                          Text(
                                            "No bio yet. Add one!",
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                                              fontSize: 14,
                                            ),
                                          ),
                                        const SizedBox(height: 18),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => editField("username"),
                                                icon: Icon(Icons.edit, color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53)),
                                                label: Text("Edit Username", style: TextStyle(color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53))),
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(color: isDarkMode ? Colors.orange[200]! : const Color(0xFF386A53)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              OutlinedButton.icon(
                                                onPressed: () => editField("bio"),
                                                icon: Icon(Icons.info_outline, color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53)),
                                                label: Text("Edit Bio", style: TextStyle(color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53))),
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(color: isDarkMode ? Colors.orange[200]! : const Color(0xFF386A53)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Seller Button Section
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('sellers')
                                .doc(currentUser.email)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.exists) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SellerSetupPage(onTap: () {}),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.storefront, color: Colors.white),
                                  label: const Text('Become a Seller', style: TextStyle(fontSize: 16, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(
                  child: Text("User data not available"),
                );
              },
            ),
          ),
        ],
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

    final TextEditingController controller =
        TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Edit ${field.substring(0, 1).toUpperCase() + field.substring(1)}'),
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
