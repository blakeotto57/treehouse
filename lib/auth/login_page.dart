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
          MaterialPageRoute(builder: (context) => ExplorePage()),
        );
      } else {
        // Sign out and display a message prompting email verification
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          displayMessage(
              "Email is not verified yet. Please verify your email and try again.");
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
                padding: const EdgeInsets.all(16.0), // Match register page
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.park, size: 48, color: Color(0xFF4D8061)), // Match register page
                    const SizedBox(height: 12), // Match register page

                    const Text(
                      'Welcome to treehouse',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4D8061),
                        letterSpacing: 1,
                        fontSize: 22, // Match register page
                      ),
                    ),
                    const SizedBox(height: 18), // Match register page

                    MyTextField(
                      controller: emailTextController,
                      hintText: "College Email",
                      obscureText: false,
                    ),
                    const SizedBox(height: 10), // Match register page

                    MyTextField(
                      controller: passwordTextController,
                      hintText: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 16), // Match register page

                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        onTap: signIn,
                        text: "Sign In",
                      ),
                    ),
                    const SizedBox(height: 16), // Match register page

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New User?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4D8061),
                            fontSize: 14, // Match register page
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
                              fontSize: 14, // Match register page
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