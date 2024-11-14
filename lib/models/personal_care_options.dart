import 'package:flutter/material.dart';

import 'package:treehouse/pages/category_pages/personal_care.dart';
import 'package:treehouse/pages/category_pages/vending_cooking.dart';

// Placeholder for CategoryModel if it's not defined elsewhere
class CategoryModel {
  final Widget text;
  final String iconPath;
  final Color boxColor;
  final Function(BuildContext) onTap;

  CategoryModel({
    required this.text,
    required this.iconPath,
    required this.boxColor,
    required this.onTap,
  });
}

// Class that provides a list of category options for Personal Care
class PersonalCareOptions {
  static List<CategoryModel> getpersonalcareoptions() {
    List<CategoryModel> categories = [];




    // HAIRCUT & STYLING category
    categories.add(
      CategoryModel(
        text: Text(
          "Tyler A.", 
          style: TextStyle(
            color: Colors.black,
          fontWeight: FontWeight.bold,
          ),
        ),
        iconPath: "assets/icons/style-icon.svg",
        boxColor: Color.fromRGBO(239, 215, 57, 1),
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PersonalCarePage()),
          );
        },
      ),
    );




    // MAKEUP & BEAUTY category
    categories.add(
      CategoryModel(
        text: Text(
          "Max B.", 
          style: TextStyle(color: Colors.black,
          fontWeight: FontWeight.bold,
          ),
        ),
        iconPath: "assets/icons/makeup-icon.svg",
        boxColor: Color.fromRGBO(239, 57, 96, 1),
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VendingCookingPage()),
          );
        },
      ),
    );





    return categories;
  }
}
