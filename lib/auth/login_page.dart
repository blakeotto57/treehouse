import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/auth/register_page.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/text_field.dart';
import 'package:treehouse/pages/explore_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, this.onTap}); // Make onTap optional

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  String? errorMessage; // <-- Add this line

  @override
  void initState() {
    super.initState();
    // Clear login fields when page is shown
    emailTextController.clear();
    passwordTextController.clear();
    emailTextController.addListener(() {
      if (errorMessage != null) {
        setState(() {
          errorMessage = null;
        });
      }
    });
    passwordTextController.addListener(() {
      if (errorMessage != null) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  //sign user in
  void signIn() async {
    setState(() {
      errorMessage = null; // Clear previous error
    });

    // Custom .edu email check
    if (!emailTextController.text.trim().toLowerCase().endsWith('.edu')) {
      setState(() {
        errorMessage = "Invalid email. Please use your .edu email address.";
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Force a reload and get the latest user object
      await userCredential.user?.reload();
      final freshUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (freshUser != null && freshUser.emailVerified) {
        emailTextController.clear();
        passwordTextController.clear();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ExplorePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        /*

        uncomment after testing is done

        
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            errorMessage = "Email is not verified yet. Please verify your email and try again.";
          });
        }
        */
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            errorMessage = "Either the email or password is incorrect.";
          } else {
            errorMessage = "An error occurred. Please try again.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "An error occurred. Please try again.";
        });
      }
    }
  }

  //register user
  void registerUser() async {
    try {
      // After creating the user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Send verification email
      await userCredential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage =
              "An error occurred during registration. Please try again.";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage =
              "An error occurred during registration. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF386A53),
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
                    const SizedBox(height: 16), // Match register page
                    Text(
                      "Treehouse",
                      style: TextStyle(
                        fontSize: 30, // Match register page
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4D8061),
                      ),
                    ),  
                    const SizedBox(height: 16), // Match register page

                    if (errorMessage != null) // <-- Show error message
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        RegisterPage(onTap: widget.onTap),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
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
