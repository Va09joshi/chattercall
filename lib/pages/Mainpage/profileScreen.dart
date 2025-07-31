import 'package:chat_application/auth/authenticationPage.dart';
import 'package:chat_application/models/Usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Usermodel? currentUser;
  String joinedDate = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      // Fetch from Firestore
      final doc = await FirebaseFirestore.instance.collection('people').doc(currentUserUid).get();

      if (doc.exists) {
        setState(() {
          currentUser = Usermodel.fromMap(doc.data()!);
        });
      }

      // Get joined date from Auth metadata
      final creationTime = FirebaseAuth.instance.currentUser?.metadata.creationTime;
      if (creationTime != null) {
        setState(() {
          joinedDate = DateFormat('MMMM yyyy').format(creationTime); // e.g., July 2025
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Profile", style: GoogleFonts.lato(fontSize: 25)),
            const SizedBox(width: 10),
            Image.asset("assets/images/communication.png", width: 30),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xff09203f),
        titleTextStyle: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
        toolbarHeight: 60,
        elevation: 10,
        shadowColor: Colors.white12,
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            /// Cover + Profile Image
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueGrey.shade900, const Color(0xFF0D47A1)],
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: currentUser!.profilepic != null && currentUser!.profilepic!.isNotEmpty
                            ? Image.network(
                          currentUser!.profilepic!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 60),
                        )
                            : const Icon(Icons.person, size: 60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),

            /// Name + Email + More Info
            Text(
              currentUser!.fullname ?? "No Name",
              style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              currentUser!.email ?? "No Email",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text("Joined: $joinedDate", style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 30),
            Divider(),

            /// Option Tiles
            ActionTile(
              icon: FontAwesomeIcons.userPen,
              label: "Edit Profile",
              textColor: Colors.black87,
              onTap: () {},

            ),
            const SizedBox(height: 10),
            ActionTile(
              icon: FontAwesomeIcons.gear,
              label: "Settings",
              textColor: Colors.black87,
              onTap: () {},

            ),
            const SizedBox(height: 10),
            ActionTile(
              icon: FontAwesomeIcons.headset,
              label: 'Help & Support',
              onTap: () {},
              textColor: Colors.black87,
            ),
            const SizedBox(height: 10),
            ActionTile(
              icon: FontAwesomeIcons.arrowRightFromBracket,
              label: "Logout",
              textColor: Colors.red,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  AuthenticationPage()),
                );
              },

            ),


          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;

  const ActionTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      elevation: 6, // adds shadow
      color: Colors.white,
      shadowColor: Colors.black45,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Row(
                   children: [
                     Icon(icon, color: textColor),
                     const SizedBox(width: 15),
                     Text(
                       label,
                       style: GoogleFonts.lato(
                         fontSize: 17,
                         fontWeight: FontWeight.w600,
                         color: textColor,
                       ),
                     ),

                   ],

                 ),
                Icon(FontAwesomeIcons.arrowRight,color: Colors.blueGrey,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

