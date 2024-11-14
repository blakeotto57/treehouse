import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:treehouse/models/personal_care_options.dart';

class PersonalCarePage extends StatelessWidget {
  const PersonalCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Personal Care Page'),
      ),
      body: PersonalCareContent(
        categories: PersonalCareOptions.getpersonalcareoptions(),
        // Add CategoryModel objects here as needed
      ),
    );
  }
}

class PersonalCareContent extends StatelessWidget {
  final List<CategoryModel> categories;

  PersonalCareContent({required this.categories});


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10), // Space between AppBar and content
          SizedBox(height: 10),
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align categories title to the left
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Personal Care Sellers",
                    style: TextStyle(
                      color: Colors.black, // Color of categories text
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                  ),
                ),
                SizedBox(height: 1), // Space between categories label and list
                
                
                Container(
                  height: 361, // Height of category list view
                  color: Colors.white, // Background color of category list
                  child: ListView.separated(
                    itemCount: categories.length,
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(10),
                    separatorBuilder: (context, index) => SizedBox(height: 25), // Space between categories
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => categories[index].onTap(context),
                        child: Container(
                          height: 100, // Height of each category box
                          decoration: BoxDecoration(
                            color: categories[index].boxColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2), // Creates shadow color
                                spreadRadius: 2, // How big the shadow is
                                blurRadius: 2,
                                offset: Offset(3, 3), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: categories[index].text, // This will now correctly render text
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  categories[index].iconPath,
                                  width: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
