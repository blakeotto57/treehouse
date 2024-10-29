// ignore_for_file: sort_child_properties_last, duplicate_ignore

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
    return Scaffold(
      appBar: appBar(),
      body: Column (

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchbar(),

          SizedBox(height: 10,), //creates distance between searcbar and column

          Column(
            crossAxisAlignment: CrossAxisAlignment.start, //moves categoreis title to left
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                "Categories",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600
                  ),
                ),
              ),
              
              //light green box underneath categories
              SizedBox(height: 10), //distance between categories word and light green box
              Container(
                height: 400,
                color: Color.fromARGB(255, 196, 235, 177),
                child: ListView.separated(
                  itemCount: categories.length,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(15),
                  separatorBuilder: (context, index) => SizedBox(height: 25),//Creates space between categories
                  itemBuilder: (context, index) {
                    return Container(
                      height: 120, //adjusts the height of the category boxes
                      decoration: BoxDecoration(
                        color: categories[index].boxColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      //padding for category text
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              categories[index].name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 25,
                                 ),
                               ),
                              ),
                            ),

                          //padding for category icon
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              categories[index].iconPath,
                              width: 50,


                            ),
                          ),
                        ],
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

  Container searchba() {
    return Container(
          margin: EdgeInsets.only(top: 10, left: 20, right: 20), //creates search box dimensions
          decoration: BoxDecoration(
            boxShadow: [
            BoxShadow (
              color: Colors.black.withOpacity(0.11),
              blurRadius: 40,
              spreadRadius: 20,
            )
            ]
              
          ),
          child: searchbar(),
        );
  }

  TextField searchbar() {
    return TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              
              hintText: "search categories",
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.5)
              ),
              
              contentPadding: const EdgeInsets.all(10), //reduces text box height
              
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset('assets/icons/search-icon.svg', height: 10, width: 10),
                ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),//makes search bar circular
                borderSide: BorderSide.none,
              )
            ),
          );
  }

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
          ]
          
          ),
          ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 106, 145, 87),
        elevation: 100, //creates shadown for appbar


        leading: GestureDetector(
          onTap: () {},

          child: Container( //creates left back button
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          width: 35,
          height: 35,
          // ignore: sort_child_properties_last
          child: SvgPicture.asset('assets/icons/back-arrow.svg', height: 30, width: 30),
          decoration: BoxDecoration(
          color: const Color.fromARGB(255, 156, 195, 137),
          borderRadius: BorderRadius.circular(15) //make box have cured edges
          ),
        ),
        ),
          

          //right top button
          actions: [
            GestureDetector(
              onTap: () {},


              child: Container( //creates left back button
              margin: const EdgeInsets.all(10),
              alignment: Alignment.center,
              width: 35,
              height: 35,
              child: SvgPicture.asset('assets/icons/settings-icon.svg', height: 30, width: 30),

              decoration: 
              BoxDecoration( 
              color: const Color.fromARGB(255, 156, 195, 137),
              borderRadius: BorderRadius.circular(15) //make box have cured edges
              ),
         //Squeezes square in
          ),
            ),
    


          ],
    );
  }
}