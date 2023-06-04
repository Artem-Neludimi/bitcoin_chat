import 'package:flutter/material.dart';

class CurrencyTextField extends StatefulWidget {
  const CurrencyTextField({Key? key, required this.onChanged})
      : super(key: key);
  final void Function(String) onChanged;

  @override
  State<CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  final controller = TextEditingController();
  late bool isPortrait;
  bool isKeyboardDialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (!isPortrait && !isKeyboardDialogShown) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void showFullScreenKeyboard(
      BuildContext context, TextEditingController txtCtrl) {
    isKeyboardDialogShown = true;
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          body: Row(
            children: [
              const SizedBox(width: 10),
              Flexible(
                flex: 3,
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: widget.onChanged,
                  autofocus: true,
                  controller: txtCtrl,
                ),
              ),
              Flexible(
                child: Center(
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK')),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) => isKeyboardDialogShown = false);
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          showFullScreenKeyboard(context, controller);
        },
        child: AbsorbPointer(
          absorbing: !isPortrait,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(
                Icons.search,
              ),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
