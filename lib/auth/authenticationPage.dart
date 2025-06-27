import 'package:chat_application/auth/Signinpage.dart';
import 'package:chat_application/auth/Signuppage.dart';
import 'package:chat_application/uidesign/uidesign.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthenticationPage extends  {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff5f7fa), Color(0xffc3cfe2)],
            begin: Alignment.bottomCenter,
            end: Alignment.topLeft,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/voice-mail.png',
                      height: 80,
                    ),

                    Text(
                      'ChatterCall',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Uidesign().gradientButton(
                      label: 'Sign In',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Signinpage()),
                      ),
                      gradient: [Colors.blue.shade900, Colors.blue],
                      icon: Icons.login,
                      height: 48,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 16),
                    Uidesign().gradientButton(
                      label: 'Sign Up',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignUppage()),
                      ),
                      gradient: [Colors.blue, Colors.blue.shade900],
                      icon: Icons.person_add,
                      height: 48,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 32),
                    const Divider(thickness: 2, color: Colors.grey),
                    const SizedBox(height: 24),
                    Uidesign().gradientButton(
                      label: 'Continue with Google',
                      onTap: () {},
                      gradient: [Colors.orange, Colors.red.shade700],
                      icon: FontAwesomeIcons.google,
                      height: 48,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 12),
                    Uidesign().gradientButton(
                      label: 'Continue with Facebook',
                      onTap: () {},
                      gradient: [Color(0xff1877f2), Colors.blue.shade900],
                      icon: FontAwesomeIcons.facebookF,
                      height: 50,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

