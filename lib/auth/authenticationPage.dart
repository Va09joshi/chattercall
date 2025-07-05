import 'package:chat_application/auth/Signinpage.dart';
import 'package:chat_application/auth/Signuppage.dart';
import 'package:chat_application/uidesign/uidesign.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthenticationPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xff09203f),
            Color(0xff537895),
            Color(0xff09203f)

          ],begin: Alignment(0, 5),
              end: Alignment(5, 0)
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 700,
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
                      'assets/images/communication.png',
                      height: 60,
                    ),

                    Text(
                      'ChatterCall',
                      style: GoogleFonts.getFont("Jost",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                     Text("Please login or signup to continue",style: GoogleFonts.getFont("Lato",fontSize: 14),),
                     SizedBox(height: 40,),
                    
                    Uidesign().gradientButton(
                      label: 'Sign In',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Signinpage()),
                      ),
                      gradient: [Color(0xff09203f),Color(0xff537895)],
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
                      gradient: [Color(0xff09203f),Color(0xff537895)],
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
                      gradient: [ Colors.red.shade300,Colors.orange,Colors.orange,Colors.red.shade300],
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

