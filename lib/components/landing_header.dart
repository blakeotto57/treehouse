import 'package:flutter/material.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/pages/landing_page.dart';

class LandingHeader extends StatelessWidget {
  final String? rightButtonText;
  final VoidCallback? onRightButtonTap;
  final bool showRightButton;

  const LandingHeader({
    super.key,
    this.rightButtonText,
    this.onRightButtonTap,
    this.showRightButton = true,
  });

  void navigateToHome(BuildContext context) {
    // Check if we're already on the landing page to avoid unnecessary navigation
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == '/' || currentRoute == '/landing') {
      return; // Already on landing page, don't navigate
    }
    
    // Use pushReplacement with a smooth fade transition to avoid jumping
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LandingPage(),
        transitionDuration: const Duration(milliseconds: 100),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade transition to avoid visual jump
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? AppColors.borderDark.withOpacity(0.3)
                : AppColors.borderLight.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => navigateToHome(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Treehouse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!isMobile && showRightButton)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryGreenDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRightButtonTap ?? () => navigateToHome(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      rightButtonText ?? 'Home',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

