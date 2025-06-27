import 'package:chat_application/auth/Signinpage.dart';
import 'package:chat_application/models/Usermodel.dart';
import 'package:chat_application/pages/completeprofile.dart';
import 'package:chat_application/uidesign/Uidesign.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUppage extends StatefulWidget {
  const SignUppage({super.key});

  @override
  State<SignUppage> createState() => _SignUppageState();
}

class _SignUppageState extends State<SignUppage> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmcontroller = TextEditingController();

  /* ───────────────────────────────
     Validation & sign-up logic
  ─────────────────────────────── */
  Future<void> checkup() async {
    final email = emailcontroller.text.trim();
    final password = passwordcontroller.text.trim();
    final cpassword = confirmcontroller.text.trim();

    if (email.isEmpty || password.isEmpty || cpassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details!")),
      );
      return;
    }
    if (password != cpassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    await signUp(email, password);
  }

  Future<void> signUp(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;
      final newUser = Usermodel(
        email: email,
        uid: uid,
        fullname: '',
        profilepic: '',
      );
      await FirebaseFirestore.instance
          .collection('people')
          .doc(uid)
          .set(newUser.Tomap());

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => Completeprofile(usermodel: newUser, firebaseuser: credential.user),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(0.0, 1.0); // slide from bottom
            const end = Offset.zero;
            final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'That e-mail is already registered.';
          break;
        case 'weak-password':
          msg = 'Choose a password with at least 6 characters.';
          break;
        case 'invalid-email':
          msg = 'That doesn’t look like a valid e-mail address.';
          break;
        default:
          msg = 'Sign-up failed (${e.code}).';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
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
                SizedBox(height: 22),
            
                Container(
                  width: 300,
                  height: 500,
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
                      Container( width: 300 , height: 50,color: Colors.blue,child: Center(child: Text("Create Your Account",style: GoogleFonts.getFont("Lato",fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16),)),),
                      Divider(thickness: 2,height: 1,),
                      const SizedBox(height: 20),
                      const SizedBox(height: 11),
                      Uidesign().customTextField(
                        label: "Email",
                        hinttext: "Enter Your Email..",
                        controller: emailcontroller,
                        icon: Icons.email,
                      ),
                      Uidesign().customTextField(
                        label: "Password",
                        hinttext: "Enter Your password..",
                        controller: passwordcontroller,
                        icon: Icons.password_outlined,
                        isPassword: false,
                      ),
                      Uidesign().customTextField(
                        label: "Confirm*",
                        hinttext: "Enter Your password..",
                        controller: confirmcontroller,
                        icon: Icons.password,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: checkup,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 200,
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff00c6fb), Color(0xff66a6ff)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black)],
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Up",
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
                          Text(
                            "Already have an Account?",
                            style: GoogleFonts.openSans(fontSize: 11),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                reverseTransitionDuration:
                                const Duration(milliseconds: 400),
                                pageBuilder: (_, __, ___) => const Signinpage(),
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
                              "Sign In",
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
