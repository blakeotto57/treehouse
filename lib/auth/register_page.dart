import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/text_field.dart';

import '../components/button.dart';
import '../pages/home.dart';


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
 //text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();


  //sign up user
  void signUp() async {
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
    // Create the user
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailTextController.text,
      password: passwordTextController.text,
    );

    // After creating new user, create a new document in Firebase for them
    await FirebaseFirestore.instance.collection("users").doc(emailTextController.text).set({
      "username": emailTextController.text.split("@")[0],
      "bio": "Empty bio",
      "email": emailTextController.text,
      "password": passwordTextController.text,
      "profileImageUrl": null, // Add default value for profileImageUrl
      // Add additional fields if needed
    });

    // Pop loading indicator
    if (mounted) {
      Navigator.pop(context);
    }

    // Navigate to the home page or show success message
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomePage()),
      );
    }
  } on FirebaseAuthException catch (e) {
    // Pop loading indicator
    if (mounted) {
      Navigator.pop(context);
    }

    // Show error to user
    displayMessage(e.code);
  } catch (e) {
    // Pop loading indicator
    if (mounted) {
      Navigator.pop(context);
    }

    // Log and show any other errors
    print('Error: $e');
    displayMessage('An error occurred. Please try again.');
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
      backgroundColor: Colors.green[200],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              
                    //welcome to treehouse
                    const Text(
                      'Lets join treehouse',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          letterSpacing: 3,
                          fontSize: 20,
                      ),
                    ),
              
                    const SizedBox(height: 25),
              
              
                    //email textfield
                    MyTextField(
                      controller: emailTextController,
                      hintText: "Email",
                      obscureText: false,
                    ),
              
              
                    const SizedBox(height: 10),
              
              
                    //password textfield
                   MyTextField(
                      controller: passwordTextController,
                      hintText: "Password",
                      obscureText: true,
                    ),
              
              
                    const SizedBox(height: 10),
              
              
              
                     //CONFIRM password textfield
                   MyTextField(
                      controller: confirmPasswordTextController,
                      hintText: "Confirm Password",
                      obscureText: true,
                    ),
              
              
                    const SizedBox(height: 10),
              
              
                  //sign up button
                   MyButton(
                    onTap: signUp, 
                    text: "Sign Up",
                    ),
              
              
              
                    const SizedBox(height: 10),
              
                  //go to register page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
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