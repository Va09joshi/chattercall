import 'package:chat_application/models/Usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final TextEditingController searchcontroller = TextEditingController();
  String _emailQuery = '';

  void _performSearch() {
    setState(() => _emailQuery = searchcontroller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        titleTextStyle: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
        toolbarHeight: 60,
        elevation: 10,
        shadowColor: Colors.black87,
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ─── Search box ──────────────────────────────────────────────
              TextField(
                controller: searchcontroller,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: "search for chats…",
                  hintStyle: const TextStyle(color: Colors.blueGrey),
                  label: const Text("Search",
                      style:
                      TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade900),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              CupertinoButton.filled(
                child: const Text("Search"),
                onPressed: _performSearch,
              ),
              const SizedBox(height: 20),

              // ─── Results list ───────────────────────────────────────────
              Expanded(
                child: _emailQuery.isEmpty
                    ? const Center(child: Text("Enter an email to search"))
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection("people")
                      .where("email", isEqualTo: _emailQuery)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text("No result found!"));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final user = Usermodel.fromMap(docs[index].data());
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user.fullname ?? "No Name",
                              style: const TextStyle(color: Colors.black)),
                          subtitle: Text(user.email ?? "",
                              style: const TextStyle(color: Colors.black54)),
                          onTap: () {
                            // TODO: navigate to chat or profile
                          },
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
    );
  }
}
