import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({Key? key, required this.onChanged}) : super(key: key);
  final void Function(String) onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void showFullScreenKeyboard(
      BuildContext context, TextEditingController txtCtrl) {
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
    );
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
