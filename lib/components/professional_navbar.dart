import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfessionalNavbar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<SlidingDrawerState>? drawerKey;

  const ProfessionalNavbar({super.key, this.drawerKey});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<ProfessionalNavbar> createState() => _ProfessionalNavbarState();
}

class _ProfessionalNavbarState extends State<ProfessionalNavbar> {
  ValueNotifier<bool>? _drawerNotifier;
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set up listener after the first frame when drawer key is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDrawerListener();
    });
  }

  void _setupDrawerListener() {
    final drawerState = widget.drawerKey?.currentState;
    if (drawerState != null && mounted) {
      _drawerNotifier = drawerState.isOpenNotifier;
      _drawerNotifier?.addListener(_onDrawerStateChanged);
      // Force rebuild to get initial state
      setState(() {});
    }
  }

  @override
  void dispose() {
    _drawerNotifier?.removeListener(_onDrawerStateChanged);
    super.dispose();
  }

  void _onDrawerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isDrawerOpen {
    return _drawerNotifier?.value ?? widget.drawerKey?.currentState?.isOpen ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Menu button and branding
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Menu button for drawer with icon transition
              Builder(
                builder: (context) {
                  // Use ValueListenableBuilder to react to drawer state changes
                  final drawerState = widget.drawerKey?.currentState;
                  final notifier = drawerState?.isOpenNotifier;
                  final iconColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
                  
                  if (notifier != null) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: notifier,
                      builder: (context, isOpen, child) {
                        return IconButton(
                          icon: AnimatedRotation(
                            turns: isOpen ? 0.25 : 0.0, // 0.25 turns = 90 degrees (vertical)
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.menu,
                              color: iconColor,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            if (drawerState != null) {
                              drawerState.toggle();
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        );
                      },
                    );
                  }
                  
                  // Fallback if drawer state is not available
                  return IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: iconColor,
                      size: 20,
                    ),
                    onPressed: () {
                      if (widget.drawerKey?.currentState != null) {
                        widget.drawerKey!.currentState!.toggle();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
              const SizedBox(width: 10),
              // Treehouse Connect branding (matching landing page)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    context.go('/explore');
                  },
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
            ],
          ),
          // Right side: Action buttons
          if (!isMobile)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Explore button
                TextButton(
                  onPressed: () {
                    context.go('/explore');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Explore',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 13,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                // Messages button
                TextButton(
                  onPressed: () {
                    context.go('/messages');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 13,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Profile Section
                _buildProfileSection(context, isDark),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isDark) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();
    
    final userEmail = currentUser.email ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get(),
      builder: (context, snapshot) {
        String? photoUrl;
        String displayName = 'Profile';
        String fullName = '';
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          photoUrl = userData?['profileImageUrl'] as String?;
          final username = userData?['username'] as String?;
          final name = userData?['name'] as String?;
          if (username != null && username.isNotEmpty) {
            displayName = username;
          } else if (userEmail.isNotEmpty) {
            displayName = userEmail.split('@')[0];
          }
          if (name != null && name.isNotEmpty) {
            fullName = name;
          }
        } else if (userEmail.isNotEmpty) {
          displayName = userEmail.split('@')[0];
        }

        // Get initials for avatar
        String initials = '';
        if (fullName.isNotEmpty) {
          final parts = fullName.split(' ');
          if (parts.length >= 2) {
            initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else if (parts.isNotEmpty) {
            initials = parts[0][0].toUpperCase();
          }
        }
        if (initials.isEmpty && userEmail.isNotEmpty) {
          initials = userEmail[0].toUpperCase();
        }

        return GestureDetector(
          onTap: () {
            _showProfilePopup(context, isDark, userEmail, fullName.isNotEmpty ? fullName : displayName, photoUrl, initials);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              key: _profileKey,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: isDark 
                    ? AppColors.cardDark 
                    : AppColors.backgroundLight,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(
                        initials.isNotEmpty ? initials : '?',
                        style: TextStyle(
                          color: isDark 
                              ? AppColors.primaryGreenLight 
                              : AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfilePopup(BuildContext context, bool isDark, String userEmail, String userName, String? photoUrl, String initials) {
    final RenderBox? renderBox = _profileKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return;
    
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const popupWidth = 280.0;
    const popupPadding = 8.0;
    
    // Calculate position
    double top = offset.dy + size.height + popupPadding;
    double right = screenWidth - offset.dx - size.width;
    
    // Ensure popup doesn't go off-screen to the right
    if (right < popupPadding) {
      right = popupPadding;
    }
    // Ensure popup doesn't go off-screen to the left
    if (right + popupWidth > screenWidth - popupPadding) {
      right = screenWidth - popupWidth - popupPadding;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            // Backdrop to close dialog when clicking outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Popup menu positioned near the profile icon
            Positioned(
              top: top,
              right: right,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: Container(
                  width: popupWidth,
                  constraints: BoxConstraints(
                    maxHeight: screenHeight - top - popupPadding,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _ProfilePopupContent(
                    userEmail: userEmail,
                    userName: userName,
                    photoUrl: photoUrl,
                    initials: initials,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfilePopupContent extends StatefulWidget {
  final String userEmail;
  final String userName;
  final String? photoUrl;
  final String initials;
  final bool isDark;

  const _ProfilePopupContent({
    required this.userEmail,
    required this.userName,
    this.photoUrl,
    required this.initials,
    required this.isDark,
  });

  @override
  State<_ProfilePopupContent> createState() => _ProfilePopupContentState();
}

class _ProfilePopupContentState extends State<_ProfilePopupContent> {
  bool _isThemeExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentIsDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: widget.isDark 
                    ? AppColors.cardDark 
                    : AppColors.backgroundLight,
                backgroundImage: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                    ? NetworkImage(widget.photoUrl!)
                    : null,
                child: (widget.photoUrl == null || widget.photoUrl!.isEmpty)
                    ? Text(
                        widget.initials.isNotEmpty ? widget.initials : '?',
                        style: TextStyle(
                          color: widget.isDark 
                              ? AppColors.primaryGreenLight 
                              : AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark 
                            ? AppColors.textPrimaryDark 
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: widget.isDark 
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
        ),
        // Menu Items
        _MenuItem(
          icon: Icons.person_outline,
          label: 'Profile',
          isDark: widget.isDark,
          onTap: () {
            Navigator.of(context).pop();
            context.go('/profile');
          },
        ),
        _MenuItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          isDark: widget.isDark,
          onTap: () {
            Navigator.of(context).pop();
            context.go('/settings');
          },
        ),
        // Expandable Theme Section
        Column(
          children: [
            _MenuItem(
              icon: Icons.brightness_6_outlined,
              label: 'Theme',
              isDark: widget.isDark,
              showArrow: true,
              arrowRotation: _isThemeExpanded ? 0.5 : 0.0,
              onTap: () {
                setState(() {
                  _isThemeExpanded = !_isThemeExpanded;
                });
              },
            ),
            // Theme Options (Light/Dark)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  _ThemeOption(
                    icon: Icons.light_mode,
                    label: 'Light',
                    isDark: widget.isDark,
                    isSelected: !currentIsDark,
                    onTap: () {
                      if (currentIsDark) {
                        themeProvider.toggleTheme();
                      }
                    },
                  ),
                  _ThemeOption(
                    icon: Icons.dark_mode,
                    label: 'Dark',
                    isDark: widget.isDark,
                    isSelected: currentIsDark,
                    onTap: () {
                      if (!currentIsDark) {
                        themeProvider.toggleTheme();
                      }
                    },
                  ),
                ],
              ),
              crossFadeState: _isThemeExpanded 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: widget.isDark 
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
        ),
        _MenuItem(
          icon: Icons.logout,
          label: 'Log out',
          isDark: widget.isDark,
          textColor: AppColors.errorRed,
          iconColor: AppColors.errorRed,
          onTap: () {
            Navigator.of(context).pop();
            _handleLogout(context);
          },
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LoginPage(onTap: () {}),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isDark;
  final bool showArrow;
  final double arrowRotation;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _MenuItem({
    this.icon,
    required this.label,
    required this.isDark,
    this.showArrow = false,
    this.arrowRotation = 0.0,
    this.textColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = textColor ?? (isDark 
        ? AppColors.textPrimaryDark 
        : AppColors.textPrimaryLight);
    final defaultIconColor = iconColor ?? (isDark 
        ? AppColors.textSecondaryDark 
        : AppColors.textSecondaryLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: defaultIconColor,
                ),
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 28),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: defaultTextColor,
                  ),
                ),
              ),
              if (showArrow)
                AnimatedRotation(
                  turns: arrowRotation,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.only(left: 28),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark 
                        ? AppColors.primaryGreenLight 
                        : AppColors.primaryGreen)
                    : (isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? (isDark 
                            ? AppColors.primaryGreenLight 
                            : AppColors.primaryGreen)
                        : (isDark 
                            ? AppColors.textPrimaryDark 
                            : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 16,
                  color: isDark 
                      ? AppColors.primaryGreenLight 
                      : AppColors.primaryGreen,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
