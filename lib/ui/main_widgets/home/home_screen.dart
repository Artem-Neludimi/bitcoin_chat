import 'package:bitcoin_chat/ui/helper_widgets/no_internet_conection_dialog.dart';
import 'package:bitcoin_chat/ui/helper_widgets/setting_dialog.dart';
import 'package:bitcoin_chat/ui/main_widgets/chart/chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/get_it.dart';
import '../../../models/user.dart';
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

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final _user = getIt<User>();
  final _bloc = HomeBloc();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  var _isAuth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController.addListener(() {
      if (_textController.text.trim().isNotEmpty || _textController.text.trim().isEmpty) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _bloc.add(FetchMessagesEvent());
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
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
          if (state is SettingsState) {
            showDialog(
              context: context,
              builder: (context) => const SettingsDialog(),
            );
          }
          if (state is ColorPickerState) {
            showDialog(context: context, builder: (context) => const ColorPickerDialog())
                .whenComplete(() => setState(() {}));
          }
          if (state is MessagesState) {}
          if (state is WriteMessageState) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
            );
          }
          if (state is NoInternetConnectionState) {
            showDialog(
              context: context,
              builder: (context) => const NoInternetConnectionDialog(),
            );
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('error').tr()));
          }
        },
        builder: (context, state) {
          final List<Message> messages = context.read<HomeBloc>().messages.toList();

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
            body: SafeArea(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Chart(statusBarHeight: statusBarHeight),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          onPressed: () {
                            _bloc.add(SettingsEvent());
                          },
                          icon: const Icon(
                            Icons.settings,
                          ),
                        ),
                      )
                    ],
                  ),
                  if (isPortrait) ...[
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: messages.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 3),
                        itemBuilder: (context, index) {
                          index = (index - messages.length).abs() - 1;
                          final primaryColor = theme.colorScheme.primary;
                          const offset = 0.1;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                children: [
                                  if (!messages[index].isSend) const Icon(Icons.error),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${messages[index].nickname}',
                                          style: TextStyle(
                                            color: Color(messages[index].color!),
                                            fontSize: theme.textTheme.titleSmall!.fontSize! - offset,
                                            shadows: [
                                              Shadow(
                                                  // bottomLeft
                                                  offset: const Offset(-offset, -offset),
                                                  color: primaryColor),
                                              Shadow(
                                                  // bottomRight
                                                  offset: const Offset(offset, -offset),
                                                  color: primaryColor),
                                              Shadow(
                                                  // topRight
                                                  offset: const Offset(offset, offset),
                                                  color: primaryColor),
                                              Shadow(
                                                  // topLeft
                                                  offset: const Offset(-offset, offset),
                                                  color: primaryColor),
                                            ],
                                          ),
                                        ),
                                        TextSpan(
                                          style: theme.textTheme.titleSmall,
                                          text: ': ${messages[index].text!.replaceAll(RegExp('\\s+'), ' ')}',
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
                                    'welcome',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ).tr(),
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
                              title: const Text('nicknameSet').tr(),
                            ),
                          );
                        }
                      },
                      child: AbsorbPointer(
                        absorbing: !_isAuth,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                    hintText: 'sendMessage'.tr(),
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
                                  transitionBuilder: (child, anim) => RotationTransition(
                                    turns: child.key == const ValueKey('icon1')
                                        ? Tween<double>(begin: 0, end: 0).animate(anim)
                                        : Tween<double>(begin: 0, end: 0).animate(anim),
                                    child: ScaleTransition(scale: anim, child: child),
                                  ),
                                  child: text == ''
                                      ? Icon(
                                          Icons.color_lens,
                                          key: const ValueKey('icon1'),
                                          color: Color(_user.color ?? 0xFFFFFFFF),
                                        )
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
            ),
          );
        },
      ),
    );
  }
}
