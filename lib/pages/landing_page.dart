import 'package:flutter/material.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/components/button.dart';
import 'package:treehouse/components/landing_header.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

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
            // Header - Using LandingHeader component to match login/register pages
            LandingHeader(
              rightButtonText: 'Sign Up',
              onRightButtonTap: () => navigateToLogin(context),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: isMobile ? 40 : 80,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Your Campus Marketplace',
                            style: TextStyle(
                              fontSize: isMobile ? 36 : 56,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              letterSpacing: -2,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Connect with students, discover services, and build your campus community. \nA peer-to-peer platform designed for college students.',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 16,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: isMobile ? double.infinity : 200,
                            child: MyButton(
                              onTap: () => navigateToLogin(context),
                              text: 'Get Started',
                            ),
                          ),
                          if (isMobile) ...[
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () => navigateToLogin(context),
                              child: Text(
                                'Already have an account? Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Features Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: 60,
                      ),
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      child: Column(
                        children: [
                          Text(
                            'Why Treehouse Connect?',
                            style: TextStyle(
                              fontSize: isMobile ? 32 : 42,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              letterSpacing: -1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                          if (isMobile)
                            _buildFeaturesColumn(context, isDark)
                          else
                            _buildFeaturesRow(context, isDark),
                        ],
                      ),
                    ),

                    // About Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: 60,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'About Treehouse Connect',
                            style: TextStyle(
                              fontSize: isMobile ? 32 : 42,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              letterSpacing: -1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Treehouse Connect is a peer-to-peer service platform exclusively for college students. '
                              'Whether you\'re looking for academic help, personal care services, food delivery, '
                              'or technical support, our platform connects you with trusted students in your community. '
                              'Join thousands of students who are building connections and supporting each other.',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: 40,
                      ),
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      child: Column(
                        children: [
                          if (isMobile)
                            Column(
                              children: [
                                _buildFooterLink(context, isDark, 'About', '/about'),
                                const SizedBox(height: 12),
                                _buildFooterLink(context, isDark, 'Help', '/help'),
                                const SizedBox(height: 12),
                                _buildFooterLink(context, isDark, 'Terms', '/terms'),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFooterLink(context, isDark, 'About', '/about'),
                                const SizedBox(width: 32),
                                _buildFooterLink(context, isDark, 'Help', '/help'),
                                const SizedBox(width: 32),
                                _buildFooterLink(context, isDark, 'Terms', '/terms'),
                              ],
                            ),
                          const SizedBox(height: 24),
                          Text(
                            '© 2025 Treehouse Connect',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
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

  Widget _buildFeaturesRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFeatureCard(
            context,
            isDark,
            Icons.people,
            'Trusted Community',
            'Connect with verified college students in a safe, secure environment.',
          ),
        ),
        Expanded(
          child: _buildFeatureCard(
            context,
            isDark,
            Icons.category,
            'Academic Assistance',
            'Find everything from academics assistance to personal care, all in one place.',
          ),
        ),
        Expanded(
          child: _buildFeatureCard(
            context,
            isDark,
            Icons.bolt,
            'Quick & Easy',
            'Post services or find what you need in minutes.',
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesColumn(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildFeatureCard(
          context,
          isDark,
          Icons.people,
          'Trusted Community',
          'Connect with verified college students in a safe, secure environment.',
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          context,
          isDark,
          Icons.category,
          'Diverse Services',
          'Find everything from academics to personal care, all in one place.',
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          context,
          isDark,
          Icons.bolt,
          'Quick & Easy',
          'Post services or find what you need in minutes.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 40,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, bool isDark, String text, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

