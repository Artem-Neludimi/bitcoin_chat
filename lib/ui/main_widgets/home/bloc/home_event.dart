part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class InitialEvent extends HomeEvent {}

class NicknameEvent extends HomeEvent {
  final Widget? title;

  NicknameEvent({this.title});
}

class AuthEvent extends HomeEvent {}

class StreamMessageEvent extends HomeEvent {}

class WriteMessageEvent extends HomeEvent {
  final Message message;

  WriteMessageEvent({required this.message});
}

class ErrorEvent extends HomeEvent {}
