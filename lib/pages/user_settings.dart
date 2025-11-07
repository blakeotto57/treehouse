import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/pages/feedback.dart';
import 'package:treehouse/components/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:treehouse/theme/theme.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  bool _isLoading = false;

  // Sign user out
  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LoginPage(onTap: () {}),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void navigateToFeedback() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => FeedbackPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void navigateToChangePassword() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : AppColors.cardLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.lock,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primaryGreenLight
                      : AppColors.primaryGreen,
                ),
                const SizedBox(width: 10),
                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400] // Dark mode label color
                          : Colors.grey[800], // Light mode label color
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2E2E2E) // Dark mode input background
                        : const Color(0xFFF5F5F5), // Light mode input background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreen,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Dark mode text color
                        : Colors.black, // Light mode text color
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[800],
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2E2E2E)
                        : const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreen,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[800],
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2E2E2E)
                        : const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreen,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[800],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add your change password logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primaryGreenLight
                      : AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Change Password",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final GlobalKey<SlidingDrawerState> _drawerKey =
        GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context), // Use customDrawerContent from drawer.dart
      child: Scaffold(
      drawer: customDrawer(context),
      appBar: Navbar(drawerKey: _drawerKey),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.settings, color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                const SizedBox(width: 10),
                Text(
                  "User Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
                
              ],
            ),
          ),
          // Settings content with left/right padding only (not top nav)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Section 1: Security
                  buildSectionHeader('Security'),
                  buildListTile(
                    title: 'Change Password',
                    icon: Icons.lock,
                    onTap: navigateToChangePassword,
                    titleStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : textColor, // Adjust text color based on theme
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  // Section 2: Theme Customization
                  buildSectionHeader('Theme Customization'),
                  SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.white
                            : textColor, // Adjust text color based on theme
                      ),
                    ),
                    value: Provider.of<ThemeProvider>(context).isDarkMode,
                    onChanged: (bool value) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                  const Divider(color: Colors.grey),
                  buildSectionHeader('App Feedback'),
                  buildListTile(
                    title: 'Send Feedback',
                    icon: Icons.feedback,
                    onTap: navigateToFeedback,
                    titleStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : textColor, // Adjust text color based on theme
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  // --- KO-FI BUTTON ---
                  buildKofiButton(context), // <--- Here!
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Update the password
        FirebaseFirestore.instance.collection('users').doc(user.email!).update({
          'password': _newPasswordController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password successfully updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is signed in')),
      );
    }
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryGreenLight
              : AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget buildListTile({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
    TextStyle? titleStyle,
  }) {
    return ListTile(
      title: Text(
        title,
        style: titleStyle ??
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: icon != null
          ? Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryGreenLight
                  : AppColors.primaryGreen,
            )
          : null,
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      dense: true,
    );
  }

  // --- KO-FI BUTTON FUNCTION ---
  Widget buildKofiButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            const url = 'https://ko-fi.com/treehouseconnect'; 
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch Ko-fi!')),
              );
            }
          },
          icon: Image.network(
            'https://storage.ko-fi.com/cdn/cup-border.png',
            height: 24,
            width: 24,
          ),
          label: const Text('Buy me a Ko-fi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5E5B), // Ko-fi red!
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
