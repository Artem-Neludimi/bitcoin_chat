import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String currentLocale;
  final Map<String, String> locales = {
    'ru': 'Русский',
    'en': 'English',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentLocale = context.locale.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        ListTile(
            leading: const Icon(Icons.language),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                iconSize: 0,
                value: locales[currentLocale],
                items: locales.values
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  context.setLocale(
                    Locale(
                      locales.map((k, v) => MapEntry(v, k))[value!]!,
                    ),
                  );
                },
              ),
            ))
      ],
    );
  }
}
