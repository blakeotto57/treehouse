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
Widget _buildNavButton(IconData icon, String label, VoidCallback onTap) {
  return TextButton.icon(
    onPressed: onTap,
    icon: Icon(icon, color: Colors.white),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12.0)),
  );
}


class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF386A53),
      title: LayoutBuilder(
        builder: (context, constraints) {
          final showTitle = constraints.maxWidth > 600;
          return Row(
            children: [
              if (showTitle)
                Flexible(
                  flex: 0,
                  child: Row(
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
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  child: const UserSearch(),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            if (isWide) {
              // Show buttons with text and icons
              return Row(
                children: [
                  _buildNavButton(Icons.explore, "Explore", () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const ExplorePage()));
                  }),
                  _buildNavButton(Icons.message, "Messages", () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => MessagesPage()));
                  }),
                  _buildNavButton(Icons.person, "Profile", () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => UserProfilePage()));
                  }),
                  _buildNavButton(Icons.settings, "Settings", () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserSettingsPage()));
                  }),
                ],
              );
            } else {
              // Show popup menu on small screens
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'Explore':
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ExplorePage()));
                      break;
                    case 'Messages':
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => MessagesPage()));
                      break;
                    case 'Profile':
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => UserProfilePage()));
                      break;
                    case 'Settings':
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserSettingsPage()));
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                      value: 'Explore',
                      child: ListTile(
                          leading: Icon(Icons.explore),
                          title: Text('Explore'))),
                  const PopupMenuItem(
                      value: 'Messages',
                      child: ListTile(
                          leading: Icon(Icons.message),
                          title: Text('Messages'))),
                  const PopupMenuItem(
                      value: 'Profile',
                      child: ListTile(
                          leading: Icon(Icons.person), title: Text('Profile'))),
                  const PopupMenuItem(
                      value: 'Settings',
                      child: ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Settings'))),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
