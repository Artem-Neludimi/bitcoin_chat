import 'package:flutter/material.dart';

class CurrencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double statusBarHeight;

  const CurrencyAppBar(this.statusBarHeight, {super.key});

  @override
  Size get preferredSize => Size.fromHeight(statusBarHeight);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: statusBarHeight,
    );
  }
}
