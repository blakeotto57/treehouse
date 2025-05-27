import 'package:flutter/material.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/components/user_search.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const Navbar({super.key, this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF386A53),
      title: Row(
        children: [
          // Treehouse + Divider + School Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Treehouse",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 24,
                width: 1,
                color: Colors.white54,
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (context) {
                  final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                  final school = (userEmail.contains('@') && userEmail.contains('.edu'))
                      ? userEmail.split('@')[1].split('.edu')[0]
                      : '';
                  return Text(
                    school,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Flexible Search Bar
          Expanded(
            child: Container(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: widget.actions ??
      [
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ExplorePage()),
            );
          },
          icon: const Icon(Icons.explore, color: Colors.white),
          label: const Text("Explore", style: TextStyle(color: Colors.white)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MessagesPage()),
            );
          },
          icon: const Icon(Icons.message, color: Colors.white),
          label: const Text("Messages", style: TextStyle(color: Colors.white)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage()),
            );
          },
          icon: const Icon(Icons.person, color: Colors.white),
          label: const Text("Profile", style: TextStyle(color: Colors.white)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserSettingsPage()),
            );
          },
          icon: const Icon(Icons.settings, color: Colors.white),
          label: const Text("Settings", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}