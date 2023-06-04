import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/user.dart';
import '../../../services/api/chat_repository.dart';
import '../../../services/get_it.dart';
import 'bloc/nickname_dialog_bloc.dart';

class NicknameDialog extends StatefulWidget {
  final Widget? title;

  const NicknameDialog({super.key, this.title});

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  final textController = TextEditingController();
  bool isKeyboardDialogShown = false;
  late bool isPortrait;

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
    textController.dispose();
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
    final bloc = NicknameDialogBloc(ChatRepository(), getIt<User>());
    Widget buttonContent = const Text('chat').tr();

    return BlocProvider(
      create: (context) => bloc,
      child: BlocConsumer<NicknameDialogBloc, NicknameDialogState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is AuthState) {
            Navigator.of(context).pop();
          }
          if (state is LoadingState) {
            buttonContent = const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('error').tr(),
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return AlertDialog(
            title: Center(child: widget.title),
            content: GestureDetector(
              onTap: () {
                showFullScreenKeyboard(context, textController);
              },
              child: AbsorbPointer(
                absorbing: !isPortrait,
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'nickname'.tr(),
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onSubmitted: (value) {
                    bloc.add(AuthEvent(value.trim()));
                  },
                ),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  child: buttonContent,
                  onPressed: () {
                    bloc.add(AuthEvent(textController.text.trim()));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
