import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/pages/feedback.dart';
import 'package:treehouse/components/nav_bar.dart';

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
    pageBuilder: (context, animation1, animation2) => LoginPage(),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastelGreen = const Color(0xFFF5FBF7);
    final darkBackground = const Color(0xFF181818);

    return Scaffold(
      drawer: customDrawer(context),
      appBar: const Navbar(),
      body: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.settings, color: Color(0xFF386A53)),
                const SizedBox(width: 10),
                const Text(
                  "User Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF386A53),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: Color(0xFF386A53).withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
                const SizedBox(width: 10),
                // Sign out button at the end of the header row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: signOut,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
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
                    title: "Change Password",
                    icon: Icons.lock,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => SingleChildScrollView(
                          child: AlertDialog(
                            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                            title: Row(
                              children: [
                                Text(
                                  "Change Password",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : textColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _currentPasswordController,
                                      decoration: InputDecoration(
                                        labelText: "Current Password",
                                        border: const OutlineInputBorder(),
                                        labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      ),
                                      obscureText: true,
                                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _newPasswordController,
                                      decoration: InputDecoration(
                                        labelText: "New Password",
                                        border: const OutlineInputBorder(),
                                        labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      ),
                                      obscureText: true,
                                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _confirmPasswordController,
                                      decoration: InputDecoration(
                                        labelText: "Confirm New Password",
                                        border: const OutlineInputBorder(),
                                        labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      ),
                                      obscureText: true,
                                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _changePassword();
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Change Password",
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.black : textColor,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
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
                        color: textColor,
                      ),
                    ),
                    value: Provider.of<ThemeProvider>(context).isDarkMode,
                    onChanged: (bool value) {
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    },
                  ),
                  const Divider(color: Colors.grey),
                  buildSectionHeader('App Feedback'),
                  buildListTile(
                    title: 'Send Feedback',
                    icon: Icons.feedback,
                    onTap: navigateToFeedback,
                  ),
                  const Divider(color: Colors.grey),
                  
                ],
              ),
            ),
          ),
        ],
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: Color(0xFF386A53),
        ),
      ),
    );
  }

  Widget buildListTile({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: icon != null
          ? Icon(
              icon,
              color: Colors.green[800],
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
}
