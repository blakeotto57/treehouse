import 'package:flutter/material.dart';



//folder that distingushes the categories from one another
class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
    });

    static List<CategoryModel> getCategories() {
      List<CategoryModel> categories = [];

    //Personal Care box
    categories.add(
      CategoryModel(name: "Personal Care", iconPath: "assets/icons/haircut-icon.svg", boxColor: Color.fromRGBO(75, 57, 239, 1),),);

    //Vending & Cooking box
    categories.add(
      CategoryModel(name: "Vending & Cooking", iconPath: "assets/icons/vending-icon.svg", boxColor: Color.fromRGBO(215, 57, 239, 1),),);

    //Photography box
    categories.add(
      CategoryModel(name: "Photography & Media", iconPath: "assets/icons/camera-icon.svg", boxColor: Color.fromRGBO(57, 210, 192, 1),),);

    //Academic assitance box
    categories.add(
      CategoryModel(name: "Academic Assistance", iconPath: "assets/icons/school-icon.svg", boxColor: Color.fromRGBO(238, 138, 96, 1),),);

    //Technical Services box
    categories.add(
      CategoryModel(name: "Technical Services", iconPath: "assets/icons/computer-icon.svg", boxColor: Color.fromRGBO(255, 64, 129, 1),),);

     //Errands & Moving Services box
    categories.add(
      CategoryModel(name: "Errands & Moving", iconPath: "assets/icons/box-icon.svg", boxColor: Color.fromRGBO(255, 193, 7, 1),),);

    //Pet Care box
    categories.add(
      CategoryModel(name: "Pet Care", iconPath: "assets/icons/dog-icon.svg", boxColor: Color.fromRGBO(76, 175, 80, 1),),);

    //Cleaning box
    categories.add(
      CategoryModel(name: "Cleaning", iconPath: "assets/icons/clean-icon.svg", boxColor: Color.fromRGBO(156, 39, 176, 1)
      )
    );

    return categories;
    }
}