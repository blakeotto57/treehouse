import 'package:flutter/material.dart';
import 'package:treehouse/theme/theme.dart';

class MyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Color? color;
  final bool isOutlined;

  const MyButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.color,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = color ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen);
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: buttonColor, width: 2),
          foregroundColor: buttonColor,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    final effectiveColor = onTap == null 
        ? buttonColor.withOpacity(0.6) 
        : buttonColor;
    
    return Material(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          width: double.infinity,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: onTap == null ? null : [
              BoxShadow(
                color: buttonColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(onTap == null ? 0.7 : 1.0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}