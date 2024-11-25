import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:treehouse/models/seller_profile.dart';



class SellerSetupPage extends StatefulWidget {

  SellerSetupPage({super.key});

  @override
  _SellerSetupPageState createState() => _SellerSetupPageState();
}

class _SellerSetupPageState extends State<SellerSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

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

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }



  // Submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });



      //stores inputted data into firebase
      try {
        // Get the values from the controllers
        String name = _nameController.text.trim();
        String email = _emailController.text.trim();
        String phone = _phoneController.text.trim();
        String description = _descriptionController.text.trim();



        // Save the data to Firestore
        await FirebaseFirestore.instance.collection('sellers').add({
          'name': name,
          'email': email,
          'phone': phone,
          'category': selectedCategory,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        });


      // Clear the form after submission
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _descriptionController.clear();
      _images.clear();


        // Navigate to SellerProfilePage after successful setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SellerProfilePage(),  // Ensure SellerProfilePage is defined and imported
          ),
        );


    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting data: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone number field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
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
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
