import 'package:flutter/material.dart';
import 'package:treehouse/pages/category_forurm.dart';

class AcademicsSellersPage extends StatelessWidget {
  const AcademicsSellersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CategoryForumPage(
      title: "Academics",
      icon: Icons.school,
      appBarColor: Color.fromRGBO(238, 138, 96, 1),
      forumIconColor: Color.fromRGBO(238, 138, 96, 1),
      firestoreCollection: "academic_posts",
    );
  }
}