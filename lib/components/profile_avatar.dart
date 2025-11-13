import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/auth/presence_service.dart';
import 'package:treehouse/theme/theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? userEmail;
  final String? displayName;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showOnlineStatus;
  final bool isCurrentUser;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.userEmail,
    this.displayName,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.showOnlineStatus = true,
    this.isCurrentUser = false,
  });

  String _getInitials(String? name, String? email) {
    if (name != null && name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    }
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = backgroundColor ?? 
        (isDark ? AppColors.cardDark : AppColors.backgroundLight);
    final defaultTextColor = textColor ?? 
        (backgroundColor != null ? Colors.white : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen));
    
    final initials = _getInitials(displayName, userEmail);
    
    // If showing online status and not current user, wrap with status indicator
    if (showOnlineStatus && !isCurrentUser && userEmail != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final isOnline = (data?['isOnline'] as bool?) ?? false;
          
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: radius,
                backgroundColor: defaultBgColor,
                backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                    ? NetworkImage(photoUrl!)
                    : null,
                child: photoUrl == null || photoUrl!.isEmpty
                    ? Text(
                        initials,
                        style: TextStyle(
                          color: defaultTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: radius * 0.6,
                        ),
                      )
                    : null,
              ),
              // Online status indicator
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: radius * 0.4,
                    height: radius * 0.4,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: defaultBgColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
    
    // Regular avatar without online status
    return CircleAvatar(
      radius: radius,
      backgroundColor: defaultBgColor,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? NetworkImage(photoUrl!)
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Text(
              initials,
              style: TextStyle(
                color: defaultTextColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.6,
              ),
            )
          : null,
    );
  }
}

