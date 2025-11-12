import 'package:flutter/material.dart';
import 'package:treehouse/components/landing_header.dart';
import 'package:treehouse/theme/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const LandingHeader(showRightButton: false),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 60,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Treehouse Connect',
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 48,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Treehouse Connect is a peer-to-peer service platform exclusively for college students. Whether you\'re looking for academic help, personal care services, food delivery, or technical support, our platform connects you with trusted students in your community.',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'To create a safe, trusted community where college students can connect, support each other, and access services from verified peers.',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

