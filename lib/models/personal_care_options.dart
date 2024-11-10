import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:treehouse/pages/category_pages/personal_care.dart';
import 'package:treehouse/pages/category_pages/academic_assistance.dart';
import 'package:treehouse/pages/category_pages/cleaning.dart';
import 'package:treehouse/pages/category_pages/errands_moving.dart';
import 'package:treehouse/pages/category_pages/pet_care.dart';
import 'package:treehouse/pages/category_pages/photography.dart';
import 'package:treehouse/pages/category_pages/technical_services.dart';
import 'package:treehouse/pages/category_pages/vending_cooking.dart';

// Placeholder for CategoryModel if it's not defined elsewhere
class CategoryModel {
  final String name;
  final String iconPath;
  final Color boxColor;
  final Function(BuildContext) onTap;

  CategoryModel({
    required this.name,
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
        name: "Haircut & Styling",
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
        name: "Makeup & Beauty",
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
