import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/text_field.dart';

import '../components/button.dart';
import '../pages/home.dart';
import '../pages/explore_page.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({
    super.key,
    required this.onTap
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();


  // Add this validation function at class level
  bool isValidEducationalEmail(String email) {
    // Check if email is properly formatted and ends with .edu
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu$').hasMatch(email);
  }

  //sign up user
  Future<void> signUp() async {
    // Make sure passwords match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      // Show error
      displayMessage("Passwords do not match!");
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailTextController.text,
            password: passwordTextController.text,
          );

      User? user = userCredential.user;
      if (user != null) {
        // Save user info to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          // add additional fields as needed
        });

        // Send email verification
        await user.sendEmailVerification();

        if (!mounted) return; // Check if widget is still active
        
        // Show a dialog to inform user to check their email
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verify your email'),
            content: const Text('A verification email has been sent. Please verify your account.'),
            actions: [
              TextButton(
                onPressed: () async {
                  // Ensure widget is still mounted before proceeding
                  if (!mounted) return;
                  await user.reload();
                  if (FirebaseAuth.instance.currentUser!.emailVerified) {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ExplorePage()),
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email not verified yet.')),
                    );
                  }
                },
                child: const Text('I have verified'),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        displayMessage(e.code);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        print('Error: $e');
        displayMessage('An error occurred. Please try again.');
      }
    }
  }

  //display a dialog message
  void displayMessage(String message) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4D8061),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Logo
                  const Text(
                    'Welcome to treehouse',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                      fontSize: 25,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Email textfield with info icon
                  Stack(
                    children: [
                      MyTextField(
                        controller: emailTextController,
                        hintText: "College Email (.edu)",
                        obscureText: false,
                      ),
                      Positioned(
                        right: 10,
                        // Adjust top position to center vertically (assuming TextField height is ~48)
                        top: 5,
                        child: IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('College Email Required'),
                                content: const Text(
                                  'We require a college email to ensure our community consists of verified college students, creating a safe and trusted environment for campus connections.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Got it',
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Password textfield
                  MyTextField(
                    controller: passwordTextController,
                    hintText: "Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // Confirm password textfield
                  MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: "Confirm Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // Sign up button
                  MyButton(
                    onTap: signUp,
                    text: "Sign Up",
                  ),

                  const SizedBox(height: 25),

                  // Login now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}