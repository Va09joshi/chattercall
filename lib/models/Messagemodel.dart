import 'package:chat_application/models/Usermodel.dart';

class MessageModel{
  String? sender;
  String? message;
  bool? seen;
  DateTime? Createdon;

  MessageModel({this.sender,this.message,this.Createdon,this.seen});

  MessageModel.frommap(Map<String,dynamic> map){
    sender : map['sender'];
    message : map['message'];
    seen : map['seen'];
    Createdon : map['Createdon'];
  }

  Map<String,dynamic> tomap(){
    return{
      'sender' : sender,
      ' message' : message,
      'seen' : seen,
      'Createdon' : Createdon
    };
  }
}