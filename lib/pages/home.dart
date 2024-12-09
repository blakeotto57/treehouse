import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/models/chat_page.dart';
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
  List<CategoryModel> categories = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    categories = CategoryModel.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _currentIndex == 0 ? customAppBar(context) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeContent(categories: categories),
            ExplorePage(),
            MessagesPage(),
            const UserProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
          selectedItemColor: Colors.green[300],
          unselectedItemColor: Colors.grey,
          elevation: 8,
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<CategoryModel> categories;

  const HomeContent({required this.categories, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Categories",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
                      boxShadow: [
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.person_outline, color: Colors.white),
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
