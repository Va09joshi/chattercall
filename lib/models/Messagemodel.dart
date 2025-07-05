import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageid;
  String? sender;
  String? message;
  bool? seen;
  DateTime? createdon;

  MessageModel({
    this.messageid,
    this.sender,
    this.message,
    this.seen,
    this.createdon,
  });

  // Convert Firestore Map to MessageModel object
  factory MessageModel.frommap(Map<String, dynamic> map) {
    return MessageModel(
      messageid: map["messageid"],
      sender: map["sender"],
      message: map["message"],
      seen: map["seen"],
      createdon: map["createdon"] != null
          ? (map["createdon"] as Timestamp).toDate()
          : null,
    );
  }

  // Convert MessageModel object to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "message": message,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
