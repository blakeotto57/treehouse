import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:treehouse/pages/user_settings.dart'; // Adjust path if necessary

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle login logic
  Future<void> _login() async {
    try {
      // Get the username and password entered by the user
      String username = _usernameController.text;
      String password = _passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        _showErrorDialog("Please enter both username and password.");
        return;
      }

      // Retrieve the user's document from Firestore using the username
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userQuery.docs.isEmpty) {
        _showErrorDialog("User not found.");
        return;
      }

      // Assuming usernames are unique and there's only one result
      DocumentSnapshot userDoc = userQuery.docs.first;

      // Check if the password matches the one stored in Firestore
      String storedPassword = userDoc['password'];

      if (storedPassword != password) {
        _showErrorDialog("Incorrect password.");
        return;
      }

      // Navigate to the UserProfilePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
    } catch (e) {
      _showErrorDialog("Login failed: ${e.toString()}");
    }
  }

  // Function to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username input field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Password input field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            // Login button
            ElevatedButton(
              onPressed: _login,
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
