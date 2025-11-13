import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final Color? backgroundColor;
  final double borderRadius;
  final TextStyle? textStyle;

  const MyElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.height = 49.0,
    this.backgroundColor,
    this.borderRadius = 50.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: textStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,  // Default text color
              ),
        ),
      ),
    );
  }
}
