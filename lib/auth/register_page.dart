import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/components/text_field.dart';
import '../components/button.dart';
import '../pages/explore_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:treehouse/theme/theme.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  bool isValidEducationalEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu$').hasMatch(email);
  }

  /*
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '545022405037-drtlnh2b0o6j8uoc0te2t20pft5fisie.apps.googleusercontent.com'
            : null,
        scopes: ['email', 'profile'],
      );

      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
      googleUser ??= await googleSignIn.signIn(); // fallback if not already signed in

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
          });
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExplorePage()),
        );
      }
    } catch (e) {
      print("Google sign-in error: $e");
    }
  }
  */

  Future<void> signUp() async {
    if (passwordTextController.text != confirmPasswordTextController.text) {
      displayMessage("Passwords do not match!");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
        });

        await user.sendEmailVerification();

        if (!mounted) return;
        Navigator.pop(context); // Close loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verify your email'),
            content: const Text(
                'A verification email has been sent. Please verify your account.'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (!mounted) return;
                  await user.reload();
                  if (FirebaseAuth.instance.currentUser!.emailVerified) {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => ExplorePage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
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
    } catch (e) {
      Navigator.pop(context);
      displayMessage('An error occurred. ${e.toString()}');
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Welcome to Treehouse",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                            icon: Icon(Icons.info_outline,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen, size: 32),
                                      const SizedBox(height: 10),
                                      Text(
                                        'College Email Required',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'We require a college email to ensure our community consists of verified college students.',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Got it'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: passwordTextController,
                      hintText: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: confirmPasswordTextController,
                      hintText: "Confirm Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        onTap: signUp,
                        text: "Sign Up",
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
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
                                        LoginPage(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Text(
                            "Login now",
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
