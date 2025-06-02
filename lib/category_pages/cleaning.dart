import 'package:flutter/material.dart';
import 'package:treehouse/models/category_forurm.dart';

class CleaningSellersPage extends StatelessWidget {
  const CleaningSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Cleaning",
      icon: Icons.cleaning_services,
      appBarColor: Color.fromRGBO(109, 27, 123, 1),
      forumIconColor: Color.fromRGBO(109, 27, 123, 1),
      firestoreCollection: "cleaning_posts",
    );
  }
}