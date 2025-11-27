import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:prototipo1_app/config/client/client_service.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/presentation/client/Components/build_primary_button.dart';
import 'package:prototipo1_app/presentation/client/Components/build_secundary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ClientService _clientService = ClientService();

  bool _loading = false;
  bool _obscurePass = true;

  // ======================================================
  //                    LOGIN LOCAL
  // ======================================================
  Future<void> _loginLocal() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese correo y contraseña")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final cliente = await _clientService.loginLocal(email, password);

      setState(() => _loading = false);

      if (cliente == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Credenciales incorrectas")),
        );
        return;
      }

      // Guardar en la sesión
      await SessionApp.setUsuario(cliente);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bienvenido ${cliente.nombreCompleto}!")),
      );

      if (!mounted) return;
      context.go('/home');

    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ======================================================
  //                    CONTRASEÑA FIELD
  // ======================================================
  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePass,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.purple),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePass ? Icons.visibility_off : Icons.visibility,
            color: Colors.purple,
          ),
          onPressed: () => setState(() => _obscurePass = !_obscurePass),
        ),
        hintText: "Ingrese su contraseña",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ======================================================
  //                    UI COMPLETA
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF87A8F7), Color(0xFFA779FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/sujeto2.gif',
                      height: size.height * 0.25,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Perfect Teeth",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Bienvenido\nInicia sesión para continuar",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Porque tu salud bucal nos importa, cuidamos cada sonrisa.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.purple),
                  hintText: "Ingrese su correo",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _passwordField(),

              const SizedBox(height: 25),

              buildPrimaryButton(
                _loading ? "Ingresando..." : "Continuar",
                onPressed: _loading ? () {} : _loginLocal,
              ),

              const SizedBox(height: 15),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot your password?",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white54)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Or",
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.white54)),
                ],
              ),

              const SizedBox(height: 15),

              buildSecondaryButton(
                "Registrarse",
                onPressed: () => context.push('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
