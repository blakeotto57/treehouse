import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/text_field.dart';



class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
    });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();


  //sign user in
  void signIn() async {
    //show loading circle
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
        ),
      );

      //try sign in
    try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text, 
        password: passwordTextController.text,
        );

        //pop loading circle
        if (mounted) {
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        
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
      backgroundColor: Colors.green[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
            
                  //welcome to treehouse
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
            
            
                  //email textfield
                  MyTextField(
                    controller: emailTextController,
                    hintText: "College Email",
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
            
            
                //sign in button
                 MyButton(
                  onTap: signIn, 
                  text: "Sign In",
                  ),
            
            
            
                  const SizedBox(height: 25),
            
                //go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New User?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        fontSize: 16,
                      ),    
                    ),
            
                    const SizedBox(width: 4),
            
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now", 
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
      );
    }
  }