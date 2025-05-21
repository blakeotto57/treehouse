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

// Add this ListingTile widget below your _UserProfilePageState class or in a separate file and import it.
class ListingTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ListingTile({
    Key? key,
    required this.listing,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing['imageUrl'] as String?;
    final name = listing['name'] ?? 'No Name';
    final description = listing['description'] ?? '';
    final price = listing['price'] != null ? '\$${listing['price']}' : '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 120,   // Increased width
                      height: 120,  // Increased height
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 56, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (price.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  price,
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile Card at the top, centered
                              Center(
                                child: IntrinsicWidth(
                                  child: Card(
                                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    margin: const EdgeInsets.only(top: 16, bottom: 20), // Reduced margin
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8), // Reduced horizontal padding
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              GestureDetector(
                                                onTap: pickAndUploadImage,
                                                child: CircleAvatar(
                                                  radius: 48, // Slightly smaller avatar
                                                  backgroundColor: Colors.green[800],
                                                  backgroundImage: profileImageUrl != null
                                                      ? NetworkImage(profileImageUrl!)
                                                      : null,
                                                  child: profileImageUrl == null
                                                      ? const Icon(Icons.person, size: 48, color: Colors.white)
                                                      : null,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 2,
                                                right: 2,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isDarkMode ? Colors.grey[700] : Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(Icons.edit, size: 16, color: Colors.green[800]),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10), // Reduced spacing
                                          Text(
                                            computedUsername ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18, // Slightly smaller font
                                              color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            currentUser.email!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (bio != null && bio.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: isDarkMode ? Colors.grey[900] : Colors.green[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                bio,
                                                style: TextStyle(
                                                  fontSize: 13,
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
                                                fontSize: 12,
                                              ),
                                            ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => editField("username"),
                                                icon: Icon(Icons.edit, size: 16, color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53)),
                                                label: Text("Edit Username", style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53))),
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(color: isDarkMode ? Colors.orange[200]! : const Color(0xFF386A53)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              OutlinedButton.icon(
                                                onPressed: () => editField("bio"),
                                                icon: Icon(Icons.info_outline, size: 16, color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53)),
                                                label: Text("Edit Bio", style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53))),
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(color: isDarkMode ? Colors.orange[200]! : const Color(0xFF386A53)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.add_business, size: 18),
                                            label: const Text("Add Product/Service", style: TextStyle(fontSize: 14)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isDarkMode ? Colors.orange[200] : const Color(0xFF386A53),
                                              foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            ),
                                            onPressed: () => _showAddProductDialog(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Listings and Reviews side by side
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Listings Section
                                  Expanded(
                                    flex: 2,
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("My Listings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: usersCollection.doc(currentUser.email).collection('products').snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const Center(child: CircularProgressIndicator());
                                                }
                                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                  return const Text("No listings found.");
                                                }
                                                final listings = snapshot.data!.docs.map((doc) {
                                                  final data = doc.data() as Map<String, dynamic>;
                                                  return ListingTile(
                                                    listing: data,
                                                    onEdit: () => _showEditProductDialog(context, doc),
                                                    onDelete: () async {
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Delete Listing'),
                                                          content: const Text('Are you sure you want to delete this listing?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context, false),
                                                              child: const Text('Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context, true),
                                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirm == true) {
                                                        if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty) {
                                                          try {
                                                            await FirebaseStorage.instance.refFromURL(data['imageUrl']).delete();
                                                          } catch (_) {}
                                                        }
                                                        await doc.reference.delete();
                                                      }
                                                    },
                                                  );
                                                }).toList();
                                                return GridView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: listings.length,
                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 12,
                                                    crossAxisSpacing: 12,
                                                    childAspectRatio: 0.85, // Adjust for card shape
                                                  ),
                                                  itemBuilder: (context, index) => listings[index],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Reviews Section
                                  Expanded(
                                    flex: 2,
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Ratings & Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 16),
                                            // TODO: Replace with actual reviews
                                            Column(
                                              children: const [
                                                ListTile(
                                                  title: Text("Maria L.", style: TextStyle(fontWeight: FontWeight.bold)),
                                                  subtitle: Text("Great tutoring session, super helpful! ⭐⭐⭐⭐⭐"),
                                                ),
                                                ListTile(
                                                  title: Text("Josh K.", style: TextStyle(fontWeight: FontWeight.bold)),
                                                  subtitle: Text("Quick turnaround and great UI suggestions. ⭐⭐⭐⭐☆"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24), // width wrapped
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 40, color: Colors.green[700]),
                const SizedBox(height: 12),
                Text(
                  'Edit ${field.substring(0, 1).toUpperCase() + field.substring(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                StatefulBuilder(
                  builder: (context, setState) {
                    bool isFocused = false;
                    return Focus(
                      onFocusChange: (focus) => setState(() => isFocused = focus),
                      child: TextField(
                        controller: controller,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Enter your ${field.toLowerCase()}',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        style: TextStyle(color:Colors.grey),
                        maxLines: field == 'bio' ? 3 : 1,
                        onTap: () => setState(() => isFocused = true),
                        onEditingComplete: () => setState(() => isFocused = false),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
