import 'package:flutter/material.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';
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
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isWide,
  }) {
    return isWide
        ? TextButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white),
            label: Text(label, style: const TextStyle(color: Colors.white)),
            
          )
        : IconButton(
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onTap,
          );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF386A53),
          title: isWide
              ? Row(
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
                    Container(height: 24, width: 1, color: Colors.white54),
                    const SizedBox(width: 12),
                    Builder(
                      builder: (context) {
                        final userEmail =
                            FirebaseAuth.instance.currentUser?.email ?? '';
                        final school = (userEmail.contains('@') &&
                                userEmail.contains('.edu'))
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
                    const SizedBox(width: 12),
                    // Search bar for wide mode
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: UserSearch(), // Use your custom search bar widget
                      ),
                    ),
                  ],
                )
              : Center(
                  child: SizedBox(
                    height: 36,
                    child: UserSearch(), // Only the search bar in compact mode
                  ),
                ),
          actions: [
            _buildNavButton(
                icon: Icons.explore,
                label: "Explore",
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const ExplorePage()));
                },
                isWide: isWide),
            _buildNavButton(
                icon: Icons.message,
                label: "Messages",
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => MessagesPage()));
                },
                isWide: isWide),
            _buildNavButton(
                icon: Icons.person,
                label: "Profile",
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => UserProfilePage()));
                },
                isWide: isWide),
            _buildNavButton(
                icon: Icons.settings,
                label: "Settings",
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const UserSettingsPage()));
                },
                isWide: isWide),
            ...?widget.actions,
          ],
        );
      },
    );
  }
}
