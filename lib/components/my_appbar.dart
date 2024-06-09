import 'package:flutter/material.dart';
import 'package:jet_palz/theme/light_mode_theme.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final Widget? leading;
  bool automaticallyImplyLeading;

  MyAppBar({
    required this.title,
    this.actions = const [],
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(title), //add some style to it later
      titleTextStyle: const TextStyle(
          color: lightModeTheme.primaryText,
          fontSize: 28,
          fontWeight: FontWeight.w600),

      actions: actions,
      leading: leading,
      centerTitle: true,
    );
  }

  @override
  // TODO: implement preferredSize
  // Size get preferredSize => throw UnimplementedError();
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
