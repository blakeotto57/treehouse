import 'package:flutter/material.dart';
import 'package:treehouse/models/category_forurm.dart';

class PersonalCarePage extends StatelessWidget {
  const PersonalCarePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Personal Care",
      icon: Icons.person,
      appBarColor: Color.fromRGBO(125, 90, 170, 1),
      forumIconColor: Color.fromRGBO(125, 90, 170, 1),
      firestoreCollection: "personal_care_posts",
    );
  }
}