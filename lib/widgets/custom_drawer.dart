import 'package:flutter/material.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/pages/user_settings.dart';

class CustomDrawer extends StatelessWidget {
  final List<CategoryModel> categories = CategoryModel.getCategories();

  CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Drawer(
        backgroundColor: Colors.white,
        elevation: 1,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green[300],
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...categories.map((category) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(
                    category.icon,
                    size: 20,
                    color: category.boxColor,
                  ),
                  title: Text(
                    (category.name as Text).data ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: category.boxColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    category.onTap(context);
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
              ],
            )).toList(),
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(
                Icons.settings,
                size: 20,
                color: Colors.grey[700],
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}