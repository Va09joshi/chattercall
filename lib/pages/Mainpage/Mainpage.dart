/// main_page.dart
import 'package:chat_application/models/Usermodel.dart';
import 'package:chat_application/pages/HomePage.dart';
import 'package:chat_application/pages/Mainpage/profileScreen.dart';
import 'package:chat_application/pages/Mainpage/videocallpage.dart';
import 'package:chat_application/pages/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
  /// Pass the signed-in user and your own UserModel down from whatever
  /// screen creates MainPage (often after login).
  const MainPage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  final Usermodel? userModel;
  final User? firebaseUser;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  /// Build the page list in `initState` so we can access `widget.userModel`
  /// and `widget.firebaseUser`.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(
        usermodel: widget.userModel,
        firebaseuser: widget.firebaseUser,
      ),
      Searchpage(),
      Videocallpage(),
      Profilescreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
              Colors.blue.shade400,
              Colors.blue.shade900
            ]),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
            ],
          ),
          child: SingleChildScrollView(
           scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

              child: GNav(
                 // Prevent tiny overflows


                gap: 4,
                activeColor: Colors.blue.shade900,
        
                color: Colors.white,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: Colors.white60,
                selectedIndex: _selectedIndex,
        
                onTabChange: (index) => setState(() => _selectedIndex = index),
                tabs:  [
                  GButton(icon: Icons.home, text: 'Home'),
                  GButton(icon: Icons.search, text: 'Search'),
                  GButton(icon: Icons.video_camera_front, text: 'Video Call'),
                  GButton(icon: Icons.person, text: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
