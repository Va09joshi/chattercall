 import 'package:chat_application/models/Usermodel.dart';
import 'package:chat_application/pages/SearchPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  final Usermodel? usermodel;
  final User? firebaseuser;
   const Homepage({super.key, required this.usermodel, required this.firebaseuser});
 
   @override
   State<Homepage> createState() => _HomepageState();
 }
 
 class _HomepageState extends State<Homepage> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("ChatterCall"),
         automaticallyImplyLeading: false,
         centerTitle: true,
         backgroundColor: Colors.blue,
         titleTextStyle: GoogleFonts.getFont("Lato",fontWeight: FontWeight.bold,color: Colors.white,fontSize: 15),
         toolbarHeight: 60,
         elevation: 10,
         shadowColor: Colors.black87,


       ),

       body: Center(
         child: Text("data"),
       ),
     );
   }
 }
 