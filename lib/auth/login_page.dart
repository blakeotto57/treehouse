import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/auth/register_page.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/text_field.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/theme/theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Treehouse",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: AppColors.errorRed,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    MyTextField(
                      controller: emailTextController,
                      hintText: "College Email",
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),

                    MyTextField(
                      controller: passwordTextController,
                      hintText: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        onTap: signIn,
                        text: "Sign In",
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New User?",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => RegisterPage(onTap: () {}),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Text(
                            "Register now",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              fontSize: 14,
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
