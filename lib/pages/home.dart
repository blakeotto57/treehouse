// ignore_for_file: sort_child_properties_last, duplicate_ignore, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:treehouse/models/category_model.dart';


class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  int _currentIndex = 0; //keeps track of current page
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



  //START OF SCAFFOLD CODE
  Widget build(BuildContext context) {
    _getCategories();

  return SafeArea(
    child: Scaffold(
      appBar: appBar(),
      body: PageView( //the page view is covered of the body of the screen
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index; //updates the bottom bar to reflect current page

          });
        },
        
        children: [
        HomeContent(categories: categories), 
        Center(
          child: Text(
            "User Profile Page",
            style: TextStyle(
              fontSize: 24,
            )
           )
          )
        ]
      ),


      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey, // Black border color
              width: 1.0, // Width of the border
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Center( // Center the icon
                child: Icon(Icons.home),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Center( // Center the icon
                child: Icon(Icons.verified_user_outlined),
              ),
              label: "",
            ),
          ],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white, // Background color
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          elevation: 0, // Removes space if no label
          ),
       ),
      ),
   );
  }
}
//END OF SCAFFOLD CODE





//HOME PAGE CONTENT STARTS HERE

class HomeContent extends StatelessWidget {
final List<CategoryModel> categories;

HomeContent({required this.categories});



//START OF CATEGORIES CODE
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a SizedBox to create space between the AppBar and the search bar
          SizedBox(height: 10), // Adjust the height as needed
          searchbar(),
          SizedBox(height: 10), 
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Moves categories title to left
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      color: Colors.black, //color of categories text
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
                // Light green box underneath categories
                SizedBox(height: 1),
                
                 // Distance between categories word and light green box
                Container(
                  height: 361, // Height of the light green box/category list view
                  color: Colors.white, //background color of category scroll
                  child: ListView.separated(
                    itemCount: categories.length,
                    scrollDirection: Axis.vertical,

                    padding: EdgeInsets.all(10),
                    separatorBuilder: (context, index) => SizedBox(height: 25), // Creates space between categories
                    itemBuilder: (context, index) {


                      //goes to category_model page
                      return InkWell(
                        onTap: () => categories[index].onTap(context),

                        child: Container(
                        height: 50, // Adjusts the height of the category boxes
                        decoration: BoxDecoration(
                          color: categories[index].boxColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // Padding for category text
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
                                    color: Colors.white, //font color of text in category bocxs
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            // Padding for category icon
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
          ),
        ],
      ),
    );
  }
}

//END OF CATEGORIES CODE





//START OF SEARCHBAR CODE

TextField searchbar() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "search categories",
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.5),
        ),
        contentPadding: const EdgeInsets.all(10), // reduces text box height
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset('assets/icons/search-icon.svg', height: 10, width: 10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // makes search bar circular
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


//END OF APP BAR CODE




//START OF APP BAR CODE
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
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black,
            )
          ],
        ),
      ),
  

      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 106, 145, 87),
      elevation: 100, // creates shadow for appbar

      leading: GestureDetector(
        onTap: () {},
        child: Container( // creates left back button
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          width: 35,
          height: 35,
          // ignore: sort_child_properties_last
          child: SvgPicture.asset('assets/icons/back-arrow.svg', height: 30, width: 30),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 156, 195, 137),
            borderRadius: BorderRadius.circular(15), // makes box have curved edges
          ),
        ),
      ),


      // right top button
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container( // creates right top button
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 35,
            height: 35,
            child: SvgPicture.asset('assets/icons/profile-icon.svg', height: 20, width: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 156, 195, 137),
              borderRadius: BorderRadius.circular(15), // makes box have curved edges
          ),
        ),
      ),
    ],
  );
}
//END OF APP BAR CODE

