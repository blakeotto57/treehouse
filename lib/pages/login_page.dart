import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/models/seller_profile.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                String username = usernameController.text.trim();
                String password = passwordController.text.trim();

                // Validate login credentials
                bool isValidUser = await _checkUsernameAndPassword(username, password);

                if (isValidUser) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login successful!')),
                  );
                  // Navigate to the user's profile page after successful login
                  String userId = await _getUserIdByUsername(username); // Get the user ID from Firestore

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerProfilePage(userId: userId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid username or password.')),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  // Check if the username and password match in Firestore
  Future<bool> _checkUsernameAndPassword(String username, String password) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Assuming 'users' is your Firestore collection
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      return querySnapshot.docs.isNotEmpty; // Return true if user exists
    } catch (e) {
      print("Error checking username and password: $e");
      return false;
    }
  }

  // Fetch the userId based on the username
  Future<String> _getUserIdByUsername(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Assuming 'users' is your Firestore collection
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // Return the userId (document ID)
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      print("Error fetching userId: $e");
      throw e;
    }
  }
}
