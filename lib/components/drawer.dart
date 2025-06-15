import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/category_model.dart';

Widget customDrawer(BuildContext context) {
  return Drawer(
    child: customDrawerContent(context),
  );
}

Widget customDrawerContent(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final user = currentUser.email;

  return Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.black : Colors.white,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile section with improved spacing
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: user)
                    .limit(1)
                    .get(),
                builder: (context, snapshot) {
                  String? photoUrl;
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final userData =
                        snapshot.data!.docs.first.data() as Map<String, dynamic>;
                    photoUrl = userData['profileImageUrl'] as String?;
                  }
                  return CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.15),
                    radius: 20,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Text(
                            user != null && user.isNotEmpty ? user[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(width: 16), // Increased spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Loading...');
                        }
                        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                          return Text('Guest User');
                        }
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Text(
                          data['username'] ?? 'Guest User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    Text(
                      user ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
          child: Text(
            "CATEGORIES",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Category list with improved spacing
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: CategoryModel.getCategories().length,
            itemBuilder: (context, i) {
              final category = CategoryModel.getCategories()[i];
              final iconList = [
                Icons.spa,
                Icons.restaurant,
                Icons.camera_alt,
                Icons.menu_book,
                Icons.build,
                Icons.local_shipping,
                Icons.pets,
                Icons.cleaning_services,
              ];
              final iconColor = category.boxColor;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4), // Add vertical spacing between items
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4), // More horizontal padding
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      iconList.length > i ? iconList[i] : category.icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  title: category.name,
                  titleTextStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hoverColor: category.boxColor.withOpacity(0.15),
                  focusColor: category.boxColor.withOpacity(0.2),
                  tileColor: Colors.transparent, // Ensures the base color is transparent
                  selectedTileColor: category.boxColor.withOpacity(0.2), // For selected state
                  onTap: () {
                    Navigator.pop(context);
                    category.onTap(context);
                  },
                ),
              );
            },
          ),
        ),
        
        // Footer section with sign out
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1.0,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.logout,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            title: Text(
              "Sign Out",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      ],
    ),
  );
}