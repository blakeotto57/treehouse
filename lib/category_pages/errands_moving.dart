import 'package:flutter/material.dart';
import 'package:treehouse/pages/category_forurm.dart';

class ErrandsMovingSellersPage extends StatelessWidget {
  const ErrandsMovingSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Errands & Moving",
      icon: Icons.local_shipping,
      appBarColor: Color.fromRGBO(255, 193, 7, 1),
      forumIconColor: Color.fromRGBO(255, 193, 7, 1),
      firestoreCollection: "errands_moving_posts",
    );
  }
}