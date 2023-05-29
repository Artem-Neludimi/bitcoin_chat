part of 'nickname_dialog_bloc.dart';

@immutable
abstract class NicknameDialogState {}

class NicknameDialogInitial extends NicknameDialogState {}

class AuthState extends NicknameDialogState {}

class LoadingState extends NicknameDialogState {}

class ErrorState extends NicknameDialogState{}