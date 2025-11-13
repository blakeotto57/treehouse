import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/components/text_form_field.dart';
import 'package:treehouse/components/landing_header.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _generalError;

  bool isValidEducationalEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu$').hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!isValidEducationalEmail(value.trim())) {
      return 'Please enter a valid .edu email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordTextController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    if (user.emailVerified) {
      if (!mounted) return;
      setState(() {
        _emailSent = false;
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ExplorePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      if (!mounted) return;
      setState(() {
        _generalError = 'Email not verified yet. Please check your inbox and click the verification link.';
      });
    }
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _generalError = null;
      _emailSent = false;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
        });

        await user.sendEmailVerification();

        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _emailSent = true;
          _generalError = null;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e.code == 'weak-password') {
          _generalError = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _generalError = 'An account already exists with this email address.';
        } else if (e.code == 'invalid-email') {
          _generalError = 'Invalid email format.';
        } else {
          _generalError = 'An error occurred during registration. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generalError = 'An error occurred during registration. Please try again.';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _generalError = null;
      _emailSent = false;
    });

    try {
      // Configure GoogleSignIn with proper settings for web
      // For Flutter web, the client ID is set in web/index.html as a meta tag:
      // <meta name="google-signin-client_id" content="YOUR_CLIENT_ID">
      // The clientId parameter here is optional for web but can be used as a fallback
      // Note: We only need 'email' scope - Firebase Auth will provide the email from the ID token
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '545022405037-drtlnh2b0o6j8uoc0te2t20pft5fisie.apps.googleusercontent.com',
        scopes: ['email'], // Only request email scope to avoid People API requirement
      );

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Get email from Firebase user (most reliable source)
        // Firebase Auth provides the email from the ID token without needing People API
        final userEmail = user.email;
        if (userEmail == null || userEmail.isEmpty) {
          // Sign out from both Google and Firebase before showing error
          await googleSignIn.signOut();
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _generalError = 'Unable to retrieve email address. Please try again.';
          });
          return;
        }
        
        // Check if email is a .edu email
        if (!isValidEducationalEmail(userEmail)) {
          // Sign out from both Google and Firebase before showing error
          await googleSignIn.signOut();
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _generalError = 'You need to sign up with a .edu email address.';
          });
          return;
        }

        // Check if user document exists, if not create it
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
          });
        }

        if (!mounted) return;
        // Navigate to explore page
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ExplorePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Sign out from Google and Firebase on any auth error
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e.code == 'account-exists-with-different-credential') {
          _generalError = 'An account already exists with this email address using a different sign-in method.';
        } else if (e.code == 'invalid-credential') {
          _generalError = 'The credential is invalid. Please try again.';
        } else {
          _generalError = 'An error occurred during Google sign-in: ${e.message}';
        }
      });
    } catch (e) {
      // Handle ClientException and other errors
      String errorMessage = e.toString();
      
      // Check if this is a People API error
      if (errorMessage.contains('People API') || errorMessage.contains('SERVICE_DISABLED')) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _generalError = 'Google People API is not enabled. Please enable it in Google Cloud Console.';
        });
        return;
      }
      
      // Sign out from Google and Firebase on any error
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generalError = 'An error occurred during Google sign-in. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
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
              rightButtonText: 'Sign In',
              onRightButtonTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const LoginPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            
            // Register Form
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
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

                              if (_emailSent)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.mark_email_read, color: AppColors.primaryGreen, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Verification Email Sent',
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'A verification email has been sent to ${emailTextController.text.trim()}. Please verify your account before continuing.',
                                        style: TextStyle(
                                          color: AppColors.textSecondaryLight,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _checkEmailVerification,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('I have verified my email'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_generalError != null && !_emailSent)
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

                              Stack(
                                children: [
                                  MyTextFormField(
                                    controller: emailTextController,
                                    hintText: "College Email (.edu)",
                                    obscureText: false,
                                    validator: _validateEmail,
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
                              MyTextFormField(
                                controller: passwordTextController,
                                hintText: "Password",
                                obscureText: true,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 16),
                              MyTextFormField(
                                controller: confirmPasswordTextController,
                                hintText: "Confirm Password",
                                obscureText: true,
                                validator: _validateConfirmPassword,
                              ),
                              const SizedBox(height: 24),
                              
                              SizedBox(
                                width: double.infinity,
                                child: MyButton(
                                  onTap: _isLoading ? null : signUp,
                                  text: _isLoading ? "Creating Account..." : "Sign Up",
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Divider with "OR" text
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: isDark 
                                          ? AppColors.borderDark.withOpacity(0.3)
                                          : AppColors.borderLight.withOpacity(0.5),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: isDark 
                                            ? AppColors.textSecondaryDark 
                                            : AppColors.textSecondaryLight,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: isDark 
                                          ? AppColors.borderDark.withOpacity(0.3)
                                          : AppColors.borderLight.withOpacity(0.5),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Google Sign In Button - Using official Google Identity Services asset
                              // Reference: https://developers.google.com/identity/branding-guidelines
                              Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoading ? null : _signInWithGoogle,
                                    borderRadius: BorderRadius.circular(20), // Matching SVG border radius (rx="20")
                                    child: Container(
                                      width: 175, // Matching SVG width (175x40)
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/icons/google_sign_in_logo.svg',
                                        width: 175,
                                        height: 40,
                                        fit: BoxFit.contain,
                                        placeholderBuilder: (context) => Container(
                                          width: 175,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF2F2F2), // Neutral background from SVG
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Sign up with Google',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF1F1F1F),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                                                  const LoginPage(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration: Duration.zero,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Login now",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.accentBlueLight : AppColors.accentBlue,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline
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