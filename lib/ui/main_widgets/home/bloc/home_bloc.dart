import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bitcoin_chat/services/api/chat_repository.dart';
import 'package:bitcoin_chat/services/models/message.dart';

import '../../../../models/user.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChatRepository _chatRepository;
  final User _user;
  HomeBloc(
    this._chatRepository,
    this._user,
  ) : super(HomeInitial()) {
    on<InitialEvent>(_onInitial);
    on<NicknameEvent>(_onNickname);
    on<SettingsEvent>(_onSettings);
    on<ColorPickerEvent>(_onColorPicker);
    on<AuthEvent>(_onAuth);
    on<StreamMessageEvent>(_onStreamMessage);
    on<WriteMessageEvent>(_onWriteMessage);
    on<ErrorEvent>(_onError);
    _init();
  }
  List<Message> messages = [];

  _init() {
    add(NicknameEvent());
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
        if (messages.isEmpty) {
          messages = snapshot.docs
              .map((e) => Message.fromJson(e.data() as Map))
              .toList();
          messages.last.isWhenUserJoin = true;
          emit(MessagesState());
        } else {
          messages.add(Message.fromJson(snapshot.docs.last.data() as Map));
          emit(MessagesState());
        }
      }));
    } catch (e) {
      emit(ErrorState());
      throw Exception(e);
    }
  }

  _onWriteMessage(WriteMessageEvent event, Emitter<HomeState> emit) {
    try {
      _chatRepository.writeMessage(event.message);
      emit(WriteMessageState());
    } catch (e) {
      emit(ErrorState());
      throw Exception(e);
    }
  }

  _onError(ErrorEvent event, Emitter<HomeState> emit) {
    emit(ErrorState());
  }
}
