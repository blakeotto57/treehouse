import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components.dart/button.dart';
import 'package:treehouse/components.dart/text_field.dart';


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

      //make sure passwirds match
      if (passwordTextController.text != confirmPasswordTextController.text) {
        //pop loading circle
        Navigator.pop(context);
        
        //show error
        displayMessage("Passwords do not match!");
        return;
      
      }
      // try creating the user
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text,
        );

        //pop loading circle
        if (context.mounted) Navigator.pop(context);
        

      } on FirebaseAuthException catch (e) {
        // pop loading circle
        Navigator.pop(context);
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