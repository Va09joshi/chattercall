import 'package:chat_application/auth/authenticationPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;
  final String profileUrl;

  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Profile",style: GoogleFonts.getFont("Lato",fontSize: 25),),

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
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 400,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blueGrey.shade900, Color(0xFF0D47A1)])
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,

                  bottom: -50,
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        width: 150, // must be equal for perfect circle
                        height: 150,
                        color: Colors.grey[300], // optional background
                        child: Image.network(
                          profileUrl,
                          fit: BoxFit.contain, // ensures the image fits inside the circle
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60),
                        ),
                      ),
                    ),
                  ),
                )


              ],
            ),
          ),
          SizedBox(height: 30),
          // Profile Picture


          const SizedBox(height: 20),

          // Name
          Text(
            name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          // Email
          Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),

          const SizedBox(height: 30),


          Divider(),
          SizedBox(
            height: 12,
          ),
          // Other options
          Container(
            width: 390,
            height: 50,

            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.blueGrey.shade900, Color(0xFF0D47A1)
              ]),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [BoxShadow(color: Colors.black26)],
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "Edit Profile",
                    style: GoogleFonts.getFont(
                      "Lato",
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 11,
          ),
          Container(
            width: 390,
            height: 50,

            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.blueGrey.shade900, Color(0xFF0D47A1)
              ]),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [BoxShadow(color: Colors.black26)],
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "Settings",
                    style: GoogleFonts.getFont(
                      "Lato",
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 11,),
          Container(
            width: 390,
            height: 50,

            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.red.shade900, Colors.red,Colors.red.shade900
              ]),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [BoxShadow(color: Colors.black26)],
            ),
            child: InkWell(
              onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route)=>
                    route.isFirst
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                    return AuthenticationPage();
                  }));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "Logout",
                    style: GoogleFonts.getFont(
                      "Lato",
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),


        ],
      ),
    );
  }
}
