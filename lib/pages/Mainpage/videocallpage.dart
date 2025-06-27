import 'package:flutter/material.dart';

class Videocallpage extends StatefulWidget {
  const Videocallpage({super.key});

  @override
  State<Videocallpage> createState() => _VideocallpageState();
}

class _VideocallpageState extends State<Videocallpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("video Call"),),
    );
  }
}
