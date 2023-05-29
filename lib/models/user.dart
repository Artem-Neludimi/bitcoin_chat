class User {
  String? _nickname;
  String? _uid;
  int? _color;

  String? get nickname => _nickname;
  String? get uid => _uid;
  int? get color => _color;

  bool get isAuth => _nickname != null && _nickname != '';

  void setNickname(String nickname) {
    _nickname = nickname;
  }

  void setUid(String uid) {
    _uid = uid;
  }

  void setColor(int color) {
    _color = color;
  }
}
