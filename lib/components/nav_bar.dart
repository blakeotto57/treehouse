import 'package:flutter/material.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const Navbar({super.key, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    List<Widget> navActions = actions ??
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
      Container(
        height: 28,
        width: 1.2,
        color: Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  MessagesPage()),
          );
        },
        icon: const Icon(Icons.message, color: Colors.white),
        label: const Text("Messages", style: TextStyle(color: Colors.white)),
      ),
      Container(
        height: 28,
        width: 1.2,
        color: Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  UserProfilePage()),
          );
        },
        icon: const Icon(Icons.person, color: Colors.white),
        label: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      Container(
        height: 28,
        width: 1.2,
        color: Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
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
    ];

    return Material(
      elevation: 6,
      shadowColor: Colors.black54,
      child: Container(
        color: const Color(0xFF386A53),
        height: 56,
        child: Row(
          children: [
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.all(6.0),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: "Open navigation menu",
                ),
              ),
            ),
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1,
                ),
              ),
            const Spacer(),
            ...navActions,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}