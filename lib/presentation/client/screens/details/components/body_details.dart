//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
import 'package:prototipo1_app/presentation/client/Components/employee/recomend_treatment.dart';
import 'package:prototipo1_app/presentation/client/Components/title_with_custom_underline.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:prototipo1_app/presentation/client/screens/citas/agendar_cita_screen.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class BodyDetails extends StatefulWidget {
  final int idEspecialidad;
  final String nombreEspecialidad;
  final String? imagenEspecialidad;
  final Cliente? clienteOverride;


  const BodyDetails({
    super.key,
    required this.idEspecialidad,
    required this.nombreEspecialidad,
    this.imagenEspecialidad,
    this.clienteOverride,
  });

  @override
  State<BodyDetails> createState() => _BodyDetailsState();
}

class _BodyDetailsState extends State<BodyDetails> {
  final TratamientosService _service = TratamientosService();
  late Future<List<Tratamiento>> _futureTratamientos;

  @override
  void initState() {
    super.initState();
    _futureTratamientos = _loadTratamientos();
    
  }

  Future<List<Tratamiento>> _loadTratamientos() async {
    final all = await _service.getAllTratamientos();
    return all.where((t) => t.idEspecialidad == widget.idEspecialidad).toList();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['ENDPOINT_API6'] ?? ' ';
    final imageUrl = widget.imagenEspecialidad != null
        //? 'http://192.168.1.20:3000${widget.imagenEspecialidad}'
        ? '$baseUrl${widget.imagenEspecialidad}'
        : 'assets/images/placeholder.png';

    final primaryColor = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Imagen principal con altura moderada
          Stack(
            children: [
              Container(
                height: size.height * 0.27,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl)
                        : AssetImage(imageUrl) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.nombreEspecialidad,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: TitleWithCustomUnderline(text: 'Tratamientos Disponibles'),
          ),
          const SizedBox(height: 5),

          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<Tratamiento>>(
              future: _futureTratamientos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar tratamientos: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final tratamientos = snapshot.data ?? [];
                if (tratamientos.isEmpty) {
                  return const Center(
                    child: Text('No hay tratamientos para esta especialidad.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tratamientos.length,
                  itemBuilder: (context, index) {
                    final t = tratamientos[index];
                    final imageUrl = t.imagen != null
                        //? 'http://192.168.1.20:3000${t.imagen}'
                        ? '$baseUrl${t.imagen}'
                        : 'assets/images/placeholder.png';

                    return RecomendTreatment(
                      primaryColor: primaryColor,
                      imageUrl: imageUrl,
                      t: t,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AgendarCitaScreen(tratamiento: t, clienteOverride: widget.clienteOverride),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
