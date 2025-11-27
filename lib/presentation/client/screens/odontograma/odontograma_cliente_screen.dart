import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/employed/odontograma_services.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_detalle_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontocolor_model.dart';

class OdontogramaClienteScreen extends StatefulWidget {
  const OdontogramaClienteScreen({super.key});

  @override
  State<OdontogramaClienteScreen> createState() =>
      _OdontogramaClienteScreenState();
}

class _OdontogramaClienteScreenState extends State<OdontogramaClienteScreen> {
  final OdontogramaService _service = OdontogramaService();

  Odontograma? _odontograma;
  List<OdontoColor> _colores = [];

  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargarOdontograma();
  }

  Future<void> _cargarOdontograma() async {
    try {
      final cliente = SessionApp.usuarioActual;

      if (cliente == null) {
        setState(() {
          _error = true;
          _cargando = false;
        });
        return;
      }

      final odo =
          await _service.obtenerOdontogramaPorCliente(cliente.idCliente);
      final colores = await _service.obtenerColores();

      setState(() {
        _odontograma = odo;
        _colores = colores;
        _cargando = false;
      });
    } catch (e) {
      debugPrint("Error cargando odontograma: $e");
      setState(() {
        _error = true;
        _cargando = false;
      });
    }
  }

  // *************************************
  // ORDENAR DIENTES SUPERIORES
  // *************************************
  List<OdontogramaDetalle> _superiores() {
    if (_odontograma == null) return [];

    return _odontograma!.detalles
        .where(
          (d) =>
              int.parse(d.diente?.dienteNumero ?? '0') >= 11 &&
              int.parse(d.diente?.dienteNumero ?? '0') <= 28,
        )
        .toList()
      ..sort(
        (a, b) => int.parse(a.diente?.dienteNumero ?? '0')
            .compareTo(int.parse(b.diente?.dienteNumero ?? '0')),
      );
  }

  // *************************************
  // ORDENAR DIENTES INFERIORES
  // *************************************
  List<OdontogramaDetalle> _inferiores() {
    if (_odontograma == null) return [];

    return _odontograma!.detalles
        .where(
          (d) =>
              int.parse(d.diente?.dienteNumero ?? '0') >= 31 &&
              int.parse(d.diente?.dienteNumero ?? '0') <= 48,
        )
        .toList()
      ..sort(
        (a, b) => int.parse(a.diente?.dienteNumero ?? '0')
            .compareTo(int.parse(b.diente?.dienteNumero ?? '0')),
      );
  }

  // *************************************
  // DIBUJAR UN DIENTE
  // *************************************
  Widget _dienteItem(OdontogramaDetalle det) {
    final hex = det.color?.colorHex ?? "#DDDDDD";

    Color color;
    try {
      color = Color(int.parse("FF${hex.replaceAll('#', '')}", radix: 16));
    } catch (_) {
      color = Colors.grey;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: Text(
            det.diente?.dienteNumero ?? '',
            style: const TextStyle(fontSize: 10, color: Colors.black),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            det.color?.colorNombre ?? "Sin color",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  // *************************************
  // LEYENDA DE COLORES
  // *************************************
  Widget _buildColorLegend() {
    if (_colores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text(
          "Significado de colores",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // LISTA DE TARJETAS
        Column(
          children: _colores.map((c) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  // círculo del color
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _parseColor(c.colorHex),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // nombre + significado
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.colorNombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.significadoClinico,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || !hex.startsWith('#')) return Colors.grey;
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  // *************************************
  // PANTALLA PRINCIPAL
  // *************************************
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Odontograma")),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _odontograma == null || _error
              ? const Center(child: Text("No se pudo cargar el odontograma."))
              : _buildOdontogramaVisual(),
    );
  }

  // *************************************
  // CUERPO CON FORMA DE U
  // *************************************
  Widget _buildOdontogramaVisual() {
    final sup = _superiores();
    final inf = _inferiores();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // tarjeta del usuario
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(SessionApp.usuarioActual?.nombreCompleto ?? ""),
              subtitle: Text(
                "Odontograma #${_odontograma!.idOdontograma}\n"
                "${_odontograma!.observacionesGenerales}",
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text("Dientes Superiores",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: sup.map((d) => _dienteItem(d)).toList(),
          ),

          const SizedBox(height: 35),

          const Text("Dientes Inferiores",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: inf.map((d) => _dienteItem(d)).toList(),
          ),

          // LEYENDA DE COLORES
          _buildColorLegend(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
