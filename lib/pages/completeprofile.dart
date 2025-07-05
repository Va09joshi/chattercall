import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_application/pages/Mainpage/Mainpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// ‼️— unified URI —‼️
import '../models/Usermodel.dart';

import '../uidesign/Uidesign.dart';
import '../keyword_utils.dart';   // buildSearchKeywords() & saveUser()

class Completeprofile extends StatefulWidget {
  final Usermodel usermodel;
  final User firebaseuser;

  const Completeprofile({
    Key? key,
    required this.usermodel,
    required this.firebaseuser,
  }) : super(key: key);

  @override
  State<Completeprofile> createState() => _CompleteprofileState();
}

class _CompleteprofileState extends State<Completeprofile> {
  File? imagefile;
  final TextEditingController namecontroller = TextEditingController();
  bool isUploading = false;

  /* ───── image pick & crop ───── */

  Future<void> selectImage(ImageSource src) async {
    final picked = await ImagePicker().pickImage(source: src);
    if (picked != null) _cropImage(picked);
  }

  Future<void> _cropImage(XFile file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 75,
    );
    if (cropped != null) setState(() => imagefile = File(cropped.path));
  }

  void _showPhotoOptions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Upload Profile Picture",
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Select from Gallery"),
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ───── validation & upload ───── */

  void _checkValues() {
    final fullName = namecontroller.text.trim();
    if (fullName.isEmpty || imagefile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all the details")));
    } else {
      _uploadData(fullName);
    }
  }

  Future<void> _uploadData(String fullName) async {
    setState(() => isUploading = true);
    try {
      /* 1️⃣  Upload image to ImgBB */
      const apiKey = 'a3148b0b120196e73402f12ce7eae950';
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
      final base64Img = base64Encode(await imagefile!.readAsBytes());

      final res = await http.post(uri, body: {'image': base64Img});
      if (res.statusCode != 200) throw ('ImgBB upload failed');

      final imageUrl = jsonDecode(res.body)['data']['url'];

      /* 2️⃣  Save to Firestore with searchKeywords */
      await saveUser(
        uid: widget.usermodel.uid!,
        fullname: fullName,
        email: widget.usermodel.email!,
        profilePic: imageUrl,
      );

      // keep local model in sync
      widget.usermodel
        ..fullname = fullName
        ..profilepic = imageUrl;

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainPage(
            userModel: widget.usermodel,
            firebaseUser: widget.firebaseuser,
          ),
        ),
      );
    } catch (e) {
      log('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  /* ───── UI ───── */

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
            child: Container(
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(blurRadius: 6, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text("Complete Profile",
                      style: GoogleFonts.lato(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: _showPhotoOptions,
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 70,
                      backgroundImage:
                      imagefile != null ? FileImage(imagefile!) : null,
                      child: imagefile == null
                          ? const Icon(Icons.account_circle,
                          size: 150, color: Colors.black38)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Uidesign().customTextField(
                    label: "Full name",
                    hinttext: "Enter name here…",
                    controller: namecontroller,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: isUploading ? null : _checkValues,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 200,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueGrey, Colors.blueAccent],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black)],
                      ),
                      child: isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
