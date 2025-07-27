import 'package:chat_application/auth/authenticationPage.dart';
import 'package:chat_application/models/Usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            ProfileTile(
              icon: Icons.edit,
              label: "Edit Profile",
              onTap: () {},
              gradientColors: [Colors.blueGrey.shade900, const Color(0xFF0D47A1)],
            ),
            const SizedBox(height: 10),
            ProfileTile(
              icon: Icons.settings,
              label: "Settings",
              onTap: () {},
              gradientColors: [Colors.blueGrey.shade900, const Color(0xFF0D47A1)],
            ),
            const SizedBox(height: 10),
            ProfileTile(
              icon: Icons.logout,
              label: "Logout",
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  AuthenticationPage()),
                );
              },
              gradientColors: [Colors.red.shade900, Colors.red, Colors.red.shade900],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const ProfileTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(11),
        boxShadow: [BoxShadow(color: Colors.black26)],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
