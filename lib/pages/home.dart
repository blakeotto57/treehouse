import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/models/chat_page.dart';
import 'package:treehouse/models/seller_setup.dart';
import 'package:treehouse/models/seller_profile.dart';
import 'package:treehouse/models/marketplace.dart'; // Correct import for Marketplace
import 'package:treehouse/pages/user_profile.dart'; // Import the user profile page
import 'package:treehouse/pages/feedback.dart'; // Adjust path if necessary

String? globalSellerId; // Persistent global variable for Seller ID

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
    _loadSellerId();
    categories = CategoryModel.getCategories(); // Load categories only once
  }

  Future<void> _loadSellerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      globalSellerId = prefs.getString('sellerId');
    });
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
            globalSellerId != null
                ? ChatPage(
                    currentUserId: globalSellerId!,
                    chatRoomId: 'defaultRoom', // Replace with actual logic for chat room
                  )
                : const Center(
                    child: Text('Please set up your seller profile to use chat.'),
                  ), // Show message if globalSellerId is null
            globalSellerId != null
                ? SellerProfilePage(
                    sellerId: globalSellerId!,
                    currentUserId: globalSellerId!,
                  )
                : Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SellerSetupPage(),
                          ),
                        ).then((_) => _loadSellerId()); // Reload sellerId after setup
                      },
                      child: const Text('Set Up Seller Profile'),
                    ),
                  ),
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

// Home Page Content
class HomeContent extends StatelessWidget {
  final List<CategoryModel> categories;

  const HomeContent({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchbar(),
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
            physics: const ClampingScrollPhysics(), // Allow scrolling
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
Widget searchbar() {
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
          MaterialPageRoute(builder: (context) => FeedbackPage()), // Navigate to FeedbackPage
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
            MaterialPageRoute(builder: (context) => const UserProfilePage()),
          );
        },
      ),
    ],
  );
}
