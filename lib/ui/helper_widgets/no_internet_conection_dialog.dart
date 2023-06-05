import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoInternetConnectionDialog extends StatelessWidget {
  const NoInternetConnectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        const Icon(
          Icons.signal_wifi_connected_no_internet_4_outlined,
          size: 300,
        ),
        Center(child: const Text('noInternetConnection').tr())
      ],
    );
  }
}
