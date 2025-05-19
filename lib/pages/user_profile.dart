import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/text_box.dart';
import 'package:treehouse/models/reviews_page.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:flutter/services.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

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

  @override
  void initState() {
    super.initState();
    _ensureDefaultUsername();
  }

  Future<void> _ensureDefaultUsername() async {
    final userDoc = await usersCollection.doc(currentUser.email).get();
    final defaultUsername = currentUser.email!.split('@')[0];
    if (!userDoc.exists) {
      // If user doc doesn't exist, create it with username
      await usersCollection.doc(currentUser.email).set({
        'username': defaultUsername,
        'email': currentUser.email,
        // Add any other default fields you want here
      });
    } else {
      final data = userDoc.data() as Map<String, dynamic>;
      if (data['username'] == null || data['username'].toString().trim().isEmpty) {
        await usersCollection.doc(currentUser.email).update({'username': defaultUsername});
      }
    }
  }

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
        final downloadUrl = await storageRef.getDownloadURL();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkBackground = const Color(0xFF181818);

    return Scaffold(
      backgroundColor: isDark ? darkBackground : pastelGreen,
      drawer: customDrawer(context),
      appBar: const Navbar(),
      body: Column(
        children: [
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
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.add_business),
                                          label: const Text("Add Product/Service"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53),
                                            foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                          ),
                                          onPressed: () => _showAddProductDialog(context),
                                        ),
                                        const SizedBox(height: 24),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: usersCollection
                                              .doc(currentUser.email)
                                              .collection('products')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }
                                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                              return const Text("No products/services yet.");
                                            }
                                            return Column(
                                              children: snapshot.data!.docs.map((doc) {
                                                final data = doc.data() as Map<String, dynamic>;
                                                final imageUrl = data['imageUrl'] as String?;
                                                return Card(
                                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (imageUrl != null && imageUrl.isNotEmpty)
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(12),
                                                            child: Image.network(
                                                              imageUrl,
                                                              height: 180,
                                                              width: double.infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        const SizedBox(height: 12),
                                                        Text(
                                                          data['name'] ?? '',
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Text(
                                                          data['description'] ?? '',
                                                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              "\$${data['price']?.toStringAsFixed(2) ?? '0.00'}",
                                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                            ),
                                                            Row(
                                                              children: [
                                                                IconButton(
                                                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                                                  onPressed: () => _showEditProductDialog(context, doc),
                                                                  tooltip: 'Edit',
                                                                ),
                                                                IconButton(
                                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                                  onPressed: () async {
                                                                    if ((data['imageUrl'] as String?)?.isNotEmpty ?? false) {
                                                                      try {
                                                                        await FirebaseStorage.instance.refFromURL(data['imageUrl']).delete();
                                                                      } catch (_) {}
                                                                    }
                                                                    await doc.reference.delete();
                                                                  },
                                                                  tooltip: 'Delete',
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      if (field == 'username') {
        // Use stored username or fallback to email prefix
        currentValue = (userData['username'] == null || userData['username'].toString().trim().isEmpty)
            ? currentUser.email!.split('@')[0]
            : userData['username'];
      } else {
        currentValue = userData[field] ?? '';
      }
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
          cursorColor: Colors.black, // <-- Add this line
          decoration: InputDecoration(
            hintText: 'Enter your ${field.toLowerCase()}',
          ),
          maxLines: field == 'bio' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
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
                final newValue = controller.text.trim();

                // If editing username, check for uniqueness
                if (field == 'username') {
                  final query = await usersCollection
                      .where('username', isEqualTo: newValue)
                      .get();

                  // If another user already has this username (excluding current user)
                  final isTaken = query.docs.any((doc) => doc.id != currentUser.email);

                  if (isTaken) {
                    if (mounted) {
                      Navigator.pop(context); // Close loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('That username is already taken.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                }

                // Update Firestore
                await usersCollection.doc(currentUser.email).update({
                  field: newValue,
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
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    XFile? pickedImage;
    final ImagePicker _picker = ImagePicker();
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Center(
              child: Text(
                'Add Product/Service',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          pickedImage = image;
                        });
                      }
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: pickedImage != null
                          ? (kIsWeb
                              ? FutureBuilder<Uint8List>(
                                  future: pickedImage!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.memory(snapshot.data!, fit: BoxFit.cover, width: 140, height: 140),
                                      );
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(File(pickedImage!.path), fit: BoxFit.cover, width: 140, height: 140),
                                ))
                          : const Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (USD)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final desc = descController.text.trim();
                        final price = double.tryParse(priceController.text.trim()) ?? 0.0;

                        if (name.isEmpty || price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid name and price')),
                          );
                          return;
                        }

                        setState(() {
                          isUploading = true;
                        });

                        String? imageUrl;
                        if (pickedImage != null) {
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child('productImages/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}_${pickedImage!.name}');
                          if (kIsWeb) {
                            final bytes = await pickedImage!.readAsBytes();
                            await storageRef.putData(bytes);
                          } else {
                            await storageRef.putFile(File(pickedImage!.path));
                          }
                          imageUrl = await storageRef.getDownloadURL();
                        }
                        // Save imageUrl to Firestore
                        await usersCollection
                            .doc(currentUser.email)
                            .collection('products')
                            .add({
                          'name': name,
                          'description': desc,
                          'price': price,
                          'imageUrl': imageUrl,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: isUploading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditProductDialog(BuildContext context, QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final TextEditingController nameController = TextEditingController(text: data['name'] ?? '');
    final TextEditingController descController = TextEditingController(text: data['description'] ?? '');
    final TextEditingController priceController = TextEditingController(text: data['price']?.toString() ?? '');
    XFile? pickedImage;
    final ImagePicker _picker = ImagePicker();
    bool isUploading = false;
    String? imageUrl = data['imageUrl'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Center(
              child: Text(
                'Edit Product/Service',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          pickedImage = image;
                        });
                      }
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: pickedImage != null
                          ? (kIsWeb
                              ? FutureBuilder<Uint8List>(
                                  future: pickedImage!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.memory(snapshot.data!, fit: BoxFit.cover, width: 140, height: 140),
                                      );
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(File(pickedImage!.path), fit: BoxFit.cover, width: 140, height: 140),
                                ))
                          : (imageUrl != null && imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(imageUrl!, fit: BoxFit.cover, width: 140, height: 140),
                                )
                              : const Icon(Icons.add_a_photo, size: 48, color: Colors.grey)),
                    ),
                  ),
                  if (imageUrl != null && imageUrl!.isNotEmpty && pickedImage == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          setState(() {
                            imageUrl = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (USD)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final desc = descController.text.trim();
                        final price = double.tryParse(priceController.text.trim()) ?? 0.0;

                        if (name.isEmpty || price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid name and price')),
                          );
                          return;
                        }

                        setState(() {
                          isUploading = true;
                        });

                        String? newImageUrl = imageUrl;

                        // If user picked a new image, upload it
                        if (pickedImage != null) {
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child('productImages/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}_${pickedImage!.name}');
                          if (kIsWeb) {
                            final bytes = await pickedImage!.readAsBytes();
                            await storageRef.putData(bytes);
                          } else {
                            await storageRef.putFile(File(pickedImage!.path));
                          }
                          newImageUrl = await storageRef.getDownloadURL();
                          // Optionally delete old image from storage
                          if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty) {
                            try {
                              await FirebaseStorage.instance.refFromURL(data['imageUrl']).delete();
                            } catch (_) {}
                          }
                        } else if (imageUrl == null && data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty) {
                          // If image was removed, delete from storage and set Firestore field to null
                          try {
                            await FirebaseStorage.instance.refFromURL(data['imageUrl']).delete();
                          } catch (_) {}
                          newImageUrl = null;
                        }

                        await doc.reference.update({
                          'name': name,
                          'description': desc,
                          'price': price,
                          'imageUrl': newImageUrl,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: isUploading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
