import 'dart:convert';

import 'package:bitcoin_chat/ui/main_widgets/chart/chart.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../services/api/chat_repository.dart';
import '../../../../services/get_it.dart';
import '../../../models/user.dart';
import '../../../services/api/currency_repository.dart';
import '../../../services/models/candle_ticker_model.dart';
import '../../../services/models/message.dart';
import '../../helper_widgets/color_picker_dialog.dart';
import '../../helper_widgets/currency_app_bar.dart';
import '../nickname_dialog/nickname_dialog.dart';
import 'bloc/home_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _user = getIt<User>();
  final _bloc = HomeBloc(ChatRepository(), getIt<User>());
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  var _isAuth = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_textController.text.trim().isNotEmpty ||
          _textController.text.trim().isEmpty) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final theme = Theme.of(context);
    final text = _textController.text.trim();

    return BlocProvider(
      create: (context) => _bloc,
      child: BlocConsumer<HomeBloc, HomeState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is NicknameState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => NicknameDialog(title: state.title),
            ).then((value) {
              _bloc.add(AuthEvent());
            });
          }
          if (state is ColorPickerState) {
            showDialog(
                context: context,
                builder: (context) => const ColorPickerDialog());
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Error')));
          }
          if (state is MessagesState) {}
          if (state is WriteMessageState) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
            );
          }
        },
        builder: (context, state) {
          final List<Message> messages = context.read<HomeBloc>().messages;

          if (state is HomeInitial) {
            return Scaffold(
              appBar: CurrencyAppBar(statusBarHeight),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is AuthState) {
            _isAuth = state.isAuth;
          }
          return Scaffold(
            resizeToAvoidBottomInset: _isAuth,
            appBar: CurrencyAppBar(statusBarHeight),
            body: Column(
              children: [
                Chart(statusBarHeight: statusBarHeight),
                if (isPortrait) ...[
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: messages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 3),
                      itemBuilder: (context, index) {
                        index = (index - messages.length).abs() - 1;
                        final primaryColor = theme.colorScheme.primary;
                        const offset = 0.1;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                RichText(
                                  textDirection: TextDirection.ltr,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${messages[index].nickname}',
                                        style: TextStyle(
                                          color: Color(messages[index].color!),
                                          fontSize: theme.textTheme.titleSmall!
                                                  .fontSize! -
                                              offset,
                                          shadows: [
                                            Shadow(
                                                // bottomLeft
                                                offset: const Offset(
                                                    -offset, -offset),
                                                color: primaryColor),
                                            Shadow(
                                                // bottomRight
                                                offset: const Offset(
                                                    offset, -offset),
                                                color: primaryColor),
                                            Shadow(
                                                // topRight
                                                offset: const Offset(
                                                    offset, offset),
                                                color: primaryColor),
                                            Shadow(
                                                // topLeft
                                                offset: const Offset(
                                                    -offset, offset),
                                                color: primaryColor),
                                          ],
                                        ),
                                      ),
                                      TextSpan(
                                        style: theme.textTheme.titleSmall,
                                        text:
                                            ': ${messages[index].text!.replaceAll(RegExp('\\s+'), ' ')}',
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            if (messages[index].isWhenUserJoin)
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 5),
                                child: const Text(
                                  'Welcome to the chat!',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!_isAuth) {
                        _bloc.add(
                          NicknameEvent(
                            title: const Text('Set a nickname first'),
                          ),
                        );
                      }
                    },
                    child: AbsorbPointer(
                      absorbing: !_isAuth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 20),
                                  hintText: 'Send a message',
                                  isDense: true,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                transitionBuilder: (child, anim) =>
                                    RotationTransition(
                                  turns: child.key == const ValueKey('icon1')
                                      ? Tween<double>(begin: 0, end: 0)
                                          .animate(anim)
                                      : Tween<double>(begin: 0, end: 0)
                                          .animate(anim),
                                  child: ScaleTransition(
                                      scale: anim, child: child),
                                ),
                                child: text == ''
                                    ? const Icon(Icons.color_lens,
                                        key: ValueKey('icon1'))
                                    : const Icon(
                                        Icons.send,
                                        key: ValueKey('icon2'),
                                      ),
                              ),
                              onPressed: () {
                                if (text.isNotEmpty) {
                                  _bloc.add(
                                    WriteMessageEvent(
                                      message: Message(
                                        nickname: _user.nickname,
                                        text: text,
                                        uid: _user.uid,
                                        time: DateTime.now().toIso8601String(),
                                        color: _user.color,
                                      ),
                                    ),
                                  );
                                  _textController.clear();
                                } else {
                                  _bloc.add(ColorPickerEvent());
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
