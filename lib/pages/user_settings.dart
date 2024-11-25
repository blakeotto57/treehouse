import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  //sign user out
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
        title: Text('User Settings'),
        centerTitle: true,
        actions: [
          // Log out button in the top right corner
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Settings Picture at the Top
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Section 1: Account Information
          buildSectionHeader('Account Information'),
          ListTile(
            title: Text('Name'),
            subtitle: Text('John Doe'), // Example, replace with dynamic data
            trailing: Icon(Icons.edit),
            onTap: () {
              // Handle edit functionality
            },
          ),
          ListTile(
            title: Text('Email'),
            subtitle: Text('johndoe@example.com'),
            trailing: Icon(Icons.edit),
            onTap: () {
              // Handle edit functionality
            },
          ),
          Divider(),

          // Section 2: Security
          buildSectionHeader('Security'),
          ListTile(
            title: Text('Change Password'),
            trailing: Icon(Icons.lock),
            onTap: () {
              // Handle password change
            },
          ),
          ListTile(
            title: Text('Two-Factor Authentication'),
            trailing: Switch(value: false, onChanged: (value) {
              // Handle toggle
            }),
          ),
          Divider(),

          // Section 3: Theme Customization
          buildSectionHeader('Theme Customization'),
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(value: false, onChanged: (value) {
              // Handle theme change
            }),
          ),
          ListTile(
            title: Text('Accent Color'),
            trailing: Icon(Icons.color_lens),
            onTap: () {
              // Handle color selection
            },
          ),
          Divider(),

          // Section 4: User Activity
          buildSectionHeader('User Activity'),
          ListTile(
            title: Text('Recent Activity'),
            onTap: () {
              // Handle navigation to activity page
            },
          ),
          Divider(),

          // Section 5: Transaction History
          buildSectionHeader('Transaction History'),
          ListTile(
            title: Text('View Transactions'),
            onTap: () {
              // Handle navigation to transaction history
            },
          ),
          Divider(),

          // Section 6: Linked Accounts
          buildSectionHeader('Linked Accounts'),
          ListTile(
            title: Text('Manage Social Media Connections'),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
