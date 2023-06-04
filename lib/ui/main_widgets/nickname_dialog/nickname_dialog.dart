import 'dart:async';

import 'package:bitcoin_chat/services/api/chat_repository.dart';
import 'package:bitcoin_chat/services/get_it.dart';
import 'package:bitcoin_chat/ui/main_widgets/nickname_dialog/bloc/nickname_dialog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/user.dart';

class NicknameDialog extends StatefulWidget {
  final Widget? title;

  const NicknameDialog({super.key, this.title});

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  final textController = TextEditingController();
  late bool isPortrait;

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
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
    final bloc = NicknameDialogBloc(ChatRepository(), getIt<User>());
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Widget buttonContent = const Text('chat');

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
              const SnackBar(
                content: Text('Error'),
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
                    hintText: 'Nickname',
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
