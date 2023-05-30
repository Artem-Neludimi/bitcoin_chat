class Message {
  String? nickname;
  String? text;
  String? uid;
  String? time;
  int? color;
  bool isSend;
  bool isDeleted;
  bool isWhenUserJoin;

  Message({
    required this.nickname,
    required this.text,
    required this.uid,
    required this.time,
    required this.color,
    this.isSend = true,
    this.isDeleted = false,
    this.isWhenUserJoin = false,
  });

  factory Message.fromJson(Map json) {
    return Message(
      nickname: json['nickname'].toString(),
      text: json['text'].toString(),
      uid: json['uid'].toString(),
      time: json['time'].toString(),
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'text': text,
        'uid': uid,
        'time': time,
        'color': color,
      };
}
