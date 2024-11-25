import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //section name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //section name
              Text(sectionName),

              //edit button
              IconButton(
                onPressed: (){}, 
                icon: Icon(Icons.edit),
              ),
            ],
          ),

          //text
          Text(text),

          IconButton(
            onPressed: (){}, 
            icon: Icon(
              Icons.edit,
            ),
          ),
        ],
      ),
    );
  }
}