import 'package:flutter/material.dart';
import 'package:treehouse/pages/category_forurm.dart';

class CleaningSellersPage extends StatelessWidget {
  const CleaningSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Cleaning",
      icon: Icons.cleaning_services,
      appBarColor: Color.fromRGBO(191, 84, 210, 1),
      forumIconColor: Color.fromRGBO(191, 84, 210, 1),
      firestoreCollection: "cleaning_posts",
    );
  }
}