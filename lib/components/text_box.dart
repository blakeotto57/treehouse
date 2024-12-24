import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      width: width, // Set width dynamically
      height: height, // Set height dynamically
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: padding ?? const EdgeInsets.only(left: 15, bottom: 15), // Default padding
      margin: margin ?? const EdgeInsets.only(left: 20, right: 20, top: 20), // Default margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: textColor,
                ),
                ),
              // Edit button
              IconButton(
                onPressed: onPressed,
                icon: const Icon(Icons.edit),
                color: textColor,
              ),
            ],
          ),
          // Text
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
