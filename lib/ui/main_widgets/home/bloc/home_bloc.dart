import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bitcoin_chat/services/api/chat_repository.dart';
import 'package:bitcoin_chat/services/models/message.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../models/user.dart';
import '../../../../services/get_it.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<InitialEvent>(_onInitial);
    on<NicknameEvent>(_onNickname);
    on<SettingsEvent>(_onSettings);
    on<ColorPickerEvent>(_onColorPicker);
    on<AuthEvent>(_onAuth);
    on<StreamInternetConnectionEvent>(_onStreamInternetConnection);
    on<StreamMessageEvent>(_onStreamMessage);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<WriteMessageEvent>(_onWriteMessage);
    on<ErrorEvent>(_onError);
    _init();
  }
  final ChatRepository _chatRepository = ChatRepository();
  final User _user = getIt<User>();
  var _isFirstTime = true;

  var messages = <Message>{};

  _init() {
    add(StreamInternetConnectionEvent());
    add(StreamMessageEvent());
  }

  _onNickname(NicknameEvent event, Emitter<HomeState> emit) {
    emit(NicknameState(title: event.title));
  }

  _onSettings(SettingsEvent event, Emitter<HomeState> emit) {
    emit(SettingsState());
  }

  _onColorPicker(ColorPickerEvent event, Emitter<HomeState> emit) {
    emit(ColorPickerState());
  }

  _onAuth(AuthEvent event, Emitter<HomeState> emit) {
    emit(AuthState(_user.isAuth));
  }

  _onInitial(InitialEvent event, Emitter<HomeState> emit) {
    emit(HomeInitial());
  }

  _onStreamMessage(StreamMessageEvent event, Emitter<HomeState> emit) async {
    try {
      await emit.onEach(_chatRepository.messagesStream(), onData: ((snapshot) {
        final last = Message.fromJson(snapshot.docs.last.data() as Map);
        messages.addAll(
          snapshot.docs.map(
            (e) => Message.fromJson(
              e.data() as Map,
            ),
          ),
        );
        if (_isFirstTime) {
          _isFirstTime = false;
          messages.last.isWhenUserJoin = true;
        }
        emit(MessagesState());
        if (last.uid == _user.uid) {
          emit(WriteMessageState());
        }
      }));
    } catch (e) {
      emit(ErrorState());
      throw Exception(e);
    }
  }

  _onFetchMessages(FetchMessagesEvent event, Emitter<HomeState> emit) async {
    _chatRepository.messagesStream().listen((event) {
      final data = event.docs.map((e) => Message.fromJson(e.data() as Map));
      messages.addAll(data);
    });
    emit(MessagesState());
  }

  _onStreamInternetConnection(
    StreamInternetConnectionEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (await InternetConnectionChecker().hasConnection) {
      add(NicknameEvent());
    } else {
      emit(NoInternetConnectionState());
    }
    await emit.onEach(
      Connectivity().onConnectivityChanged,
      onData: (data) async {
        if (!await InternetConnectionChecker().hasConnection) {
          emit(NoInternetConnectionState());
        }
      },
    );
  }

  _onWriteMessage(WriteMessageEvent event, Emitter<HomeState> emit) async {
    try {
      await _chatRepository.writeMessage(event.message);
      await Future.delayed(const Duration(milliseconds: 100), () {
        if (!messages.contains(event.message)) {
          messages.add(event.message..isSend = false);
          emit(WriteMessageState());
        }
      });
    } catch (e) {
      emit(ErrorState());
      throw Exception(e);
    }
  }

  _onError(ErrorEvent event, Emitter<HomeState> emit) {
    emit(ErrorState());
  }
}
