import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototipo1_app/config/client/client_service.dart';
import 'package:prototipo1_app/presentation/client/Components/build_primary_button.dart';
import 'package:prototipo1_app/presentation/client/Components/build_text_field.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';

class RegisterScreen extends StatefulWidget {
  final int? idRolRegister;
  const RegisterScreen({super.key, this.idRolRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //final _googleAuthService = GoogleAuthService();
  // Controladores
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _clientService = ClientService();

  bool _isLoading = false;
  String? _generoSeleccionado;

  // ==========================================================
  //  Registrar cliente
  // ==========================================================
  Future<void> _registrarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmarPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cliente = Cliente(
        idCliente: 0,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        cedula: _cedulaController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        passwordHash: _passwordController.text.trim(),
        proveedorAuth: 'local',
        idRol: widget.idRolRegister ?? 3,
        fechaNacimiento: _fechaNacimientoController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(_fechaNacimientoController.text)
            : null,
        genero: _generoSeleccionado,
        fechaRegistro: DateTime.now(),
      );

      final nuevo = await _clientService.createCliente(cliente);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registro exitoso: ${nuevo.nombreCompleto}"),
            backgroundColor: Colors.greenAccent.shade700,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al registrar: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================================
  //  Selector de fecha con localización (sin error)
  // ==========================================================
  Future<void> _seleccionarFechaNacimiento(BuildContext context) async {
    const locale = Locale('es', 'ES');

    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: locale,
          delegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: child,
        );
      },
    );

    if (seleccionada != null) {
      setState(() {
        _fechaNacimientoController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(seleccionada);
      });
    }
  }

  // ==========================================================
  //  Construcción de la pantalla
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF87A8F7), Color(0xFFA779FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================
                // CABECERA
                // =====================================
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
                  "Crea tu cuenta",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Ingresa tus datos para registrarte y mejorar tu salud bucal.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),

                // =====================================
                // CAMPOS DEL FORMULARIO
                // =====================================
                buildTextField(
                  Icons.person_outline,
                  "Nombre",
                  controller: _nombreController,
                  validator: _required,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  Icons.person_outline,
                  "Apellido",
                  controller: _apellidoController,
                  validator: _required,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  Icons.badge_outlined,
                  "Cédula",
                  controller: _cedulaController,
                  validator: _required,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  Icons.email_outlined,
                  "Correo electrónico",
                  controller: _correoController,
                  validator: _emailValidator,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  Icons.phone_outlined,
                  "Teléfono",
                  controller: _telefonoController,
                ),
                const SizedBox(height: 15),

                // 📅 Fecha de nacimiento
                GestureDetector(
                  onTap: () => _seleccionarFechaNacimiento(context),
                  child: AbsorbPointer(
                    child: buildTextField(
                      Icons.calendar_today,
                      "Fecha de nacimiento",
                      controller: _fechaNacimientoController,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 🚻 Género
                DropdownButtonFormField<String>(
                  value: _generoSeleccionado,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_2_outlined,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  hint: Text(
                    "Seleccione su género",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Masculino",
                      child: Text("Masculino"),
                    ),
                    DropdownMenuItem(
                      value: "Femenino",
                      child: Text("Femenino"),
                    ),
                    DropdownMenuItem(value: "Otro", child: Text("Otro")),
                  ],
                  onChanged: (value) =>
                      setState(() => _generoSeleccionado = value),
                  validator: (value) =>
                      value == null ? 'Seleccione un género' : null,
                ),
                const SizedBox(height: 15),

                // 🔒 Contraseñas
                buildTextField(
                  Icons.lock_outline,
                  "Contraseña",
                  controller: _passwordController,
                  isPassword: true,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 15),
                buildTextField(
                  Icons.lock_outline,
                  "Confirmar contraseña",
                  controller: _confirmarPasswordController,
                  isPassword: true,
                  validator: _passwordValidator,
                ),

                const SizedBox(height: 25),
                buildPrimaryButton(
                  _isLoading ? "Registrando..." : "Registrarse",
                  onPressed: _isLoading ? () {} : () => _registrarCliente(),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Colors.white54, thickness: 0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "O",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Colors.white54, thickness: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // GOOGLE
                // SizedBox(
                //   width: double.infinity,
                //   child: buildGoogleButton(
                //     "Registrarse con Google",
                //     onPressed: () async {
                //       final cliente = await _googleAuthService
                //           .signInWithGoogle();
                //       if (cliente != null && context.mounted) {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           SnackBar(
                //             content: Text(
                //               "Bienvenido ${cliente.nombreCompleto}",
                //             ),
                //             backgroundColor: Colors.greenAccent.shade700,
                //           ),
                //         );
                //         Navigator.pop(context);
                //       } else {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           SnackBar(
                //             content: Text(
                //               "Inicio de sesión cancelado o fallido\n mail: ${cliente?.correo} " ,
                //             ),
                //           ),
                //         );
                //       }
                //     },
                //   ),
                // ),
                const SizedBox(height: 20),

                // YA TIENES CUENTA
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "¿Ya tienes cuenta? Inicia sesión",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  //  Validaciones básicas
  // ==========================================================
  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo requerido' : null;

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value)) return 'Correo no válido';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }
}
