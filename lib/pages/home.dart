import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          "Categories", 

          style: TextStyle(
            
            color: Color.fromARGB(255, 104, 75, 37), 
            fontSize: 24, 
            fontWeight: FontWeight.bold
            ),
            ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 209, 255, 153),
          elevation: 100, //creates shadown for appbar


          leading: Container( //creates left back button
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
            color: const Color.fromRGBO(251, 101, 101, 1),
            borderRadius: BorderRadius.circular(15) //make box have cured edges
          ),
          child: SvgPicture.asset('assets/icons/back-arrow.svg'), //Squeezes square in

          ),
            
      ),

          
    );
  }
}