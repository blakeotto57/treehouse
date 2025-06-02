import 'package:flutter/material.dart';
import 'package:treehouse/models/category_forurm.dart';

class TechnicalServicesSellersPage extends StatelessWidget {
  const TechnicalServicesSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Technical",
      icon: Icons.computer,
      appBarColor: Color.fromRGBO(179, 45, 90, 1),
      forumIconColor: Color.fromRGBO(179, 45, 90, 1),
      firestoreCollection: "technical_posts",
    );
  }
}