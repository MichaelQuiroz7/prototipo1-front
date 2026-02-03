import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
import 'package:prototipo1_app/presentation/employee/dto/especialidad_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class EspecialidadesScreen extends StatefulWidget {
  const EspecialidadesScreen({super.key});

  @override
  State<EspecialidadesScreen> createState() => _EspecialidadesScreenState();
}

class _EspecialidadesScreenState extends State<EspecialidadesScreen> {
  final TratamientosService _service = TratamientosService();
  final ImagePicker _picker = ImagePicker();

  List<Especialidad> _especialidades = [];
  List<Tratamiento> _tratamientos = [];
  int? _selectedEspecialidadId;
  // File? _selectedImage;

  Color get primaryColor => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadEspecialidades();
  }

  // ===================================================
  //  CARGAR DATOS
  // ===================================================
  Future<void> _loadEspecialidades() async {
    try {
      final data = await _service.getAllEspecialidades();
      setState(() {
        _especialidades = data;
        if (data.isNotEmpty)
          _selectedEspecialidadId = data.first.idEspecialidad;
      });
      _loadTratamientos();
    } on DioException catch (e) {
      _showError(e);
    }
  }

  Future<void> _loadTratamientos() async {
    try {
      final data = await _service.getAllTratamientos();
      setState(() => _tratamientos = data);
    } on DioException catch (e) {
      _showError(e);
    }
  }

  // ===================================================
  //  SELECCIONAR IMAGEN  CORONAS -CARILLAS DE PORCELANA E-MAX MAS DE 3
  // ===================================================
  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() => _selectedImage = File(pickedFile.path));
  //   }
  // }

  // ===================================================
  //  AGREGAR / CREAR
  // ===================================================
  Future<void> _addEspecialidad() async {
  final formKey = GlobalKey<FormState>();

  String nombre = '';
  String descripcion = '';
  File? imagenSeleccionada;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Nueva Especialidad',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // =========================
                      // IMAGEN (OBLIGATORIA)
                      // =========================
                      GestureDetector(
                        onTap: () async {
                          final picked = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );

                          if (picked != null) {
                            setStateDialog(() {
                              imagenSeleccionada = File(picked.path);
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[100],
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: imagenSeleccionada == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 45,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Imagen obligatoria",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    imagenSeleccionada!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =========================
                      // NOMBRE (OBLIGATORIO)
                      // =========================
                      TextFormField(
                        decoration: _inputDecoration("Nombre *"),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "El nombre es obligatorio"
                                : null,
                        onChanged: (v) => nombre = v,
                      ),

                      const SizedBox(height: 12),

                      // =========================
                      // DESCRIPCIÓN (OBLIGATORIA)
                      // =========================
                      TextFormField(
                        decoration: _inputDecoration("Descripción *"),
                        maxLines: 2,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "La descripción es obligatoria"
                                : null,
                        onChanged: (v) => descripcion = v,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  if (imagenSeleccionada == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Debe seleccionar una imagen"),
                      ),
                    );
                    return;
                  }

                  try {
                    final nueva = Especialidad(
                      idEspecialidad: 0,
                      nombre: nombre,
                      descripcion: descripcion,
                      fechaCreacion: DateTime.now(),
                    );

                    await _service.createEspecialidad(
                      nueva,
                      imagenFile: imagenSeleccionada,
                    );

                    Navigator.pop(context);
                    _loadEspecialidades();
                  } on DioException catch (e) {
                    _showError(e);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      );
    },
  );
}


  Future<void> _addTratamiento() async {
    final formKey = GlobalKey<FormState>();

    String nombre = '';
    String descripcion = '';
    String codigo = '';
    double? precio;
    int? especialidadSeleccionada = _selectedEspecialidadId;
    File? imagenSeleccionada;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Nuevo Tratamiento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // =========================
                        // IMAGEN
                        // =========================
                        GestureDetector(
                          onTap: () async {
                            final picked = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (picked != null) {
                              setStateDialog(() {
                                imagenSeleccionada = File(picked.path);
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[100],
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            child: imagenSeleccionada == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 45,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Agregar imagen",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      imagenSeleccionada!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =========================
                        // ESPECIALIDAD
                        // =========================
                        DropdownButtonFormField<int>(
                          value: especialidadSeleccionada,
                          decoration: _inputDecoration("Especialidad"),
                          validator: (value) =>
                              value == null ? "Campo obligatorio" : null,
                          items: _especialidades.map((esp) {
                            return DropdownMenuItem<int>(
                              value: esp.idEspecialidad,
                              child: Text(esp.nombre),
                            );
                          }).toList(),
                          onChanged: (val) => especialidadSeleccionada = val,
                        ),

                        const SizedBox(height: 12),

                        // =========================
                        // NOMBRE (OBLIGATORIO)
                        // =========================
                        TextFormField(
                          decoration: _inputDecoration("Nombre *"),
                          validator: (value) => value == null || value.isEmpty
                              ? "Campo obligatorio"
                              : null,
                          onChanged: (v) => nombre = v,
                        ),

                        const SizedBox(height: 12),

                        // =========================
                        // PRECIO (OBLIGATORIO)
                        // =========================
                        TextFormField(
                          decoration: _inputDecoration("Precio *"),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Campo obligatorio";
                            }
                            if (double.tryParse(value) == null) {
                              return "Precio inválido";
                            }
                            return null;
                          },
                          onChanged: (v) => precio = double.tryParse(v),
                        ),

                        const SizedBox(height: 12),

                        // OPCIONALES
                        TextFormField(
                          decoration: _inputDecoration("Código (Opcional)"),
                          onChanged: (v) => codigo = v,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: _inputDecoration(
                            "Descripción (Opcional)",
                          ),
                          maxLines: 2,
                          onChanged: (v) => descripcion = v,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    if (imagenSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("La imagen es obligatoria"),
                        ),
                      );
                      return;
                    }

                    try {
                      final nuevo = Tratamiento(
                        idTratamiento: 0,
                        codigo: codigo,
                        nombre: nombre,
                        descripcion: descripcion,
                        precio: precio!,
                        idEspecialidad: especialidadSeleccionada!,
                        fechaCreacion: DateTime.now(),
                      );

                      await _service.createTratamiento(
                        nuevo,
                        imagenFile: imagenSeleccionada,
                      );

                      Navigator.pop(context);
                      _loadTratamientos();
                    } on DioException catch (e) {
                      _showError(e);
                    }
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  // Future<void> _addTratamiento() async {
  //   String nombre = '';
  //   String descripcion = '';
  //   String codigo = '';
  //   double precio = 0.0;
  //   int? especialidadSeleccionada = _selectedEspecialidadId;
  //   _selectedImage = null;

  //   await showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Agregar Tratamiento'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             GestureDetector(
  //               onTap: _pickImage,
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: Container(
  //                   height: 120,
  //                   width: double.infinity,
  //                   color: Theme.of(
  //                     context,
  //                   ).colorScheme.primary.withOpacity(0.9),
  //                   child: _selectedImage == null
  //                       ? Center(
  //                           child: Icon(
  //                             Icons.add_photo_alternate_outlined,
  //                             size: 40,
  //                             color: primaryColor,
  //                           ),
  //                         )
  //                       : Image.file(
  //                           _selectedImage!,
  //                           fit: BoxFit.cover,
  //                           width: double.infinity,
  //                           height: double.infinity,
  //                         ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             DropdownButtonFormField<int>(
  //               value: especialidadSeleccionada,
  //               decoration: const InputDecoration(labelText: 'Especialidad'),
  //               items: _especialidades.map((esp) {
  //                 return DropdownMenuItem<int>(
  //                   value: esp.idEspecialidad,
  //                   child: Text(esp.nombre),
  //                 );
  //               }).toList(),
  //               onChanged: (val) => especialidadSeleccionada = val,
  //             ),
  //             TextField(
  //               decoration: const InputDecoration(labelText: 'Código'),
  //               onChanged: (v) => codigo = v,
  //             ),
  //             TextField(
  //               decoration: const InputDecoration(labelText: 'Nombre'),
  //               onChanged: (v) => nombre = v,
  //             ),
  //             TextField(
  //               decoration: const InputDecoration(labelText: 'Descripción'),
  //               onChanged: (v) => descripcion = v,
  //             ),
  //             TextField(
  //               decoration: const InputDecoration(labelText: 'Precio'),
  //               keyboardType: TextInputType.number,
  //               onChanged: (v) => precio = double.tryParse(v) ?? 0.0,
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancelar'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             try {
  //               if (especialidadSeleccionada == null) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text("Seleccione una especialidad"),
  //                   ),
  //                 );
  //                 return;
  //               }

  //               final nuevo = Tratamiento(
  //                 idTratamiento: 0,
  //                 codigo: codigo,
  //                 nombre: nombre,
  //                 descripcion: descripcion,
  //                 precio: precio,
  //                 idEspecialidad: especialidadSeleccionada!,
  //                 fechaCreacion: DateTime.now(),
  //               );
  //               await _service.createTratamiento(
  //                 nuevo,
  //                 imagenFile: _selectedImage,
  //               );
  //               Navigator.pop(context);
  //               _loadTratamientos();
  //             } on DioException catch (e) {
  //               _showError(e);
  //             }
  //           },
  //           child: const Text('Guardar'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ===================================================
  //  UTILIDAD
  // ===================================================
  void _showError(DioException e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.response?.data ?? e.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ===================================================
  //  INTERFAZ
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['ENDPOINT_API6'] ?? ' ';
    final tratamientosFiltrados = _selectedEspecialidadId != null
        ? _tratamientos
              .where((t) => t.idEspecialidad == _selectedEspecialidadId)
              .toList()
        : _tratamientos;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Especialidades y Tratamientos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedEspecialidadId,
              decoration: InputDecoration(
                labelText: 'Seleccionar Especialidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _especialidades.map((esp) {
                return DropdownMenuItem<int>(
                  value: esp.idEspecialidad,
                  child: Text(esp.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedEspecialidadId = value);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: tratamientosFiltrados.isEmpty
                  ? const Center(child: Text('No hay tratamientos registrados'))
                  : ListView.builder(
                      itemCount: tratamientosFiltrados.length,
                      itemBuilder: (context, index) {
                        final t = tratamientosFiltrados[index];
                        final imageUrl = t.imagen != null
                            //? 'http://192.168.1.20:3000${t.imagen}'
                            ? '$baseUrl${t.imagen}'
                            : null;
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: 60,
                                        height: 60,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            title: Text(t.nombre),
                            subtitle: Text(
                              '${t.descripcion ?? ''}\nCódigo: ${t.codigo ?? 'N/A'}',
                            ),
                            trailing: Text('\$${t.precio.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandableFab(
        distance: 75.0,
        children: [
          _buildActionButton(
            icon: Icons.category_outlined,
            label: "Nueva Especialidad",
            onPressed: _addEspecialidad,
          ),
          _buildActionButton(
            icon: Icons.medical_services_outlined,
            label: "Nuevo Tratamiento",
            onPressed: _addTratamiento,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Texto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),

          // Botón
          FloatingActionButton.small(
            heroTag: label,
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 6,
            onPressed: onPressed,
            child: Icon(icon, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ===================================================
// FAB ANIMADO
// ===================================================
class ExpandableFab extends StatefulWidget {
  final double distance;
  final List<Widget> children;
  const ExpandableFab({
    super.key,
    required this.distance,
    required this.children,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      _open ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          if (_open)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: Container(color: Colors.transparent),
              ),
            ),
          ..._buildExpandingActionButtons(),
          _buildMainFab(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      children.add(
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            final offset = Offset(
              0,
              (i + 1) * widget.distance * _expandAnimation.value,
            );
            return Positioned(
              right: 4,
              bottom: offset.dy,
              child: Transform.scale(
                scale: _expandAnimation.value,
                child: child,
              ),
            );
          },
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildMainFab() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: _toggle,
      child: Icon(_open ? Icons.close : Icons.menu),
    );
  }
}
