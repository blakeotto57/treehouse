import 'package:flutter/material.dart';
import 'package:treehouse/pages/category_forurm.dart';

class PhotographySellersPage extends StatelessWidget {
  const PhotographySellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Photography",
      icon: Icons.camera,
      appBarColor: Color.fromRGBO(40, 147, 134, 1),
      forumIconColor: Color.fromRGBO(40, 147, 134, 1),
      firestoreCollection: "photography_posts",
    );
  }
}