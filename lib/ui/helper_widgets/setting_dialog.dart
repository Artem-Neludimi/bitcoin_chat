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
      contentPadding: const EdgeInsets.all(8),
      children: [
        ListTile(
            leading: const Icon(Icons.language),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                iconSize: 0,
                value: locales[currentLocale],
                items: locales.values.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
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
            )),
        ListTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
          onTap: () => showLicensePage(
            context: context,
            applicationIcon: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset('assets/images/app_icon.png', width: 64, height: 64),
            ),
          ),
          leading: const Icon(Icons.description_outlined),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'licenses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ).tr(),
              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
