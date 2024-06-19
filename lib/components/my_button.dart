import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const MyButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );

    final mergedStyle = defaultStyle.merge(style);

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mergedStyle,
        child: child,
      ),
    );
  }
}
