import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/employed/odontograma_services.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_detalle_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontocolor_model.dart';


class EditorOdontogramaScreen extends StatefulWidget {
  final Cliente cliente;

  const EditorOdontogramaScreen({
    super.key,
    required this.cliente,
  });

  @override
  State<EditorOdontogramaScreen> createState() => _EditorOdontogramaScreenState();
}

class _EditorOdontogramaScreenState extends State<EditorOdontogramaScreen> {
  final OdontogramaService _service = OdontogramaService();

  Odontograma? _odontograma;
  List<OdontoColor> _colores = [];

  bool _cargando = true;
  bool _error = false;

  int? _cuadranteSeleccionado;
  final Set<int> _detallesModificados = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = false;
    });

    try {
      final odo = await _service.obtenerOdontogramaPorCliente(widget.cliente.idCliente);
      final colores = await _service.obtenerColores();

      setState(() {
        _odontograma = odo;
        _colores = colores.where((c) => !c.eliminado).toList();
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando odontograma: $e');
      setState(() {
        _error = true;
        _cargando = false;
      });
    }
  }

  List<OdontogramaDetalle> get _detallesFiltrados {
    if (_odontograma == null || _cuadranteSeleccionado == null) return [];

    final detalles = _odontograma!.detalles.where((det) {
      final cuadrante = det.diente?.cuadrante;
      return cuadrante == _cuadranteSeleccionado;
    }).toList();

    detalles.sort((a, b) {
      final na = a.diente?.dienteNumero ?? '';
      final nb = b.diente?.dienteNumero ?? '';
      return na.compareTo(nb);
    });

    return detalles;
  }

  Color _colorDesdeHex(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      final limpia = hex.replaceAll('#', '');
      return Color(int.parse('FF$limpia', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  String _nombreCuadrante(int cuadrante) {
    switch (cuadrante) {
      case 1:
        return 'Sup. Der.';
      case 2:
        return 'Sup. Izq.';
      case 3:
        return 'Inf. Izq.';
      case 4:
        return 'Inf. Der.';
      default:
        return 'Cuadrante $cuadrante';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Odontograma de ${widget.cliente.nombreCompleto}'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBody() {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    if (_error || _odontograma == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudo cargar el odontograma'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _cargarDatos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildInfoCabecera(),
          const SizedBox(height: 12),
          _buildCuadrantesGrid(),
          const SizedBox(height: 12),
          Expanded(child: _buildListaDientes()),
        ],
      ),
    );
  }

  Widget _buildInfoCabecera() {
    return Card(
      child: ListTile(
        title: Text(widget.cliente.nombreCompleto),
        subtitle: Text(
          'Odontograma #${_odontograma!.idOdontograma} · '
          'Obs: ${_odontograma!.observacionesGenerales ?? 'Sin observaciones'}',
        ),
        leading: const Icon(Icons.person_outline),
      ),
    );
  }

  Widget _buildCuadrantesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona un cuadrante', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _buildCuadranteCard(1),
            _buildCuadranteCard(2),
            _buildCuadranteCard(3),
            _buildCuadranteCard(4),
          ],
        ),
      ],
    );
  }

  Widget _buildCuadranteCard(int cuadrante) {
    final seleccionado = _cuadranteSeleccionado == cuadrante;

    return GestureDetector(
      onTap: () {
        setState(() {
          _cuadranteSeleccionado = seleccionado ? null : cuadrante;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: seleccionado
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cuadrante $cuadrante',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: seleccionado
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black87,
                  )),
              const SizedBox(height: 4),
              Text(_nombreCuadrante(cuadrante),
                  style: TextStyle(
                    fontSize: 12,
                    color: seleccionado
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade700,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaDientes() {
    if (_cuadranteSeleccionado == null) {
      return const Center(child: Text('Selecciona un cuadrante para ver los dientes.'));
    }

    final detalles = _detallesFiltrados;

    if (detalles.isEmpty) {
      return Center(
        child: Text('No hay dientes registrados para el cuadrante $_cuadranteSeleccionado.'),
      );
    }

    return ListView.builder(
      itemCount: detalles.length,
      itemBuilder: (context, index) {
        final det = detalles[index];
        final diente = det.diente;
        final color = det.color;
        final colorVisual = _colorDesdeHex(color?.colorHex ?? '#CCCCCC');
        //print(det.color?.colorHex);
        //print("Diente ${det.diente?.dienteNumero} → ${det.color?.colorHex}");

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorVisual,
              child: Text(
                diente?.dienteNumero ?? '',
                style: const TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
            title: Text('${diente?.dienteNumero ?? '??'} - ${diente?.nombre ?? 'Diente'}'),
            subtitle: Text(
              'Estado: ${det.estado.isNotEmpty ? det.estado : 'Sin estado'}\n'
              'Color: ${color?.colorNombre ?? 'Sin color'}',
              maxLines: 2,
            ),
            trailing: const Icon(Icons.edit),
            onTap: () => _mostrarSelectorColor(det),
          ),
        );
      },
    );
  }

  void _mostrarSelectorColor(OdontogramaDetalle det) {
    if (_colores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay colores configurados.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar color para diente ${det.diente?.dienteNumero ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300, // evita conflictos con Expanded
                  child: ListView.builder(
                    itemCount: _colores.length,
                    itemBuilder: (context, index) {
                      final col = _colores[index];
                      final colorVisual = _colorDesdeHex(col.colorHex);

                      return ListTile(
                        leading: CircleAvatar(backgroundColor: colorVisual),
                        title: Text(col.colorNombre),
                        subtitle: Text(col.significadoClinico),
                        onTap: () {
                          setState(() {
                            det.idColor = col.idColor;
                            det.color = col;
                            det.estado = col.significadoClinico;
                            _detallesModificados.add(det.idDetalle);
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Regresar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar cambios'),
              onPressed: _detallesModificados.isEmpty ? null : _guardarCambios,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (_detallesModificados.isEmpty || _odontograma == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardando cambios...')));

    try {
      for (final idDetalle in _detallesModificados) {
        final det = _odontograma!.detalles.firstWhere(
          (d) => d.idDetalle == idDetalle,
        );

        await _service.actualizarDetalle(det.idDetalle, {
          'idColor': det.idColor,
          'estado': det.estado,
          'observacion': det.observacion ?? '',
        });
      }

      _detallesModificados.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados correctamente')),
      );
    } catch (e) {
      debugPrint('Error guardando cambios odontograma: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }
}
