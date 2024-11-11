// ignore_for_file: sort_child_properties_last, duplicate_ignore, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/pages/user_profile.dart'; // Import the user profile page

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  int _currentIndex = 0; // Keeps track of the current page index
  final PageController _pageController = PageController();

  void _getCategories() {
    categories = CategoryModel.getCategories();
  }

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  @override
  Widget build(BuildContext context) {
    _getCategories();

    return SafeArea(
      child: Scaffold(
        appBar: appBar(),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            HomeContent(categories: categories), // Home content page
            UserProfilePage(), // User profile page
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _pageController.jumpToPage(index); // Switches to the selected page
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.home)),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.person)),
                label: "",
              ),
            ],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// Home Page Content
class HomeContent extends StatelessWidget {
  final List<CategoryModel> categories;

  HomeContent({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchbar(),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(
                  color: Colors.grey,
                  thickness: 2.0,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 361,
                color: Colors.white,
                child: ListView.separated(
                  itemCount: categories.length,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(10),
                  separatorBuilder: (context, index) => SizedBox(height: 25),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => categories[index].onTap(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: categories[index].boxColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  categories[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                categories[index].iconPath,
                                width: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
    child: Container(decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2, 
            blurRadius: 2, 
            offset: Offset(0, 3),
          ),
        ],
      ),
      
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "search categories",
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.5),
          ),
          contentPadding: const EdgeInsets.all(10),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset('assets/icons/search-icon.svg', height: 10, width: 10),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );
}

// App Bar
AppBar appBar() {
  return AppBar(
    title: const Text(
      "Treehouse",
      style: TextStyle(
        color: Color.fromARGB(255, 174, 90, 65),
        fontSize: 40,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        shadows: [
          Shadow(
            offset: Offset(0, 3),
            blurRadius: 4,
            color: Colors.black,
          )
        ],
      ),
    ),
    centerTitle: true,
    backgroundColor: const Color.fromARGB(255, 106, 145, 87),
    elevation: 100,
    leading: GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        width: 35,
        height: 35,
        child: SvgPicture.asset('assets/icons/back-arrow.svg', height: 30, width: 30),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 156, 195, 137),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    actions: [
      GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          width: 35,
          height: 35,
          child: SvgPicture.asset('assets/icons/profile-icon.svg', height: 20, width: 20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 156, 195, 137),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    ],
  );
}
