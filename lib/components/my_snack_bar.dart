import 'package:flutter/material.dart';

class MySnackBar {
  static void show(
    BuildContext context, {
    required Widget content,
    Color backgroundColor = Colors.blue,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 10,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        content: content,
      ),
    );
  }
}
