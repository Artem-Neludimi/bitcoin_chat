import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  String? _nickname;
  String? _uid;
  String? _color;

  String? get nickname => _nickname;
  String? get uid => _uid;
  String? get color => _color;

  bool get isAuth => _nickname != null && _nickname != '';

  void setNickname(String nickname) {
    _nickname = nickname;
  }

  void setUid(String uid) {
    _uid = uid;
  }

  void setColor(String color) {
    _color = color;
  }
}
