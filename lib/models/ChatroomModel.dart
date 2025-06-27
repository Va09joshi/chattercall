class ChatRoomModel{

  String? chatroomid;
  List<String>? participates;


  ChatRoomModel({this.chatroomid,this.participates});

  ChatRoomModel.frommap(Map<String,dynamic> map){
    chatroomid : map['chatroomid'];
    participates : map['participates'];
  }

  Map<String,dynamic> ToMap(){
    return {
      "chatroomid" : chatroomid,
      "participates" : participates
    };
  }
}
