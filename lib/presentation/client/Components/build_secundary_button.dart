import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

Widget buildSecondaryButton(String text, {required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white70),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


   Widget buildGoogleButton(String text, {required VoidCallback onPressed}) {
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Image.asset('assets/images/googleLogo.png', height: 24), 
        label: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.transparent,
        ),
        onPressed: onPressed,
      ),
    );
  }