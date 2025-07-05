import 'package:chat_application/auth/Signuppage.dart';
 // ✅ Updated import
import 'package:chat_application/pages/HomePage.dart';
import 'package:chat_application/pages/Mainpage/Mainpage.dart';
import 'package:chat_application/pages/completeprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/Usermodel.dart';
import '../uidesign/Uidesign.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  final TextEditingController emailcntroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  @override
  void dispose() {
    emailcntroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  /* ───────────────────────────────
     Sign-in validation & Firebase
  ─────────────────────────────── */
  Future<void> checkUp() async {
    final email = emailcntroller.text.trim();
    final password = passwordcontroller.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields!")),
      );
      return;
    }

    await signin(email, password);
  }

  Future<void> signin(String email, String password) async {
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (ex) {
      String message = "An error occurred.";
      switch (ex.code) {
        case "user-not-found":
          message = "No user found with that email.";
          break;
        case "wrong-password":
          message = "Incorrect password.";
          break;
        case "invalid-email":
          message = "Invalid email format.";
          break;
        default:
          message = "Error: ${ex.code}";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (credential != null) {
      final uid = credential.user!.uid;
      final userdata = await FirebaseFirestore.instance.collection('people').doc(uid).get();

      if (!userdata.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found in Firestore.")),
        );
        return;
      }

      final usermodel = Usermodel.fromMap(userdata.data() as Map<String, dynamic>);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) =>
              MainPage(userModel: usermodel, firebaseUser: credential?.user!),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  /* ───────────────────────────────
     UI
  ─────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff09203f), Color(0xff537895), Color(0xff09203f)],
            begin: Alignment(0, 5),
            end: Alignment(5, 0),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/communication.png", height: 50),
                Text(
                  "ChatterCall",
                  style: GoogleFonts.getFont(
                    "Jost",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 22),
                Container(
                  width: 300,
                  height: 440,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.white),
                      BoxShadow(color: Colors.white),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Divider(thickness: 2, height: 1),
                      Container(
                        width: 300,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff09203f),
                              Color(0xff537895),
                              Color(0xff09203f),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Login",
                            style: GoogleFonts.getFont(
                              "Jost",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Divider(thickness: 2, height: 1),
                      const SizedBox(height: 20),
                      Uidesign().customTextField(
                        label: "Email",
                        hinttext: "Enter Your Email..",
                        controller: emailcntroller,
                        icon: Icons.email,
                      ),
                      Uidesign().customTextField(
                        label: "Password",
                        hinttext: "Enter Your password..",
                        controller: passwordcontroller,
                        icon: Icons.password,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: checkUp, // ✅ updated method name
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 200,
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 30,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff537895), Color(0xff09203f)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black)],
                          ),
                          child: Center(
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.getFont("Jost",
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 11),
                      Text(
                        "Create an Account?",
                        style: GoogleFonts.openSans(fontSize: 11),
                      ),
                      SizedBox(height: 11),
                      Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.rectangle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.keyboard_return, color: Colors.white),
                        ),
                      )
                    ],
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
