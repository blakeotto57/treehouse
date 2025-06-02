import 'package:flutter/material.dart';
import 'package:treehouse/models/category_forurm.dart';

class PetCareSellersPage extends StatelessWidget {
  const PetCareSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Pet Care",
      icon: Icons.pets,
      appBarColor: Color.fromRGBO(76, 175, 80, 1),
      forumIconColor: Color.fromRGBO(76, 175, 80, 1),
      firestoreCollection: "pet_care_posts",
    );
  }
}