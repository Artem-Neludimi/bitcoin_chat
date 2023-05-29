part of 'nickname_dialog_bloc.dart';

@immutable
abstract class NicknameDialogEvent {}

class AuthEvent extends NicknameDialogEvent {
  final String nickname;

  AuthEvent(this.nickname);
}
