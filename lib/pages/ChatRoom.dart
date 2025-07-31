import 'dart:developer';

import 'package:chat_application/models/ChatroomModel.dart';
import 'package:chat_application/models/Messagemodel.dart';
import 'package:chat_application/models/Usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class Chatroom extends StatefulWidget {
  final Usermodel targetuser;
  final ChatRoomModel chatroom;
  final User currentuser;

  const Chatroom({
    Key? key,
    required this.targetuser,
    required this.chatroom,
    required this.currentuser,
  }) : super(key: key);

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final uuid = Uuid();

  Future<void> _sendMessage() async {
    final msg = _messageCtrl.text.trim();
    _messageCtrl.clear();
    if (msg.isEmpty) return;

    final newMessage = MessageModel(
      messageid: uuid.v1(),
      sender: widget.currentuser.uid,
      createdon: DateTime.now(),
      message: msg,
      seen: false,
    );

    final chatRef = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatroom.chatroomid);

    final roomSnap = await chatRef.get();
    if (!roomSnap.exists) {
      await chatRef.set({
        'chatroomid': widget.chatroom.chatroomid,
        'participants': {
          widget.currentuser.uid: true,
          widget.targetuser.uid: true,
        },
        'lastmessage': '',
        'updatedon': DateTime.now(),
      });
    }

    await chatRef
        .collection('messages')
        .doc(newMessage.messageid)
        .set(newMessage.toMap());

    await chatRef.update({
      'lastmessage': newMessage.message,
      'updatedon': DateTime.now(),
    });

    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    widget.chatroom.lastmessage = msg;
    FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .set(widget.chatroom.toMap());

    log('Message sent: ${newMessage.message}');
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final time = TimeOfDay.fromDateTime(dt);
    final now = DateTime.now();
    final date = dt.day == now.day &&
        dt.month == now.month &&
        dt.year == now.year
        ? 'Today'
        : '${dt.day}/${dt.month}/${dt.year}';
    return '$date • ${time.format(context)}';
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff243949),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.arrow_left_sharp,color: Colors.white,size: 40,)),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(widget.targetuser.profilepic ?? ''),
                ),
                const SizedBox(width: 15),
                Text(widget.targetuser.fullname ?? ''),
              ],
            ),

            Icon(FontAwesomeIcons.ellipsisVertical,color: Colors.white,)

          ],
        ),
        titleTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: .6,
        ),
        centerTitle: true,
        elevation: 6,
        toolbarHeight: 60,
        shadowColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chatrooms')
                    .doc(widget.chatroom.chatroomid)
                    .collection('messages')
                    .orderBy('createdon', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.active) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong 🚧'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Say hi 👋'));
                  }

                  final docs = snapshot.data!.docs;

                  // Mark received messages as seen
                  for (var doc in docs) {
                    final msg = MessageModel.frommap(
                        doc.data() as Map<String, dynamic>);
                    if (msg.sender == widget.targetuser.uid && msg.seen!) {
                      FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(widget.chatroom.chatroomid)
                          .collection('messages')
                          .doc(msg.messageid)
                          .update({'seen': true});
                    }
                  }

                  return ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final msg = MessageModel.frommap(
                          docs[index].data() as Map<String, dynamic>);
                      final isMe = msg.sender == widget.currentuser.uid;

                      return Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.teal.shade200
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.message ?? '',
                                style: GoogleFonts.manrope(fontSize: 15,fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(msg.createdon),
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              width: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(color: Colors.black),
                  BoxShadow(color: Colors.black)
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Send a message...',
                        hintStyle: GoogleFonts.inter(fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_sharp, color: Colors.green.shade700),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
