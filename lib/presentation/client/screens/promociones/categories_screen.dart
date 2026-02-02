import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
import 'package:prototipo1_app/presentation/client/Components/category_card.dart';
import 'package:prototipo1_app/presentation/employee/dto/especialidad_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TratamientosService _service = TratamientosService();

  List<Especialidad> especialidades = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEspecialidades();
  }

  Future<void> _loadEspecialidades() async {
    try {
      final data = await _service.getAllEspecialidades();

      setState(() {
        especialidades = data.where((e) => !e.eliminado).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar especialidades";
        isLoading = false;
      });
    }
  }


  @override
Widget build(BuildContext context) {
  // final primary = Theme.of(context).colorScheme.primary;

  return Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      title: const Text("Especialidades"),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
    body: Stack(
  children: [
    // Fondo degradado
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            const Color(0xFF4FB6FF),
            const Color(0xFFB7E7FF),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    ),

    // “Textura” suave (sin imagen)
    Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.7, -0.6),
            radius: 1.2,
            colors: [
              Colors.white.withOpacity(0.10),
              Colors.transparent,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    ),

    // Contenido
    _buildBody(),
  ],
),

  );
}


  Widget _buildBody() {
    final baseUrl = dotenv.env['ENDPOINT_API6'] ?? '';
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (especialidades.isEmpty) {
      return const Center(child: Text("No hay especialidades disponibles"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        
        int crossAxisCount = 2;

        if (constraints.maxWidth > 900) {
          crossAxisCount = 4; // tablet grande
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3; // tablet
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: especialidades.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final especialidad = especialidades[index];
              
              final imageUrl =
                  (especialidad.imagen != null &&
                      especialidad.imagen!.isNotEmpty)
                  ? "$baseUrl${especialidad.imagen}"
                  : null;

              return CategoryCard(
                title: especialidad.nombre,
                imageUrl: imageUrl,
                tratamientos: especialidad.tratamientos ?? [],
              );
            },
          ),
        );
      },
    );
  }
}
