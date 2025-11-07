import 'package:flutter/material.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/theme/theme.dart';

class ProfessionalNavbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<SlidingDrawerState>? drawerKey;

  const ProfessionalNavbar({super.key, this.drawerKey});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.headerGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 20,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 24),
        onPressed: () {
          if (drawerKey?.currentState != null) {
            drawerKey!.currentState!.toggle();
          }
        },
      ),
      title: Row(
        children: [
          // Logo - circular icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.account_tree,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Treehouse branding
          RichText(
            text: TextSpan(
              text: 'Treehouse',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
              children: [
                const TextSpan(text: '  ', style: TextStyle(fontSize: 6)),
                TextSpan(
                  text: 'UCSC Marketplace',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Explore button
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const ExplorePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: const Text(
            'Explore',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        // Messages button
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => MessagesPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: const Text(
            'Messages',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        // New Post button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ElevatedButton.icon(
            onPressed: () {
              // This will be handled by the explore page's FAB or dialog
              // For now, just navigate to explore page
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const ExplorePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'New Post',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Roboto',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
