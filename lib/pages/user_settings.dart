import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/components/professional_navbar.dart';
import 'package:treehouse/pages/feedback.dart';
import 'package:treehouse/pages/about_page.dart';
import 'package:treehouse/pages/help_page.dart';
import 'package:treehouse/pages/terms_page.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Privacy preferences
  bool _profileVisibility = true;
  bool _showEmail = false;
  bool _allowMessages = true;
  
  // Account preferences
  bool _showOnlineStatus = true;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileVisibility = prefs.getBool('profile_visibility') ?? true;
      _showEmail = prefs.getBool('show_email') ?? false;
      _allowMessages = prefs.getBool('allow_messages') ?? true;
      _showOnlineStatus = prefs.getBool('show_online_status') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ChangePasswordDialog(
        currentPasswordController: _currentPasswordController,
        newPasswordController: _newPasswordController,
        confirmPasswordController: _confirmPasswordController,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
              Icons.warning_amber_rounded,
              color: AppColors.errorRed,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final GlobalKey<SlidingDrawerState> _drawerKey = GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context),
      child: Scaffold(
        drawer: customDrawer(context),
        appBar: ProfessionalNavbar(drawerKey: _drawerKey),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 40,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              _buildPageHeader(isDark),
              const SizedBox(height: 32),
              
              // Account Settings Card
              _buildSettingsCard(
                isDark: isDark,
                title: 'Account',
                icon: Icons.person_outline,
                children: [
                  _buildAccountInfo(isDark),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 32),
                  _buildSwitchTile(
                    isDark: isDark,
                    icon: Icons.circle_outlined,
                    title: 'Show Online Status',
                    subtitle: 'Display when you\'re online',
                    value: _showOnlineStatus,
                    onChanged: (value) {
                      setState(() => _showOnlineStatus = value);
                      _savePreference('show_online_status', value);
                    },
                  ),
                  const Divider(height: 32),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: _showDeleteAccountDialog,
                    textColor: AppColors.errorRed,
                    iconColor: AppColors.errorRed,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Privacy & Security Card
              _buildSettingsCard(
                isDark: isDark,
                title: 'Privacy & Security',
                icon: Icons.security_outlined,
                children: [
                  _buildSwitchTile(
                    isDark: isDark,
                    icon: Icons.visibility_outlined,
                    title: 'Profile Visibility',
                    subtitle: 'Allow others to view your profile',
                    value: _profileVisibility,
                    onChanged: (value) {
                      setState(() => _profileVisibility = value);
                      _savePreference('profile_visibility', value);
                    },
                  ),
                  const Divider(height: 32),
                  _buildSwitchTile(
                    isDark: isDark,
                    icon: Icons.email_outlined,
                    title: 'Show Email',
                    subtitle: 'Display your email on your profile',
                    value: _showEmail,
                    onChanged: (value) {
                      setState(() => _showEmail = value);
                      _savePreference('show_email', value);
                    },
                  ),
                  const Divider(height: 32),
                  _buildSwitchTile(
                    isDark: isDark,
                    icon: Icons.message_outlined,
                    title: 'Allow Messages',
                    subtitle: 'Let others send you messages',
                    value: _allowMessages,
                    onChanged: (value) {
                      setState(() => _allowMessages = value);
                      _savePreference('allow_messages', value);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Support & Help Card
              _buildSettingsCard(
                isDark: isDark,
                title: 'Support & Help',
                icon: Icons.help_outline,
                children: [
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    subtitle: 'Share your thoughts and suggestions',
                    onTap: () => _showFeedbackDialog(context),
                  ),
                  const Divider(height: 32),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get answers to common questions',
                    onTap: () => _showHelpDialog(context),
                  ),
                  const Divider(height: 32),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Learn more about Treehouse Connect',
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 32),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    onTap: () => _showTermsDialog(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Sign Out Button
              _buildSignOutButton(isDark),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.settings,
            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Text(
              'Settings',
                  style: TextStyle(
                fontSize: 28,
                    fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your account and preferences',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Not signed in';
    final displayName = user?.displayName ?? userEmail.split('@')[0];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
            .withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
              .withOpacity(0.2),
        ),
      ),
      child: Row(
              children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark ? AppColors.cardDark : AppColors.backgroundLight,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/profile'),
            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final defaultTextColor = textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final defaultIconColor = iconColor ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: defaultIconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: defaultIconColor, size: 20),
            ),
            const SizedBox(width: 16),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: defaultTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
        title,
                  style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: signOut,
        icon: const Icon(Icons.logout),
        label: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.errorRed,
          side: BorderSide(color: AppColors.errorRed, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final feedbackController = TextEditingController();
    final bugReportController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => _FeedbackDialogContent(
        isDark: isDark,
        feedbackController: feedbackController,
        bugReportController: bugReportController,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
        children: [
            Icon(
              Icons.help_outline,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            const SizedBox(width: 12),
            const Text(
              'Help Center',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFAQItem(
                  context,
                  isDark,
                  'How do I create an account?',
                  'You need a .edu email address to create an account. Click "Sign Up" on the homepage and follow the registration process.',
                ),
                const SizedBox(height: 16),
                _buildFAQItem(
                  context,
                  isDark,
                  'How do I post a service?',
                  'After logging in, navigate to the Explore page and click "New Post" to create a service listing.',
                ),
                const SizedBox(height: 16),
                _buildFAQItem(
                  context,
                  isDark,
                  'How do I contact a service provider?',
                  'Click on any service post to view details and send a message to the provider.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, bool isDark, String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
            question,
                  style: TextStyle(
              fontSize: 16,
                    fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
        children: [
            Icon(
              Icons.info_outline,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            const SizedBox(width: 12),
            const Text(
              'About Treehouse Connect',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Treehouse Connect is a peer-to-peer service platform exclusively for college students. Whether you\'re looking for academic help, personal care services, food delivery, or technical support, our platform connects you with trusted students in your community.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Our Mission',
                      style: TextStyle(
                        fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To create a safe, trusted community where college students can connect, support each other, and access services from verified peers.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
                children: [
            Icon(
              Icons.description_outlined,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            const SizedBox(width: 12),
            const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '1. Acceptance of Terms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By accessing and using Treehouse Connect, you accept and agree to be bound by the terms and provision of this agreement.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '2. User Eligibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You must be a college student with a valid .edu email address to use this platform. You are responsible for maintaining the security of your account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.6,
            ),
          ),
        ],
      ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackDialogContent extends StatefulWidget {
  final bool isDark;
  final TextEditingController feedbackController;
  final TextEditingController bugReportController;

  const _FeedbackDialogContent({
    required this.isDark,
    required this.feedbackController,
    required this.bugReportController,
  });

  @override
  State<_FeedbackDialogContent> createState() => _FeedbackDialogContentState();
}

class _FeedbackDialogContentState extends State<_FeedbackDialogContent> {
  bool showBugReportBox = false;
  int selectedRating = 0;
  bool isSubmitting = false;

  Future<void> _saveFeedback(String feedback, int rating, {bool isBugReport = false, String? bugDescription}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'anonymous';
      final username = userEmail.split('@')[0];
      
      await FirebaseFirestore.instance.collection('feedback').doc(username).set({
        'username': username,
        'feedback': feedback,
        'rating': rating,
        'isBugReport': isBugReport,
        'bugDescription': bugDescription,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving feedback: $e')),
        );
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (widget.feedbackController.text.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 10 characters')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    await _saveFeedback(
      widget.feedbackController.text,
      selectedRating,
      isBugReport: showBugReportBox,
      bugDescription: showBugReportBox ? widget.bugReportController.text : null,
    );

    if (mounted) {
      setState(() => isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.feedback_outlined,
            color: widget.isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
          const SizedBox(width: 12),
          const Text(
            'Send Feedback',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.feedbackController,
                decoration: InputDecoration(
                  hintText: 'Your feedback (min 10 characters)',
                  filled: true,
                  fillColor: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                maxLines: 4,
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: index < selectedRating ? Colors.amber : Colors.grey[400],
                      size: 28,
                    ),
                    onPressed: () => setState(() => selectedRating = index + 1),
                  );
                }),
              ),
              Row(
                children: [
                  Checkbox(
                    value: showBugReportBox,
                    onChanged: (val) => setState(() => showBugReportBox = val ?? false),
                    activeColor: widget.isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                  const Text('Report a bug'),
                ],
              ),
              if (showBugReportBox)
                TextField(
                  controller: widget.bugReportController,
                  decoration: InputDecoration(
                    hintText: 'Describe the bug...',
                    filled: true,
                    fillColor: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
      child: Text(
            'Cancel',
        style: TextStyle(
              color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  const _ChangePasswordDialog({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    if (widget.newPasswordController.text != widget.confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    if (widget.newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
          email: user.email!,
        password: widget.currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(widget.newPasswordController.text);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
      } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
          const SizedBox(width: 12),
          const Text(
            'Change Password',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
          ),
        ),
      ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}
