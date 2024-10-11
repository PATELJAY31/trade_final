import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  CustomButton({required this.text, required this.onPressed, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: color,
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        textStyle: TextStyle(fontSize: 16),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}