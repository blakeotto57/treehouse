import 'package:flutter/material.dart';
import 'package:treehouse/models/category_forurm.dart';

class FoodSellersPage extends StatelessWidget {
  const FoodSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Food",
      icon: Icons.food_bank,
      appBarColor: Color.fromRGBO(90, 124, 239, 1),
      forumIconColor: Color.fromRGBO(90, 124, 239, 1),
      firestoreCollection: "food_posts",
    );
  }
}