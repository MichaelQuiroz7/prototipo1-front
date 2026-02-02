import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
import 'package:prototipo1_app/presentation/client/screens/details/details_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/citas/agendar_cita_screen.dart';
import 'package:prototipo1_app/presentation/employee/dto/especialidad_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class SelectorEspecialidadTratamientoSheet extends StatefulWidget {
  const SelectorEspecialidadTratamientoSheet({super.key});

  @override
  State<SelectorEspecialidadTratamientoSheet> createState() =>
      _SelectorEspecialidadTratamientoSheetState();
}

class _SelectorEspecialidadTratamientoSheetState
    extends State<SelectorEspecialidadTratamientoSheet> {
  final _service = TratamientosService();
  final _search = TextEditingController();

  List<Especialidad> especialidades = [];
  List<Tratamiento> tratamientos = [];
  String query = '';
  bool loading = true;

  final baseUrl = dotenv.env['ENDPOINT_API6'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final esp = await _service.getAllEspecialidades();
    final tra = await _service.getAllTratamientos();

    setState(() {
      especialidades = esp;
      tratamientos = tra;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = especialidades.where((e) {
      final matchEsp = e.nombre.toLowerCase().contains(query);
      final matchTrat = tratamientos.any((t) =>
          t.idEspecialidad == e.idEspecialidad &&
          t.nombre.toLowerCase().contains(query));
      return matchEsp || matchTrat;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecciona especialidad o tratamiento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _search,
            onChanged: (v) => setState(() => query = v.toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Buscar especialidad o tratamiento',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 10),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else
            SizedBox(
              height: 350,
              child: ListView(
                children: filtradas.map((esp) {
                  final tratamientosFiltrados = tratamientos
                      .where((t) =>
                          t.idEspecialidad == esp.idEspecialidad &&
                          t.nombre.toLowerCase().contains(query))
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.medical_services),
                        title: Text(esp.nombre),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(
                                idEspecialidad: esp.idEspecialidad,
                                nombreEspecialidad: esp.nombre,
                                imagenEspecialidad: esp.imagen ?? '',
                              ),
                            ),
                          );
                        },
                      ),

                      // 🔽 Tratamientos debajo
                      ...tratamientosFiltrados.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: ListTile(
                            leading: const Icon(Icons.arrow_right),
                            title: Text(t.nombre),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AgendarCitaScreen(tratamiento: t),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
