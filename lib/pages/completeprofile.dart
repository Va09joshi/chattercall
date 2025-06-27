import 'dart:convert';                       // NEW
import 'dart:developer';
import 'dart:io';

import 'package:chat_application/models/Usermodel.dart';
import 'package:chat_application/pages/HomePage.dart';
import 'package:chat_application/pages/Mainpage/Mainpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;      // NEW

import '../uidesign/Uidesign.dart';

class Completeprofile extends StatefulWidget {
  final Usermodel? usermodel;
  final User? firebaseuser;

  const Completeprofile({
    super.key,
    required this.usermodel,
    required this.firebaseuser,
  });

  @override
  State<Completeprofile> createState() => _CompleteprofileState();
}

class _CompleteprofileState extends State<Completeprofile> {
  File? imagefile;
  TextEditingController namecontroller = TextEditingController();

  /* ───────────────── image pick & crop ───────────────── */

  void selectimage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) Cropimage(picked);
  }

  void Cropimage(XFile file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 21,
    );
    if (cropped != null) {
      setState(() => imagefile = File(cropped.path));
    }
  }

  /* ───────────────── modal for camera / gallery ───────────────── */

  void showphotoOptions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Upload Profile Picture",
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(thickness: 2, height: 3),
            const SizedBox(height: 11),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.blue),
              title: const Text("Select from Gallery"),
              onTap: () {
                Navigator.pop(context);
                selectimage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Colors.red),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                selectimage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ───────────────── validation ───────────────── */

  void checkvalues() {
    final fullname = namecontroller.text.trim();
    if (fullname.isEmpty || imagefile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the details")),
      );
    } else {
      log("uploading data…");
      UploadData();
    }
  }

  /* ───────────────── upload to ImgBB & Firestore ───────────────── */

  Future<void> UploadData() async {
    try {
      /* 1️⃣  Upload image to ImgBB */
      const apiKey = 'a3148b0b120196e73402f12ce7eae950';               // <-- put your key here
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

      final bytes = await imagefile!.readAsBytes();
      final base64Img = base64Encode(bytes);

      final res = await http.post(uri, body: {'image': base64Img});
      if (res.statusCode != 200) {
        throw ('ImgBB upload failed (${res.statusCode})');
      }
      final imageurl = jsonDecode(res.body)['data']['url'];

      /*  Save name + Img URL to Firestore */
      final fullname = namecontroller.text.trim();
      widget.usermodel!
        ..fullname = fullname
        ..profilepic = imageurl;

      await FirebaseFirestore.instance
          .collection("people")
          .doc(widget.usermodel!.uid)
          .set(widget.usermodel!.Tomap());

      log("data uploaded");
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
          return MainPage(userModel: widget.usermodel,firebaseUser: widget.firebaseuser);
      })); // back on success
      }
    } catch (e) {
      log('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  /* ───────────────── UI ───────────────── */

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
              children: [
                Container(
                  width: 300,
                  height: 600,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 6),
                      BoxShadow(color: Colors.grey, offset: Offset(0, 4), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Divider(thickness: 2,height: 1,),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                          colors: [Colors.blueGrey, Colors.blueAccent,Colors.blueAccent,Colors.blueGrey],
                        ),
                        ),
                        width: 300 , height: 50,child: Center(child: Text("Login Your Account",style: GoogleFonts.getFont("Lato",fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16),)),),
                      Divider(thickness: 2,height: 1,),

                      CupertinoButton(
                        onPressed: showphotoOptions,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 80,
                          backgroundImage: imagefile != null ? FileImage(imagefile!) : null,
                          child: imagefile == null
                              ? const Icon(Icons.account_circle, size: 150, color: Colors.blue)
                              : null,
                        ),
                      ),

                      Text(
                        "Complete Profile",
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Uidesign().customTextField(
                        label: "Full name",
                        hinttext: "Enter name here…",
                        controller: namecontroller,
                        icon: Icons.people_alt_rounded,
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: checkvalues,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blueGrey, Colors.blueAccent,Colors.blueAccent,Colors.blueGrey],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black)],
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
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
