// lib/pages/homepage.dart
import 'package:chat_application/pages/ChatRoom.dart';
import 'package:chat_application/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ChatroomModel.dart';

import '../models/Usermodel.dart';
import '../uidesign/Firebasehelper.dart';

class Homepage extends StatefulWidget {
  final Usermodel? usermodel;
  final User? firebaseuser;

  const Homepage({
    super.key,
    required this.usermodel,
    required this.firebaseuser,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    print("🔥 Logged‑in UID: ${widget.usermodel?.uid}");

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/communication.png", width: 35),
            const SizedBox(width: 10),
            Text("ChatterCall", style: GoogleFonts.getFont("Lato", fontSize: 20)),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xff09203f),
        titleTextStyle: GoogleFonts.getFont(
          "Lato",
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
        toolbarHeight: 90,
        elevation: 10,
        shadowColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // // ───────────────────────────────────────── Header card
              // Center(
              //   child: Card(
              //     elevation: 4,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     child: Container(
              //       width: 400,
              //       height: 200,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(20),
              //         gradient: const LinearGradient(
              //           colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
              //           begin: Alignment.topCenter,
              //           end: Alignment.bottomCenter,
              //         ),
              //       ),
              //       child: Column(
              //         children: [
              //           Expanded(
              //             flex: 12,
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(horizontal: 20),
              //               decoration: const BoxDecoration(
              //                 color: Colors.black45,
              //                 borderRadius:
              //                 BorderRadius.vertical(top: Radius.circular(20)),
              //               ),
              //               child: const Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   CircleAvatar(
              //                     radius: 30,
              //                     backgroundColor: Colors.transparent,
              //                     child: Icon(Icons.person,
              //                         size: 40, color: Colors.white),
              //                   ),
              //                   CircleAvatar(
              //                     radius: 30,
              //                     backgroundColor: Colors.white30,
              //                     child: Icon(Icons.video_camera_front,
              //                         size: 40, color: Colors.white),
              //                   ),
              //                   CircleAvatar(
              //                     radius: 30,
              //                     backgroundColor: Colors.transparent,
              //                     child: Icon(Icons.settings,
              //                         size: 40, color: Colors.white),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           Container(
              //             width: double.infinity,
              //             padding: const EdgeInsets.all(16),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text('Join with peoples and Talk',
              //                     style: GoogleFonts.getFont(
              //                       "Lato",
              //                       fontSize: 18,
              //                       fontWeight: FontWeight.bold,
              //                       color: Colors.white,
              //                     )),
              //                 const SizedBox(height: 3),
              //                 const Text('Connect instantly with others',
              //                     style: TextStyle(
              //                       fontSize: 14,
              //                       color: Colors.white70,
              //                     )),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 11),

              // ───────────────────────────────────────── Chats label
              // Center(
              //   child: Card(
              //     elevation: 4,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     child: Container(
              //       width: 400,
              //       height: 50,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(11),
              //         gradient: const LinearGradient(
              //           colors: [Colors.white30,Colors.white30],
              //           begin: Alignment.topCenter,
              //           end: Alignment.bottomCenter,
              //         ),
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Icon(Icons.chat, color: Colors.black),
              //           const SizedBox(width: 4),
              //           Center(
              //             child: Text("chats",
              //                 style: GoogleFonts.getFont(
              //                   "Lato",
              //                   fontSize: 24,
              //                   fontWeight: FontWeight.bold,
              //                   color: Colors.black,
              //                 )),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              // ───────────────────────────────────────── Chatroom list
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .where("participants.${widget.usermodel?.uid}", isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        final chatroomSnapshot =
                        snapshot.data as QuerySnapshot<Map<String, dynamic>>;
                        print("📡 Chatrooms fetched: ${chatroomSnapshot.docs.length}");

                        return ListView.separated(

                          itemCount: chatroomSnapshot.docs.length,


                          itemBuilder: (context, index) {

                            final chatroomData =
                            chatroomSnapshot.docs[index].data();
                            final chatroom = ChatRoomModel.frommap(chatroomData);

                            final participants = chatroom.participants ?? {};
                            final participantKeys = participants.keys.toList()
                              ..remove(widget.usermodel!.uid);

                            final targetId = participantKeys.isNotEmpty
                                ? participantKeys[0]
                                : null;

                            if (targetId == null) return const SizedBox();
                            print("👥 Chatroom $index participants: $participants");
                            print("❓ TargetId: $targetId");


                            return FutureBuilder(
                              future: FirebaseHelper.getUserModelById(targetId),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.done) {
                                  final targetuser = userSnapshot.data;

                                  // 🛠️ If user data is available, show real user
                                  if (targetuser != null) {
                                    return Card(
                                      elevation: 12,

                                      shadowColor: Colors.black45,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(11),
                                          color: Colors.blueGrey.shade900,
                                        ),

                                        child: ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => Chatroom(
                                                  targetuser: targetuser,
                                                  chatroom: chatroom,
                                                  currentuser: widget.firebaseuser!,
                                                ),
                                              ),
                                            );
                                          },
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: targetuser.profilepic!.isNotEmpty
                                                ? NetworkImage(targetuser.profilepic!)
                                                : null,
                                            child: targetuser.profilepic!.isEmpty
                                                ? const Icon(Icons.person, color: Colors.black)
                                                : null,
                                          ),
                                          title: Text(targetuser.fullname!,style: GoogleFonts.getFont("Lato",color: Colors.white,fontWeight: FontWeight.bold),),
                                          subtitle: Text(chatroom.lastmessage ?? "(no message)",style: TextStyle(color: Colors.green.shade200),),
                                          trailing: Icon(Icons.arrow_forward_ios,color: Colors.white38,size: 14,),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // 👤 Show fallback ListTile even if user not found
                                    return ListTile(

                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.person_outline),
                                      ),
                                      title: Text("Unknown User"),
                                      subtitle: Text(chatroom.lastmessage ?? "(no message)"),
                                      trailing: Text(
                                        targetId.substring(0, 6), // show partial UID
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    );
                                  }
                                } else {
                                  return const SizedBox.shrink(); // or show loading spinner
                                }
                              },
                            );
                          }, separatorBuilder: (BuildContext context, int index) {
                            return Divider(height: 1,thickness: 2,);
                        },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      } else {
                        return const Center(child: Text("No Chats"));
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),

              // ───────────────────────────────────────── Test button

            ],
          ),
        ),
      ),
    );
  }
}
