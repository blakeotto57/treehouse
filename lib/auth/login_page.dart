import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/text_field.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/home.dart';



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
    
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Reload the user to update verification status
      await userCredential.user?.reload();
      User? user = FirebaseAuth.instance.currentUser;
      
      if (!mounted) return;
    
      // Remove the loading indicator from the root navigator
      Navigator.of(context, rootNavigator: true).pop();
      
      if (user != null && user.emailVerified) {
        // Navigate to explore page after successful sign in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Sign out and display a message prompting email verification
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          displayMessage("Email is not verified yet. Please verify your email and try again.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        displayMessage(e.code);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        displayMessage("An error occurred. Please try again.");
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