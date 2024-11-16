
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/models/seller_setup.dart';


import 'package:treehouse/models/marketplace.dart'; // Correct import for Marketplace
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
        appBar: _currentIndex == 0 ? appBar(context) : null, // Only show appBar for the Home page
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            HomeContent(categories: categories), // Home content page
            Marketplace(), // Marketplace page
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
            currentIndex: _currentIndex,  // Keep track of the selected tab
            onTap: (index) {
              // Only update the page index if it's different
              if (_currentIndex != index) {
                setState(() {
                  _currentIndex = index;
                });
                _pageController.jumpToPage(index);  // Update the PageView page
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.home)),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.store)), // Market icon leading to the Marketplace page
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
    return SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(255, 255, 255, 255), //top container background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchbar(),
            SizedBox(height: 5),
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
                  height: 400,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two items per row
                      crossAxisSpacing: 20, // Space between columns
                      mainAxisSpacing: 15, // Space between rows
                      mainAxisExtent: 75, // Height of each category box
                    ),
                    itemCount: categories.length,
                    padding: EdgeInsets.only(left: 5, right: 5, bottom: 75), // Added bottom padding here
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    categories[index].name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(255, 255, 255, 1),
                                      fontSize: 15,
                                      letterSpacing: 1.0,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 0), // Horizontal and vertical offset of the shadow
                                          blurRadius: 3, // The blur effect for the shadow
                                          color: Colors.black.withOpacity(0.4), // Shadow color
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: SvgPicture.asset(
                                  categories[index].iconPath,
                                  width: 30, // Shrinks icon
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
      ),
    );
  }
}


// Search Bar
Widget searchbar() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Container(
      decoration: BoxDecoration(
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
          hintText: "Search Categories",
          hintStyle: TextStyle(
            color:  Colors.grey,
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
    )
  );
}

AppBar appBar(BuildContext context) {
  return AppBar(
    leading: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerSetupPage(), // Replace with your desired page
          ),
        );
      },
      
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        width: 35,
        height: 40,
        child: Icon(Icons.money, color: Colors.white), // Example icon
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),

    title: const Text(
      "Treehouse",
      style: TextStyle(
        color: Color.fromARGB(255, 238, 236, 235),
        fontSize:40,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            offset: Offset(2, 3),
            blurRadius: 4,
            color: Colors.black,
          )
        ],
      ),
    ),
    centerTitle: true,
    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    elevation: 100,
    
    actions: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfilePage()
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.center,
          width: 35,
          height: 40,
          child: SvgPicture.asset('assets/icons/profile-icon.svg', height: 20, width: 20, color: Colors.white,),
          decoration: BoxDecoration(
            color:Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    ],
  );
}