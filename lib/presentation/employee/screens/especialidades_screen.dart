import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  File? _selectedImage;

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
        if (data.isNotEmpty) _selectedEspecialidadId = data.first.idEspecialidad;
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
  //  SELECCIONAR IMAGEN
  // ===================================================
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  // ===================================================
  //  AGREGAR / CREAR
  // ===================================================
  Future<void> _addEspecialidad() async {
    String nombre = '';
    String descripcion = '';
    _selectedImage = null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar Especialidad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: primaryColor.withOpacity(0.9),
                    child: _selectedImage == null
                        ? const Center(
                            child: Icon(Icons.add_a_photo,
                                size: 40, color: Colors.grey),
                          )
                        : Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (v) => nombre = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (v) => descripcion = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final nueva = Especialidad(
                  idEspecialidad: 0,
                  nombre: nombre,
                  descripcion: descripcion,
                  fechaCreacion: DateTime.now(),
                );
                await _service.createEspecialidad(nueva,
                    imagenFile: _selectedImage);
                Navigator.pop(context);
                _loadEspecialidades();
              } on DioException catch (e) {
                _showError(e);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTratamiento() async {
    String nombre = '';
    String descripcion = '';
    String codigo = '';
    double precio = 0.0;
    int? especialidadSeleccionada = _selectedEspecialidadId;
    _selectedImage = null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar Tratamiento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                    child: _selectedImage == null
                        ?  Center(
                            child: Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: primaryColor),
                          )
                        : Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: especialidadSeleccionada,
                decoration: const InputDecoration(labelText: 'Especialidad'),
                items: _especialidades.map((esp) {
                  return DropdownMenuItem<int>(
                    value: esp.idEspecialidad,
                    child: Text(esp.nombre),
                  );
                }).toList(),
                onChanged: (val) => especialidadSeleccionada = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Código'),
                onChanged: (v) => codigo = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (v) => nombre = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (v) => descripcion = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                onChanged: (v) => precio = double.tryParse(v) ?? 0.0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                if (especialidadSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Seleccione una especialidad")),
                  );
                  return;
                }

                final nuevo = Tratamiento(
                  idTratamiento: 0,
                  codigo: codigo,
                  nombre: nombre,
                  descripcion: descripcion,
                  precio: precio,
                  idEspecialidad: especialidadSeleccionada!,
                  fechaCreacion: DateTime.now(),
                );
                await _service.createTratamiento(nuevo,
                    imagenFile: _selectedImage);
                Navigator.pop(context);
                _loadTratamientos();
              } on DioException catch (e) {
                _showError(e);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

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
    final tratamientosFiltrados = _selectedEspecialidadId != null
        ? _tratamientos
            .where((t) => t.idEspecialidad == _selectedEspecialidadId)
            .toList()
        : _tratamientos;

    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.65),
      appBar: AppBar(
        title: const Text('Especialidades y Tratamientos',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                            ? 'http://192.168.1.20:3000${t.imagen}'
                            : null;
                        return Card(
                          elevation: 3,
                          margin:
                              const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                                                const Icon(Icons.broken_image,
                                                    color: Colors.grey),
                                      )
                                    : const Icon(Icons.image_not_supported,
                                        color: Colors.grey),
                              ),
                            ),
                            title: Text(t.nombre),
                            subtitle: Text(
                                '${t.descripcion ?? ''}\nCódigo: ${t.codigo ?? 'N/A'}'),
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
        distance: 70.0,
        children: [
          FloatingActionButton.small(
            heroTag: 'btn1',
            backgroundColor: primaryColor,
            onPressed: _addEspecialidad,
            child: const Icon(Icons.category_outlined),
          ),
          FloatingActionButton.small(
            heroTag: 'btn2',
            backgroundColor: primaryColor,
            onPressed: _addTratamiento,
            child: const Icon(Icons.add_circle_outline),
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
  const ExpandableFab({super.key, required this.distance, required this.children});

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnimation = CurvedAnimation(curve: Curves.fastOutSlowIn, parent: _controller);
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
              child: GestureDetector(onTap: _toggle, child: Container(color: Colors.transparent)),
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
            final offset = Offset(0, (i + 1) * widget.distance * _expandAnimation.value);
            return Positioned(
              right: 4,
              bottom: offset.dy,
              child: Transform.scale(scale: _expandAnimation.value, child: child),
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