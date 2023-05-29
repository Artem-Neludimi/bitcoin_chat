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

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = NicknameDialogBloc(getIt<ChatRepository>(), getIt<User>());
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
            title: widget.title,
            content: TextField(
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
