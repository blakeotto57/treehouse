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
      String fileName =
          'seller_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSeller = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No user is logged in.");

      String description = _descriptionController.text.trim();
      List<String> imageUrls = await _uploadImages();

      // Create seller document
      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(currentUser.email)
          .set({
        'userId': currentUser.uid,
        'email': currentUser.email,
        'category': selectedCategory,
        'description': description,
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'seller': true,
      });

      // Update user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .update({
        'isSeller': true,
        'sellerCategory': selectedCategory,
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully registered as seller!')),
      );

      // Simply pop back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSeller = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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

              // Image upload section
              const Text(
                'Upload Images of Past Work',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo,
                    color: Colors.black),
                label: const Text('Add Images',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: Colors.black)),
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
                  : const SizedBox(height: 2),

              // Submit button
              const SizedBox(height: 10),
              Container(
                child: ElevatedButton(
                  onPressed: isSeller
                      ? null
                      : _submitForm, // Disable button when submitting
                  child: isSeller
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
