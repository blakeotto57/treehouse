import 'package:flutter/material.dart';



//folder that distingushes the categories from one another
class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;
  Function onTap;

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
        boxColor: Color.fromRGBO(75, 57, 239, 1),
        onTap: () {  //does something is pressed

          print("Personal care clicked");
            }
          ),
        );



    //Vending & Cooking box
    categories.add(
      CategoryModel(
        name: "Vending & Cooking", 
        iconPath: "assets/icons/vending-icon.svg", 
        boxColor: Color.fromRGBO(215, 57, 239, 1),
        onTap: () {  //does something is pressed

          print("Personal care clicked");
            }
          ),
        );



    //Photography box
    categories.add(
      CategoryModel(
        name: "Photography", 
        iconPath: "assets/icons/camera-icon.svg", 
        boxColor: Color.fromRGBO(57, 210, 192, 1),
        onTap: () {  //does something is pressed

          print("Personal care clicked");
            }
          ),
        );



    //Academic assitance box
    categories.add(
      CategoryModel(
        name: "Academic Assistance", 
        iconPath: "assets/icons/school-icon.svg", 
        boxColor: Color.fromRGBO(238, 138, 96, 1),
        onTap: () {  //does something is pressed

          print("Personal care clicked");
            }
          ),
        );




    //Technical Services box
    categories.add(
      CategoryModel(
        name: "Technical Services", 
        iconPath: "assets/icons/computer-icon.svg", 
        boxColor: Color.fromRGBO(255, 64, 129, 1),
        onTap: () {  //does something is pressed

          print("Personal care clicked");
            }
          ),
        );




     //Errands & Moving Services box
    categories.add(
      CategoryModel(
        name: "Errands & Moving", 
        iconPath: "assets/icons/box-icon.svg", 
        boxColor: Color.fromRGBO(255, 193, 7, 1),
        onTap: () {  //does something is pressed

          print("Personal care clicked");
            }
          ),
        );



    return categories;
    }
}