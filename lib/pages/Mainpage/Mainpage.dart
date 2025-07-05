/// main_page.dart
        // ← fixed
import 'package:chat_application/models/Usermodel.dart';
import 'package:chat_application/pages/HomePage.dart';
import 'package:chat_application/pages/Mainpage/profileScreen.dart';
import 'package:chat_application/pages/Mainpage/videocallpage.dart';
import 'package:chat_application/pages/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  final Usermodel userModel;
  final User? firebaseUser;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(
        usermodel: widget.userModel,
        firebaseuser: widget.firebaseUser,
      ),
      SearchPage(currentUser: widget.firebaseUser!),
      const VideoCallScreen(),
      const ProfilePage(
        name: "Your name",
        email: "xyz@gmail.com",
        profileUrl:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMT4JKbsNzomQ38uf0_FL-d2rGZi7SwBLEhA&s",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient:
            const LinearGradient(colors: [Color(0xff09203f), Color(0xff09203f)]),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GNav(
              gap: 7,
              activeColor: Colors.grey.shade50,
              color: Colors.white,
              iconSize: 24,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.white12,
              selectedIndex: _selectedIndex,
              onTabChange: (index) => setState(() => _selectedIndex = index),
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.search, text: 'Search'),
                GButton(icon: Icons.video_camera_front, text: 'Video Call'),
                GButton(icon: Icons.person, text: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
