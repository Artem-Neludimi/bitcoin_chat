part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class InitialEvent extends HomeEvent {}

class NicknameEvent extends HomeEvent {
  final Widget? title;

  NicknameEvent({this.title});
}

class SettingsState extends HomeState {}

class ColorPickerEvent extends HomeEvent {}

class AuthEvent extends HomeEvent {}

class StreamMessageEvent extends HomeEvent {}

class FetchMessagesEvent extends HomeEvent {}

class StreamInternetConnectionEvent extends HomeEvent {}

class WriteMessageEvent extends HomeEvent {
  final Message message;

  WriteMessageEvent({required this.message});
}

class ErrorEvent extends HomeEvent {}
