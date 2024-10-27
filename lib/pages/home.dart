// ignore_for_file: sort_child_properties_last, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column (
        children: [
          Container(
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
          )
        ]
      )

          
    );
  }

  TextField searchbar() {
    return TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              
              hintText: "categories",
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