import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildTextField(
  IconData icon,
  String hint, {
  bool isPassword = false,
  TextEditingController? controller,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    validator: validator,
    style: GoogleFonts.poppins(color: Colors.black87),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.purple),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.black45),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13),
    ),
  );
}
