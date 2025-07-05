class ChatRoomModel {
  String? chatroomid;
  String? lastmessage;
  Map<String, bool>? participants;
  DateTime? updatedOn;

  ChatRoomModel({
    this.chatroomid,
    this.lastmessage,
    this.participants,
    this.updatedOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'lastmessage': lastmessage,
      'participants': participants,
      'updatedon': updatedOn, // ✅ this must be here
    };
  }

  factory ChatRoomModel.frommap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatroomid: map['chatroomid'],
      lastmessage: map['lastmessage'],
      participants: Map<String, bool>.from(map['participants']),
      updatedOn: map['updatedon']?.toDate(), // ✅ important for DateTime conversion
    );
  }
}
