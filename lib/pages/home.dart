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
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() => [
        HomeContent(categories: CategoryModel.getCategories()),
        ExplorePage(),
        MessagesPage(),
        UserProfilePage(),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home, size: 26),
        title: 'Home',
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
        iconSize: 22, // Lower the icon
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.store, size: 26),
        title: 'Explore',
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
        iconSize: 22,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.message, size: 26),
        title: 'Messages',
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
        iconSize: 22,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline, size: 26),
        title: 'Profile',
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
        iconSize: 22,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style1, // Adjust to preferred style
      navBarHeight: 50, // Set the height of the bottom nav bar
      padding: EdgeInsets.symmetric(vertical: 8), // Lower icons
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<CategoryModel> categories;

  const HomeContent({required this.categories, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                mainAxisExtent: 120,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          categories[index].iconPath,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          categories[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget searchBar() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Search Categories",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

AppBar customAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.green[300],
    leading: IconButton(
      icon: const Icon(Icons.feedback, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FeedbackPage()),
        );
      },
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
    actions: [
      IconButton(
        icon: const Icon(Icons.settings, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserSettingsPage()),
          );
        },
      ),
    ],
  );
}
