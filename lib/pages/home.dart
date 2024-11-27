import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/models/chat_page.dart';
import 'package:treehouse/models/seller_profile.dart';
import 'package:treehouse/models/marketplace.dart'; // Correct import for Marketplace
import 'package:treehouse/pages/user_settings.dart'; // Import the user profile page
import 'package:treehouse/pages/feedback.dart'; // Adjust path if necessary
import 'package:treehouse/pages/messages_page.dart'; // Correct import for MessagesPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  int _currentIndex = 0; // Keeps track of the current page index


@override
  void initState() {
    super.initState();
    categories = CategoryModel.getCategories(); // Load categories only once
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _currentIndex == 0
            ? appBar(context)
            : null, // Only show AppBar for the Home page
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeContent(categories: categories), // Home content page
            Marketplace(), // Marketplace page
            MessagesPage(),
            const SellerProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex, // Keep track of the selected tab
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
              label: "Marketplace",
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
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          elevation: 5,
        ),
      ),
    );
  }
}

// Conversations Page for Messages Tab
class ConversationsPage extends StatelessWidget {
  final String currentUserId;

  const ConversationsPage({required this.currentUserId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MessagesPage(); // Use MessagesList directly
  }
}

// Home Page Content
class HomeContent extends StatelessWidget {
  final List<CategoryModel> categories;

  const HomeContent({required this.categories, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchBar(),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Categories",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1.5,
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 100,
            ),
            itemCount: categories.length,
            padding: const EdgeInsets.all(10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Avoid nested scroll issues
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => categories[index].onTap(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: categories[index].boxColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        categories[index].iconPath,
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        categories[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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
    );
  }
}

// Search Bar
Widget searchBar() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Search Categories",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  );
}

// AppBar
AppBar appBar(BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.feedback),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  FeedbackPage()), // Navigate to FeedbackPage
        );
      },
    ),
    title: const Text(
      "TreeHouse",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.person_outline),
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
