import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user.dart' as self;
import '../models/message.dart';
import '../get_it.dart';

class ChatRepository {
  final _authInstance = FirebaseAuth.instance;
  final _messages = FirebaseFirestore.instance
      .collection('/bitcoin/ufhICYJp3NzYH2Bo79Cj/messages');

  String userUid() {
    return _authInstance.currentUser!.uid;
  }

  bool isAuth() {
    if (_authInstance.currentUser == null) return false;
    return _authInstance.currentUser!.isAnonymous;
  }

  Future<void> auth() async {
    try {
      await _authInstance.signInAnonymously();
      getIt<self.User>().setUid(FirebaseAuth.instance.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          log("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          log("Unknown error.");
      }
    }
  }

  Future<List<Message>> getAllMessages() async {
    final data = await _messages.get();
    return data.docs.map((e) => Message.fromJson(e.data())).toList();
  }

  Stream<QuerySnapshot> messagesStream() {
    return _messages.orderBy('time').snapshots();
  }

  Future<void> writeMessage(Message message) async {
    _messages.doc().set(message.toJson());
  }
}
