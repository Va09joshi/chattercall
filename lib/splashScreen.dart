import 'dart:async';
import 'package:chat_application/auth/authenticationPage.dart';
import 'package:chat_application/pages/Mainpage/Mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/Firebase helper.dart';
import 'models/Usermodel.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), checkLoginStatus);
  }

  Future<void> checkLoginStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      Usermodel? userModel = await FirebaseHelper.getUserModelById(currentUser.uid);

      if (userModel != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(
              userModel: userModel,
              firebaseUser: currentUser,
            ),
          ),
        );
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  AuthenticationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff09203f),
                Color(0xff537895),
                Color(0xff09203f),
              ],
              begin: Alignment(0, 5),
              end: Alignment(5, 0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/communication.png",
                width: 200,
                height: 100,
              ),
              Text(
                "ChatterCall",
                style: GoogleFonts.jost(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
