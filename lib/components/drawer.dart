import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/category_model.dart';

Widget customDrawer(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final user = currentUser.email;

  return Drawer(
    backgroundColor: isDark ? Colors.black : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    width: 250,
    child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      radius: 30,
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
                const SizedBox(width: 12),
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

          // Section title
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 6),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),

          // Category list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4),
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

                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 20, right: 12),
                  leading: Icon(
                    iconList.length > i ? iconList[i] : category.icon,
                    size: 22,
                    color: iconColor,
                  ),
                  title: category.name,
                  titleTextStyle: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hoverColor: category.boxColor.withOpacity(0.08),
                  onTap: () {
                    Navigator.pop(context);
                    category.onTap(context);
                  },
                );
              },
            ),
          ),

          // Divider
          Divider(
            thickness: 1,
            height: 1,
          ),

          // Sign Out button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              onTap: () => FirebaseAuth.instance.signOut(),
              child: Row(
                children: [
                  const Icon(Icons.power_settings_new, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                    "Sign Out",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
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