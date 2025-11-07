import 'package:flutter/material.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/components/user_search.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/theme/theme.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final GlobalKey<SlidingDrawerState>? drawerKey;

  const Navbar({super.key, this.title, this.actions, this.drawerKey});

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
            icon: Icon(icon, color: Colors.white, size: 20),
            label: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        : IconButton(
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onTap,
            tooltip: label,
          );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onPressed: () {
              if (widget.drawerKey?.currentState != null) {
                widget.drawerKey!.currentState!.toggle();
              }
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
          elevation: 0,
          title: isWide
              ? InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => ExplorePage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Row(
                    children: [
                      const Text(
                        "Treehouse",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(height: 24, width: 1, color: Colors.white.withOpacity(0.3)),
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
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: UserSearch(),
                        ),
                      ),
                    ],
                  ),
              )
              : Center(
                  child: SizedBox(
                    height: 36,
                    child: UserSearch(),
                  ),
                ),
          actions: [
            _buildNavButton(
                icon: Icons.explore,
                label: "Explore",
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => ExplorePage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                isWide: isWide),
            _buildNavButton(
                icon: Icons.message,
                label: "Messages",
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => MessagesPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                isWide: isWide),
            _buildNavButton(
                icon: Icons.person,
                label: "Profile",
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => UserProfilePage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                isWide: isWide),
            _buildNavButton(
                icon: Icons.settings,
                label: "Settings",
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => const UserSettingsPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                isWide: isWide),
            ...?widget.actions,
          ],
        );
      },
    );
  }
}
