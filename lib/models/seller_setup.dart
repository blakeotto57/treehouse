import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/seller_profile.dart'; // Import the Seller Profile Page

String? globaluserid;

class SellerSetupPage extends StatefulWidget {
  const SellerSetupPage({super.key});

  @override
  _SellerSetupPageState createState() => _SellerSetupPageState();
}

class _SellerSetupPageState extends State<SellerSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  // Verify if the username and password match a seller in Firestore
  Future<bool> _checkUsernameAndPassword(String username, String password) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('sellers')  // Querying the 'sellers' collection
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();
      return querySnapshot.docs.isNotEmpty;  // Return true if matching seller found
    } catch (e) {
      print("Error checking username and password: $e");
      return false;  // Return false in case of error or no match
    }
  }

  // Submit the form and check login credentials
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Check if the username and password match a seller's profile in Firestore
      bool isValidUser = await _checkUsernameAndPassword(username, password);

      if (isValidUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        // After login, navigate to the Seller Profile Page
        globaluserid = username;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SellerProfilePage(userId: username),  // Pass userId as the document ID in Firestore
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password.')),
        );
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
