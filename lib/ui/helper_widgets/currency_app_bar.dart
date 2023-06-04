import 'package:bitcoin_chat/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double statusBarHeight;

  CurrencyAppBar(this.statusBarHeight);

  @override
  Size get preferredSize => Size.fromHeight(statusBarHeight);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: statusBarHeight,
    );
  }
}
