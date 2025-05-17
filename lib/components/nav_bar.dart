import 'package:flutter/material.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/components/user_search.dart';

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
          const Text(
            "Treehouse Connect",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          // Replace the old search bar with UserSearch
          const Expanded(
            child: UserSearch(),
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