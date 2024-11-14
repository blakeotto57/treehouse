import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;

  // Function to pick an image from the gallery (Optional)
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // Save the image path to the variable
      });
    }
  }

  // Save user profile data to Firestore (Only username and password)
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save the user data to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(_nameController.text).set({
        'username': _nameController.text,
        'password': _passwordController.text, // Save password
        // Optionally save profile image if available, else leave it as null
        'profileImage': _profileImage != null ? _profileImage!.path : null,
      });

      // Save to SharedPreferences for easier access later
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', _nameController.text);

      print("Profile saved successfully, navigating to home...");
      // Navigate to home page after saving the profile
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Error saving profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hi, Welcome to Treehouse.")),
      body: SingleChildScrollView( // Allow scrolling when the keyboard appears
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User's name input
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Please enter your username'),
              ),
              // User's password input
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Please enter a password'),
                  obscureText: true,
                ),
              ),
              // Title above profile image (Optional)
              Text(
                "Please select a profile picture (Optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10), // Space between title and the image
              // Profile image selection (Optional)
              GestureDetector(
                onTap: _pickImage,  // Tap to select an image
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              // Save Profile button
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text("Save Profile"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
