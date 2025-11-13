import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/auth/register_page.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/text_form_field.dart';
import 'package:treehouse/components/landing_header.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    // Clear login fields when page is shown
    emailTextController.clear();
    passwordTextController.clear();
    emailTextController.addListener(() {
      if (_generalError != null) {
        setState(() {
          _generalError = null;
        });
      }
    });
    passwordTextController.addListener(() {
      if (_generalError != null) {
        setState(() {
          _generalError = null;
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!value.trim().toLowerCase().endsWith('.edu')) {
      return 'Invalid email. Please use your .edu email address.';
    }
    // Basic email format validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid .edu email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  //sign user in
  void signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text.trim(),
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
            _generalError = "Email is not verified yet. Please verify your email and try again.";
            _isLoading = false;
          });
        }
        */
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.code == 'user-not-found') {
            _generalError = "No account found with this email address.";
          } else if (e.code == 'wrong-password') {
            _generalError = "Incorrect password. Please try again.";
          } else if (e.code == 'invalid-email') {
            _generalError = "Invalid email format.";
          } else if (e.code == 'user-disabled') {
            _generalError = "This account has been disabled.";
          } else if (e.code == 'too-many-requests') {
            _generalError = "Too many failed attempts. Please try again later.";
          } else {
            _generalError = "An error occurred. Please try again.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generalError = "An error occurred. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            LandingHeader(
              rightButtonText: 'Sign Up',
              onRightButtonTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => RegisterPage(onTap: () {}),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            
            // Login Form
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: Card(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
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

                              if (_generalError != null)
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
                                          _generalError!,
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

                              MyTextFormField(
                                controller: emailTextController,
                                hintText: "College Email",
                                obscureText: false,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 16),

                              MyTextFormField(
                                controller: passwordTextController,
                                hintText: "Password",
                                obscureText: true,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: MyButton(
                                  onTap: _isLoading ? null : signIn,
                                  text: _isLoading ? "Signing In..." : "Sign In",
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
                                        color: isDark ? AppColors.accentBlueLight : AppColors.accentBlue,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}