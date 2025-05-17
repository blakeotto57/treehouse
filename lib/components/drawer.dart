import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/category_model.dart';

// Rename to avoid conflict with Flutter's Drawer
Widget customDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFF386A53),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24),
            ),
          ),
          accountName: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.email)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  "",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                );
              }
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final userDocRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.email);

                if (data == null || data['username'] == null || data['username'].toString().trim().isEmpty) {
                  final emailPrefix = FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? "User";
                  userDocRef.set({'username': emailPrefix}, SetOptions(merge: true));
                  return Text(
                    emailPrefix,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  );
                }

                final username = data['username'];
                return Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                );
              }
              final emailPrefix = FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? "User";
              final userDocRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.email);
              userDocRef.set({'username': emailPrefix}, SetOptions(merge: true));
              return Text(
                emailPrefix,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              );
            },
          ),
          accountEmail: Text(
            FirebaseAuth.instance.currentUser?.email ?? "",
            style: const TextStyle(fontSize: 14),
          ),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF386A53), size: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            "Categories",
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...CategoryModel.getCategories().asMap().entries.map((entry) {
          final i = entry.key;
          final category = entry.value;
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Card(
              elevation: 0,
              color: category.boxColor.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                dense: true,
                minLeadingWidth: 0,
                leading: CircleAvatar(
                  backgroundColor: category.boxColor.withOpacity(0.18),
                  radius: 16,
                  child: Icon(
                    iconList.length > i ? iconList[i] : category.icon,
                    color: category.boxColor,
                    size: 18,
                  ),
                ),
                title: DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  child: category.name,
                ),
                onTap: () {
                  Navigator.pop(context);
                  category.onTap(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hoverColor: category.boxColor.withOpacity(0.10),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    ),
  );
}