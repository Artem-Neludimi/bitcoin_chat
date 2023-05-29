class Message {
  String? nickname;
  String? text;
  String? uid;
  String? time;
  String? color;
  bool isSend = true;

  Message({
    required this.nickname,
    required this.text,
    required this.uid,
    required this.time,
    required this.color,
    this.isSend = true,
  });

  Message.fromJson(Map json) {
    nickname = json['nickname'].toString();
    text = json['text'].toString();
    uid = json['uid'].toString();
    time = json['time'].toString();
    color = json['color'].toString();
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'text': text,
        'uid': uid,
        'time': time,
        'color': color,
      };
}
