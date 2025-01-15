import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  bool _isLoading = false;

  // Sign user out
  void signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    // Navigate to LoginPage using MaterialPageRoute
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onTap: () {}, // Add any necessary callback
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Settings",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[800],
        elevation: 2,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black, // Change icon color based on theme
        ),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: ListView(
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
                    title: Row(
                      children: [
                        Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
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
                        height: 200,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _currentPasswordController,
                              decoration: const InputDecoration(
                                labelText: "Current Password",
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _newPasswordController,
                              decoration: const InputDecoration(
                                labelText: "New Password",
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),                            
                            const SizedBox(height: 16),
                            TextField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: "Confirm New Password",
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
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
                                    color: textColor,
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
          
          const Divider(),

          // Section 2: Theme Customization
          buildSectionHeader('Theme Customization'),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (bool value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          
          const Divider(),

         
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
        FirebaseFirestore.instance.collection('users').doc(user.email!)
        .update({
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
          fontWeight: FontWeight.bold,
          color: Colors.green,
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
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: icon != null
          ? Icon(
              icon,
              color: Colors.green[800],
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      dense: true,
    );
  }
}
