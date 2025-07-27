import 'dart:developer';

import 'package:chat_application/models/ChatroomModel.dart';
import 'package:chat_application/pages/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/Usermodel.dart';

final uuid = Uuid();

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.currentUser}) : super(key: key);

  final User currentUser;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getchatroommodel(Usermodel targetuser) async {
    final firestore = FirebaseFirestore.instance;
    final currentUid = widget.currentUser.uid;

    ChatRoomModel? chatroom;

    // 1. Check if chatroom already exists with both participants
    final query = await firestore
        .collection("chatrooms")
        .where("participants.$currentUid", isEqualTo: true)
        .where("participants.${targetuser.uid}", isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // ✅ Reuse existing chatroom
      log("✅ Chatroom exists");
      final data = query.docs.first.data() as Map<String, dynamic>;
      chatroom = ChatRoomModel.frommap(data);
    } else {
      // 🆕 Create new chatroom
      final String newId = uuid.v1();
      final newChatRoom = ChatRoomModel(
        chatroomid: newId,
        lastmessage: "",
        participants: {
          currentUid!: true,
          targetuser.uid!: true,
        },
        updatedOn: DateTime.now(),
      );

      await firestore.collection("chatrooms").doc(newId).set(newChatRoom.toMap());
      chatroom = newChatRoom;

      log("🆕 New chatroom created: $newId");
    }

    return chatroom;
  }

  String _query = '';

  void _commitSearch() {
    setState(() => _query = searchController.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Search user",style: GoogleFonts.getFont("Lato",fontSize: 25),),

            SizedBox(width:10,),
            Image.asset("assets/images/communication.png",width: 30,),

          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color(0xff09203f),
        titleTextStyle: GoogleFonts.getFont(
          "Lato",
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
        toolbarHeight: 60,
        elevation: 10,
        shadowColor: Colors.black87,
      ),

      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // // ───────────────────────────────────────── Header card
                Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: 400,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(Icons.person,
                                        size: 40, color: Colors.white),
                                  ),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white30,
                                    child: Icon(Icons.video_camera_front,
                                        size: 40, color: Colors.white),
                                  ),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(Icons.settings,
                                        size: 40, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Join with peoples and Talk',
                                    style: GoogleFonts.getFont(
                                      "Lato",
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                                const SizedBox(height: 3),
                                const Text('Connect instantly with others',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // const SizedBox(height: 11),
                SizedBox(height: 20),

                TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    label: Text("Email or name"),
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: "Enter email or name...",
                    hintStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onSubmitted: (_) => _commitSearch(),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 160,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9


                    ),
                    color: Colors.black26,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white30,
                        spreadRadius: 0.1,

                      ),
                      BoxShadow(
                        color: Colors.blueGrey,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: _commitSearch,
                    child: Center(
                      child: Text(
                        'Search',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- results ---
                Expanded(
                  child: _query.isEmpty
                      ? const Center(child: Text('Type something to search…'))
                      : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('people')
                        .where('uid', isNotEqualTo: widget.currentUser.uid)
                        .where('searchKeywords', arrayContains: _query)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text('No results found.'),
                        );
                      }

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1,color: Colors.white,thickness: 10,),
                        itemBuilder: (context, index) {
                          final user = Usermodel.fromMap(
                            docs[index].data() as Map<String, dynamic>,
                          );

                          return Container(
                            color: Colors.black26,
                            child: ListTile(

                              onTap: () async {
                                ChatRoomModel? chatroommodel = await getchatroommodel(user);
                                if (chatroommodel != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                     return SearchPage(currentUser: widget.currentUser);
                                  }));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Chatroom(
                                          targetuser: user,
                                          chatroom: chatroommodel,
                                          currentuser: widget.currentUser,
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: (user.profilepic?.isNotEmpty ?? false)
                                    ? NetworkImage(user.profilepic!)
                                    : null,
                                child: (user.profilepic?.isEmpty ?? true)
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              title: Text(
                                user.fullname ?? 'No name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                user.email ?? '',
                                style: TextStyle(fontSize: 12),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: Colors.blueGrey,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
