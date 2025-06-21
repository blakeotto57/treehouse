import 'package:flutter/material.dart';

import 'package:treehouse/category_pages/personal_care.dart';
import 'package:treehouse/category_pages/academics.dart';
import 'package:treehouse/category_pages/cleaning.dart';
import 'package:treehouse/category_pages/errands_moving.dart';
import 'package:treehouse/category_pages/pet_care.dart';
import 'package:treehouse/category_pages/photography.dart';
import 'package:treehouse/category_pages/technical_services.dart';
import 'package:treehouse/category_pages/food.dart';

//folder that distingushes the categories from one another
class CategoryModel {
  final Text name;
  final IconData icon;
  final Color boxColor;
  final Function(BuildContext) onTap;

  CategoryModel({
    required this.name,
    required this.icon,
    required this.boxColor,
    required this.onTap,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    //Personal Care box
    categories.add(
      CategoryModel(
          name: Text(
            "Personal Care",
            style: TextStyle(
              color: Color.fromRGBO(178, 129, 243, 1), // Darkened version of boxColor
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.person,
          boxColor: Color.fromRGBO(178, 129, 243, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/personal-care');
          }),
    );

    //Food box
    categories.add(
      CategoryModel(
          name: Text(
            "Food",
            style: TextStyle(
              color: Color.fromRGBO(90, 124, 239, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.food_bank,
          boxColor: Color.fromRGBO(90, 124, 239, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/food');
          }),
    );

    //Photography box
    categories.add(
      CategoryModel(
          name: Text(
            "Photography",
            style: TextStyle(
              color: Color.fromRGBO(40, 147, 134, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.camera,
          boxColor: Color.fromRGBO(40, 147, 134, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/photography');
          }),
    );

    //Academics box
    categories.add(
      CategoryModel(
          name: Text(
            "Academics",
            style: TextStyle(
              color: Color.fromRGBO(238, 138, 96, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.school,
          boxColor: Color.fromRGBO(238, 138, 96, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/academics');
          }),
    );

    //Technical Services box
    categories.add(
      CategoryModel(
          name: Text(
            "Technical",
            style: TextStyle(
              color: Color.fromRGBO(255, 64, 129, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.computer,
          boxColor: Color.fromRGBO(255, 64, 129, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/technical-services');
          }),
    );

    //Errands & Moving Services box
    categories.add(
      CategoryModel(
          name: Text(
            "Errands & Moving",
            style: TextStyle(
              color: Color.fromRGBO(255, 193, 7, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.local_shipping,
          boxColor: Color.fromRGBO(255, 193, 7, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/errands-moving');
          }),
    );

    //Pet Care box
    categories.add(
      CategoryModel(
          name: Text(
            "Pet Care",
            style: TextStyle(
              color: Color.fromRGBO(76, 175, 80, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.pets,
          boxColor: Color.fromRGBO(76, 175, 80, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/pet-care');
          }),
    );

    //Cleaning box
    categories.add(
      CategoryModel(
          name: Text(
            "Cleaning",
            style: TextStyle(
              color: Color.fromRGBO(191, 84, 210, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icons.cleaning_services,
          boxColor: Color.fromRGBO(191, 84, 210, 1),
          onTap: (context) {
            Navigator.pushNamed(context, '/category/cleaning');
          }),
    );

    return categories;
  }
}
