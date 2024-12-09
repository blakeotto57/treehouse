import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  // Sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 2,
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
          // Profile Picture at the Top
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green[300],
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 1: Account Information
          buildSectionHeader('Account Information'),
          buildListTile(
            title: 'Name',
            subtitle: 'John Doe', // Replace with dynamic data
            icon: Icons.edit,
            onTap: () {
              // Handle name edit
            },
          ),
          buildListTile(
            title: 'Email',
            subtitle: 'johndoe@example.com', // Replace with dynamic data
            icon: Icons.edit,
            onTap: () {
              // Handle email edit
            },
          ),
          const Divider(),

          // Section 2: Security
          buildSectionHeader('Security'),
          buildListTile(
            title: 'Change Password',
            icon: Icons.lock,
            onTap: () {
              // Handle password change
            },
          ),
          SwitchListTile(
            title: const Text('Two-Factor Authentication'),
            value: false,
            onChanged: (value) {
              // Handle toggle
            },
          ),
          const Divider(),

          // Section 3: Theme Customization
          buildSectionHeader('Theme Customization'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false,
            onChanged: (value) {
              // Handle theme change
            },
          ),
          buildListTile(
            title: 'Accent Color',
            icon: Icons.color_lens,
            onTap: () {
              // Handle color selection
            },
          ),
          const Divider(),

          // Section 4: User Activity
          buildSectionHeader('User Activity'),
          buildListTile(
            title: 'Recent Activity',
            onTap: () {
              // Handle navigation to activity page
            },
          ),
          const Divider(),

          // Section 5: Transaction History
          buildSectionHeader('Transaction History'),
          buildListTile(
            title: 'View Transactions',
            onTap: () {
              // Handle navigation to transaction history
            },
          ),
          const Divider(),

          // Section 6: Linked Accounts
          buildSectionHeader('Linked Accounts'),
          buildListTile(
            title: 'Manage Social Media Connections',
            onTap: () {
              // Handle linked account management
            },
          ),
        ],
      ),
    );
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
              color: Colors.green[300],
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: Colors.grey[100],
      dense: true,
    );
  }
}
