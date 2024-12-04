import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/text_field.dart';

import '../components/button.dart';


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
    
      //make sure passwords match
      if (passwordTextController.text != confirmPasswordTextController.text) {
        //show error
        displayMessage("Passwords do not match!");
        return;
      
      }
      // try creating the user
      try {
        //create the user
        UserCredential userCredential = 
            
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text,
        );

        //after creating new user, create a new document in firebase for them
        FirebaseFirestore.instance
        .collection("users")
        .doc(userCredential.user!.uid)
        .set({
          "username" : emailTextController.text.split("@")[0],
          "bio" : "Empty bio",
          "email" : emailTextController.text,
          //add additional fields if needed
        });


      } on FirebaseAuthException catch (e) {
        
        // show error to user
        displayMessage(e.code);
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
                      'Lets join the treehouse',
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