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
  final String name;
  final String iconPath;
  final Color boxColor;
  final Function (BuildContext) onTap;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
    required this.onTap,
    });

    static List<CategoryModel> getCategories() {
      List<CategoryModel> categories = [];



    //Personal Care box
    categories.add(
      CategoryModel(
        name: "Personal Care", 
        iconPath: "assets/icons/haircut-icon.svg", 
        boxColor: Color.fromRGBO(178, 129, 243, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PersonalCareSellersPage()),
           );
          }
        ),
      );




    //Food box
    categories.add(
      CategoryModel(
        name: "Food", 
        iconPath: "assets/icons/vending-icon.svg", 
        boxColor: Color.fromRGBO(215, 57, 239, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodSellersPage()),
            );
          }
        ),
      );



    //Photography box
    categories.add(
      CategoryModel(
        name: "Photography", 
        iconPath: "assets/icons/camera-icon.svg", 
        boxColor: Color.fromRGBO(57, 210, 192, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PhotographySellersPage()),
            );
          }
        ),
      );



    //Academics box
    categories.add(
      CategoryModel(
        name: "Academics", 
        iconPath: "assets/icons/school-icon.svg", 
        boxColor: Color.fromRGBO(238, 138, 96, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AcademicsSellersPage()),
            );

          }
        ),
      );



    //Technical Services box
    categories.add(
      CategoryModel(
        name: "Technical", 
        iconPath: "assets/icons/computer-icon.svg", 
        boxColor: Color.fromRGBO(255, 64, 129, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TechnicalServicesSellersPage()),
            );
          }
        ),
      );



     //Errands & Moving Services box
    categories.add(
      CategoryModel(
        name: "Errands & Moving", 
        iconPath: "assets/icons/box-icon.svg", 
        boxColor: Color.fromRGBO(255, 193, 7, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ErrandsMovingSellersPage()),
            );
          }
        ),
      );



    //Pet Care box
    categories.add(
      CategoryModel(
        name: "Pet Care", 
        iconPath: "assets/icons/dog-icon.svg", 
        boxColor: Color.fromRGBO(76, 175, 80, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PetCareSellersPage()),
            );
          }
        ),
      );



    //Cleaning box
    categories.add(
      CategoryModel(
        name: "Cleaning", 
        iconPath: "assets/icons/clean-icon.svg", 
        boxColor: Color.fromRGBO(156, 39, 176, 1),

        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CleaningSellersPage()),
            );
          }
        ),
      );

    return categories;
    }
}