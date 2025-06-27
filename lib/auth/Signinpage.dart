import 'package:chat_application/auth/Signuppage.dart';
import 'package:chat_application/models/Usermodel.dart';
import 'package:chat_application/pages/HomePage.dart';
import 'package:chat_application/pages/Mainpage/Mainpage.dart';
import 'package:chat_application/pages/completeprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../uidesign/Uidesign.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  final TextEditingController emailcntroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  /* ───────────────────────────────
     Sign-in validation & Firebase
  ─────────────────────────────── */
  Future<void> chechup() async {
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
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${ex.code}")),
      );
      return;
    }

    if (credential != null) {
      final uid = credential.user!.uid;
      final userdata =
      await FirebaseFirestore.instance.collection('people').doc(uid).get();
      final usermodel =
      Usermodel.fromMap(userdata.data() as Map<String, dynamic>);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => MainPage(userModel: usermodel, firebaseUser: credential!.user!),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(0.0, 1.0); // slide from bottom
            const end = Offset.zero;
            final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
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
            colors: [Color(0xfff5f7fa), Color(0xffc3cfe2)],
            begin: Alignment.bottomCenter,
            end: Alignment.topLeft,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/voice-mail.png", height: 50),
                Text(
                  "ChatterCall",
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
                Container(
                  width: 300,
                  height: 440,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 6),
                      BoxShadow(color: Colors.grey, offset: Offset(0, 4), blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Divider(thickness: 2,height: 1,),
                      Container( width: 300 , height: 50,color: Colors.blue,child: Center(child: Text("Login Your Account",style: GoogleFonts.getFont("Lato",fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16),)),),
                      Divider(thickness: 2,height: 1,),
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
                        onTap: chechup,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 200,
                          height: 50,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff00c6fb), Color(0xff66a6ff)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black)],
                          ),
                          child: const Center(
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Create Your Account?",
                              style: GoogleFonts.openSans(fontSize: 11)),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                reverseTransitionDuration: const Duration(milliseconds: 400),
                                pageBuilder: (_, __, ___) => const SignUppage(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return ScaleTransition(
                                    scale: Tween<double>(begin: 0.8, end: 1.0)
                                        .chain(CurveTween(curve: Curves.easeInOut))
                                        .animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),

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
