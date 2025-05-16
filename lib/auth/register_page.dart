import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/auth/login_page.dart';
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
      backgroundColor: const Color(0xFF4D8061),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Reduced from 32.0
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo or Icon (optional)
                    Icon(Icons.park, size: 48, color: Color(0xFF4D8061)), // Smaller icon
                    const SizedBox(height: 12), // Reduced from 24

                    // Welcome text
                    const Text(
                      'Welcome to treehouse',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4D8061),
                        letterSpacing: 1,
                        fontSize: 22, // Reduced from 28
                      ),
                    ),
                    const SizedBox(height: 18), // Reduced from 32

                    // Email textfield with info icon
                    Stack(
                      children: [
                        MyTextField(
                          controller: emailTextController,
                          hintText: "College Email (.edu)",
                          obscureText: false,
                        ),
                        Positioned(
                          right: 6,
                          top: 2,
                          child: IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SizedBox(
                                    width: 300,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.info_outline, color: Color(0xFF4D8061), size: 32),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'College Email Required',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color(0xFF4D8061),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'We require a college email to ensure our community consists of verified college students, creating a safe and trusted environment for campus connections.',
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                            
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF4D8061),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text(
                                                'Got it',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Reduced from 16

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
                    const SizedBox(height: 16), // Reduced from 24

                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        onTap: signUp,
                        text: "Sign Up",
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced from 24

                    // Login now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Color(0xFF4D8061),
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Reduced from 16
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage(onTap: () {  },)),
          );
        },
                          child: const Text(
                            "Login now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 14, // Reduced from 16
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
      ),
    );
  }
}