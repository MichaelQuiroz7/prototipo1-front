import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototipo1_app/config/client/client_service.dart';
import 'package:prototipo1_app/presentation/client/Components/build_primary_button.dart';
import 'package:prototipo1_app/presentation/client/Components/build_text_field.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/rol_entity.dart';

class RegisterScreen extends StatefulWidget {
  final int? idRolRegister;
  const RegisterScreen({super.key, this.idRolRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // ===============================
  // CONTROLADORES
  // ===============================
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
  bool _loadingRoles = false;
  String? _generoSeleccionado;

  List<RolEntity> _roles = [];
  RolEntity? _rolSeleccionado;

  // ===============================
  // INIT
  // ===============================
  @override
  void initState() {
    super.initState();

    if (widget.idRolRegister != null) {
      _cargarRoles();
    }
  }

  // ===============================
  // CARGAR ROLES
  // ===============================
  Future<void> _cargarRoles() async {
    setState(() => _loadingRoles = true);

    try {
      final roles = await _clientService.getAllRoles();

      // Seguridad adicional por si backend no filtra
      _roles = roles.where((r) => r.idRol != 1 && r.idRol != 3).toList();
    } catch (e) {
      debugPrint("Error cargando roles: $e");
    } finally {
      if (mounted) setState(() => _loadingRoles = false);
    }
  }

  // ===============================
  // REGISTRAR
  // ===============================
  Future<void> _registrarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmarPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    // Validación de rol si es empleado
    if (widget.idRolRegister != null && _rolSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione un rol")),
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
        idRol: widget.idRolRegister != null
            ? _rolSeleccionado!.idRol
            : 3,
        fechaNacimiento: _fechaNacimientoController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy')
                .parse(_fechaNacimientoController.text)
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===============================
  // FECHA
  // ===============================
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
      _fechaNacimientoController.text =
          DateFormat('dd/MM/yyyy').format(seleccionada);
      setState(() {});
    }
  }

  // ===============================
  // BUILD
  // ===============================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool esEmpleado = widget.idRolRegister != null;

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

                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/sujeto2.gif',
                        height: size.height * 0.25,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        esEmpleado ? "Registrar Empleado" : "Crea tu cuenta",
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

                buildTextField(Icons.person_outline, "Nombre",
                    controller: _nombreController, validator: _required),

                const SizedBox(height: 15),

                buildTextField(Icons.person_outline, "Apellido",
                    controller: _apellidoController, validator: _required),

                const SizedBox(height: 15),

                buildTextField(Icons.badge_outlined, "Cédula",
                    controller: _cedulaController, validator: _required),

                const SizedBox(height: 15),

                buildTextField(Icons.email_outlined, "Correo electrónico",
                    controller: _correoController, validator: _emailValidator),

                const SizedBox(height: 15),

                buildTextField(Icons.phone_outlined, "Teléfono",
                    controller: _telefonoController),

                const SizedBox(height: 15),

                GestureDetector(
                  onTap: () => _seleccionarFechaNacimiento(context),
                  child: AbsorbPointer(
                    child: buildTextField(Icons.calendar_today,
                        "Fecha de nacimiento",
                        controller: _fechaNacimientoController),
                  ),
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _generoSeleccionado,
                  decoration: _inputDecoration(Icons.person_2_outlined),
                  hint: const Text("Seleccione su género"),
                  items: const [
                    DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                    DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                    DropdownMenuItem(value: "Otro", child: Text("Otro")),
                  ],
                  onChanged: (value) =>
                      setState(() => _generoSeleccionado = value),
                  validator: (value) =>
                      value == null ? 'Seleccione un género' : null,
                ),

                // ==========================
                // SELECTOR DE ROL (SOLO EMPLEADO)
                // ==========================
                if (esEmpleado) ...[
                  const SizedBox(height: 15),

                  _loadingRoles
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<RolEntity>(
                          value: _rolSeleccionado,
                          decoration: _inputDecoration(
                              Icons.admin_panel_settings_outlined),
                          hint: const Text("Seleccione el rol del empleado"),
                          items: _roles
                              .map((rol) => DropdownMenuItem(
                                    value: rol,
                                    child: Text(rol.nombre),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _rolSeleccionado = value),
                          validator: (value) =>
                              value == null ? 'Seleccione un rol' : null,
                        ),
                ],

                const SizedBox(height: 25),

                buildPrimaryButton(
                  _isLoading ? "Registrando..." : "Registrarse",
                  onPressed: _isLoading ? () {} : _registrarCliente,
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Volver",
                      style: TextStyle(color: Colors.white),
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

  // ===============================
  // DECORACIÓN REUTILIZABLE
  // ===============================
  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.purple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  // ===============================
  // VALIDACIONES
  // ===============================
  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo requerido' : null;

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value)) return 'Correo no válido';
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
