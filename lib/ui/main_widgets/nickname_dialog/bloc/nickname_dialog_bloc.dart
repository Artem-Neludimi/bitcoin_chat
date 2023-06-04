import 'dart:math';

import 'package:bitcoin_chat/services/api/chat_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/user.dart';

part 'nickname_dialog_event.dart';
part 'nickname_dialog_state.dart';

class NicknameDialogBloc
    extends Bloc<NicknameDialogEvent, NicknameDialogState> {
  final ChatRepository _firebaseApi;
  final User _user;
  NicknameDialogBloc(this._firebaseApi, this._user)
      : super(NicknameDialogInitial()) {
    on<AuthEvent>(_onAuth);
  }
  _onAuth(AuthEvent event, Emitter<NicknameDialogState> emit) async {
    emit(LoadingState());
    await _firebaseApi.auth();
    if (_firebaseApi.isAuth()) {
      _user.setNickname(event.nickname);
      _user.setUid(_firebaseApi.userUid());
      _user.setColor(Random().nextInt(0xffffffff));
      emit(AuthState());
    } else {
      emit(ErrorState());
    }
  }
}
