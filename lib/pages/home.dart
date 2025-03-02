import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:treehouse/category_pages/personal_care.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/pages/feedback.dart';
import 'package:treehouse/pages/messages_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() => [
        ExplorePage(),
        MessagesPage(),
        UserProfilePage(),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.explore, size: 26),
        title: 'Explore',
        activeColorPrimary: Colors.green[800] ?? Colors.green,
        inactiveColorPrimary: Colors.grey,
        iconSize: 22,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.message, size: 26),
        title: 'Messages',
        activeColorPrimary: Colors.green[800] ?? Colors.green,
        inactiveColorPrimary: Colors.grey,
        iconSize: 22,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline, size: 26),
        title: 'Profile',
        activeColorPrimary: Colors.green[800] ?? Colors.green,
        inactiveColorPrimary: Colors.grey,
        iconSize: 22,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarStyle: NavBarStyle.style1,
        decoration: NavBarDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.green[800] ?? Colors.green,
              width: 1.0,
            ),
          ),
          colorBehindNavBar: Colors.white,
        ),
        navBarHeight: 50,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<CategoryModel> categories;

  const HomeContent({required this.categories, super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Treehouse",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[800],
              ),
              child: const Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...categories.map((category) => ListTile(
              leading: Icon(category.icon),
              title: category.name,
              onTap: () {
                Navigator.pop(context);
                category.onTap(context);
              },
            )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 60,
                ),
                itemCount: categories.length,
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => categories[index].onTap(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: categories[index].boxColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            categories[index].icon,
                            size: 40,
                            color: HSLColor.fromColor(categories[index].boxColor)
                                .withLightness(
                                  (HSLColor.fromColor(categories[index].boxColor).lightness - 0.2).clamp(0.0, 1.0)
                                )
                                .toColor(),
                          ),
                          const SizedBox(width: 10),
                          categories[index].name,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
