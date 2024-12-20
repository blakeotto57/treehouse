import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:treehouse/pages/home.dart';
import 'package:treehouse/pages/user_profile.dart';

class SellerSetupPage extends StatefulWidget {
  final Function()? onTap;
  const SellerSetupPage({
    super.key,
    required this.onTap,
  });

  @override
  _SellerSetupPageState createState() => _SellerSetupPageState();
}

class _SellerSetupPageState extends State<SellerSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  final List<String> serviceCategories = [
    'Personal Care',
    'Vending & Cooking',
    'Photography',
    'Academic Help',
    'Technical Services',
    'Errands & Moving',
    'Pet Care',
    'Cleaning',
  ];
  String? selectedCategory;

  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Declare isSeller as a state variable
  bool isSeller = false;

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  // Upload images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _images) {
      String fileName = 'seller_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(fileName);
      await ref.putFile(image);
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  // Submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSeller = true; // Show progress indicator
      });

      try {
        // Get the values from the controllers
        String description = _descriptionController.text.trim();
        String instagram = _instagramController.text.trim();
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          throw Exception("No user is logged in.");
        }

        // Upload images and get the URLs
        List<String> imageUrls = await _uploadImages();

        // Save the data to Firestore
        await FirebaseFirestore.instance.collection('sellers').doc(currentUser.email).set({
          'userId': currentUser.uid, // Store the user's UID
          'email': currentUser.email, // Store the user's email (optional)
          'category': selectedCategory,
          'description': description,
          'instagram': instagram, // Store the Instagram username
          'imageUrls': imageUrls, // Store image URLs
          'timestamp': FieldValue.serverTimestamp(),
          "seller": true,
        });

        // Clear the form after submission
        _descriptionController.clear();
        _instagramController.clear();
        _images.clear();

        // Navigate to SellerProfilePage after successful setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(), // Ensure SellerProfilePage is defined and imported
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting data: $e')),
        );
      } finally {
        setState(() {
          isSeller = false; // Reset state after submission
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text('Become a Seller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: const Text('Select a Market'),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                items: serviceCategories.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Market yourself here!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your products or services';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Instagram username field
              TextFormField(
                controller: _instagramController,
                decoration: InputDecoration(
                  labelText: 'Instagram (optional)',
                  hintText: 'Enter your Instagram username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image upload section
              const Text(
                'Upload Images of Past Work',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Add Images'),
              ),
              const SizedBox(height: 8),
              _images.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _images
                          .map((image) => Stack(
                                children: [
                                  Image.file(
                                    image,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _images.remove(image);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    )
                  : const Text('No images added yet.'),

              // Submit button
              const SizedBox(height: 24),
              Container(
                child: ElevatedButton(
                  onPressed: isSeller ? null : _submitForm, // Disable button when submitting
                  child: isSeller
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
