part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class NicknameState extends HomeState {
  final Widget? title;

  NicknameState({this.title});
}

class SettingsEvent extends HomeEvent {}

class ColorPickerState extends HomeState {}

class AuthState extends HomeState {
  final bool isAuth;

  AuthState(this.isAuth);
}

class WriteMessageState extends HomeState {}

class MessagesState extends HomeState {}

class NoInternetConnectionState extends HomeState {}

class ErrorState extends HomeState {}
