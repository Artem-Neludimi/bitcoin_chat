import 'package:bitcoin_chat/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CurrencyAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(Provider.of<CurrencyProvider>(context, listen: false)
          .currentCurrency),
      centerTitle: true,
    );
  }
}
