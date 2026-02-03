import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prototipo1_app/config/citas/citas_service.dart';
import 'package:prototipo1_app/config/citas/dtos/cita_entity.dart';
import 'package:prototipo1_app/config/client/client_service.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';

class GestionCitasScreen extends StatefulWidget {
  const GestionCitasScreen({super.key});

  @override
  State<GestionCitasScreen> createState() => _GestionCitasScreenState();
}

class _GestionCitasScreenState extends State<GestionCitasScreen> {
  final _service = CitasService();
  final _clientService = ClientService();
Map<int, Cliente> _clientesMap = {};


  bool _loading = true;
  List<CitaEntity> _todas = [];

  // Filtros
  bool _modoMes = false; // false = día, true = mes
  DateTime _selectedDate = DateTime.now(); // día seleccionado (por defecto hoy)
  int? _selectedMonth; // si modoMes = true
  int? _selectedYear;  // si modoMes = true

  String _estadoFiltro = 'todos'; // 'todos' o uno de: pendiente/asistio/no_asistio/cancelada/reagendada

  final _fmtDate = DateFormat('yyyy-MM-dd');
  final _fmtTime = DateFormat('HH:mm');
  final _fmtMonth = DateFormat('MMMM yyyy', 'es');

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    _cargar();
  }

  Future<void> _cargar() async {
  setState(() => _loading = true);

  try {
    final citas = await _service.consultarTodas();
    final clientes = await _clientService.getAllClientes();

    final map = {for (var c in clientes) c.idCliente: c};

    setState(() {
      _todas = citas;
      _clientesMap = map;
      _loading = false;
    });
  } catch (_) {
    setState(() => _loading = false);
  }
}


  // =============================
  // Helpers: extraer campos (ajusta aquí según tu CitaEntity)
  // =============================
  int _getId(CitaEntity c) {
    // AJUSTA si tu entidad tiene otro nombre
    // ejemplo: c.idCita, c.id, c.IdCita...
    return (c as dynamic).idCita ?? (c as dynamic).id ?? 0;
  }

  DateTime _getFecha(CitaEntity c) {
  return DateTime.parse('${c.fecha}T${c.horaInicio}');
}


  String _getEstado(CitaEntity c) {
    // AJUSTA: estado, Estado, estadoCita...
    final e = (c as dynamic).estado ?? (c as dynamic).Estado ?? 'pendiente';
    return (e as String).toLowerCase();
  }

 String _getTitulo(CitaEntity c) {
  final cliente = _clientesMap[c.idCliente];
  final nombreCliente = cliente?.nombreCompleto ?? 'Cliente';

  return '$nombreCliente • ${c.nombreTratamiento}';
}


  // =============================
  // Filtrado + agrupación
  // =============================
  List<CitaEntity> get _filtradas {
    final list = _todas.where((c) {
      final fecha = _getFecha(c);
      final estado = _getEstado(c);

      // filtro por día o mes
      final matchFecha = _modoMes
          ? (fecha.year == _selectedYear && fecha.month == _selectedMonth)
          : (_isSameDay(fecha, _selectedDate));

      // filtro por estado
      final matchEstado = _estadoFiltro == 'todos' ? true : (estado == _estadoFiltro);

      return matchFecha && matchEstado;
    }).toList();

    // orden: por fecha/hora
    list.sort((a, b) => _getFecha(a).compareTo(_getFecha(b)));
    return list;
  }

  Map<String, List<CitaEntity>> get _agrupadasPorDia {
    final map = <String, List<CitaEntity>>{};
    for (final c in _filtradas) {
      final key = _fmtDate.format(_getFecha(c));
      map.putIfAbsent(key, () => []);
      map[key]!.add(c);
    }
    return map;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // =============================
  // UI: estado -> etiqueta + color
  // =============================
  String _labelEstado(String estado) {
    switch (estado) {
      case 'asistio':
        return 'Asistió';
      case 'no_asistio':
        return 'No asistió';
      case 'cancelada':
        return 'Cancelada';
      case 'reagendada':
        return 'Reagendada';
      default:
        return 'Pendiente';
    }
  }

  Color _colorEstado(String estado, ColorScheme cs) {
    // Pediste: pendiente -> secondary, asistio -> primary, no_asistio -> rojo, cancelada -> gris
    switch (estado) {
      case 'asistio':
        return cs.primary;
      case 'no_asistio':
        return Colors.red;
      case 'cancelada':
        return Colors.grey;
      case 'reagendada':
        return Colors.deepPurple;
      default:
        return cs.secondary;
    }
  }

  // =============================
  // Cambiar estado (con confirmación)
  // =============================
  Future<void> _confirmarYActualizarEstado(CitaEntity cita, String nuevoEstado) async {
    final actual = _getEstado(cita);
    final cs = Theme.of(context).colorScheme;

    String mensaje;
    if (nuevoEstado == 'asistio') {
      mensaje = '¿Está seguro que desea registrar la asistencia de esta cita?';
    } else if (nuevoEstado == 'no_asistio') {
      mensaje = '¿Está seguro que desea registrar que el paciente NO asistió?';
    } else if (nuevoEstado == 'cancelada') {
      mensaje = '¿Está seguro que desea CANCELAR esta cita?';
    } else {
      mensaje = '¿Está seguro que desea cambiar el estado de la cita?';
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar cambio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Estado actual: ', style: TextStyle(color: cs.onSurfaceVariant)),
                Chip(
                  label: Text(_labelEstado(actual)),
                  backgroundColor: _colorEstado(actual, cs).withOpacity(0.12),
                  side: BorderSide(color: _colorEstado(actual, cs).withOpacity(0.4)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Nuevo estado: ', style: TextStyle(color: cs.onSurfaceVariant)),
                Chip(
                  label: Text(_labelEstado(nuevoEstado)),
                  backgroundColor: _colorEstado(nuevoEstado, cs).withOpacity(0.12),
                  side: BorderSide(color: _colorEstado(nuevoEstado, cs).withOpacity(0.4)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, confirmar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // Ejecutar cambio
    try {
      final id = _getId(cita);

      // Tú pediste 3 estados a cambiar: asistio / no_asistio / cancelada
      if (nuevoEstado == 'asistio') {
        await _service.actualizarCita(id, {'estado': 'asistio'});
      } else if (nuevoEstado == 'no_asistio') {
        await _service.noasistio(id); // tu servicio lo hace por endpoint
      } else if (nuevoEstado == 'cancelada') {
        await _service.cancelar(id);
      } else {
        await _service.actualizarCita(id, {'estado': nuevoEstado});
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "${_labelEstado(nuevoEstado)}"')),
      );

      await _cargar(); // refrescar lista
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el estado')),
      );
    }
  }

  // =============================
  // Date pickers
  // =============================
  Future<void> _pickDia() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _modoMes = false;
      _selectedDate = picked;
    });
  }

  Future<void> _pickMes() async {
    // Usamos un datePicker normal pero solo guardamos mes/año
    final base = DateTime(_selectedYear ?? DateTime.now().year, _selectedMonth ?? DateTime.now().month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2100, 12),
      helpText: 'Selecciona cualquier día del mes',
    );
    if (picked == null) return;
    setState(() {
      _modoMes = true;
      _selectedMonth = picked.month;
      _selectedYear = picked.year;
    });
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Gestión de Citas'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _filtersBar(context),
                  const SizedBox(height: 6),
                  Expanded(
                    child: _filtradas.isEmpty
                        ? _emptyState(cs)
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            children: _buildGroupedList(cs),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _filtersBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final titleFecha = _modoMes
        ? _fmtMonth.format(DateTime(_selectedYear ?? DateTime.now().year, _selectedMonth ?? DateTime.now().month, 1))
        : DateFormat("EEEE, d MMM yyyy", "es").format(_selectedDate);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header filtros
          Row(
            children: [
              Icon(Icons.calendar_month, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titleFecha,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Día')),
                  ButtonSegment(value: true, label: Text('Mes')),
                ],
                selected: {_modoMes},
                onSelectionChanged: (s) {
                  final v = s.first;
                  setState(() => _modoMes = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Botones de selección fecha
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _modoMes ? _pickMes : _pickDia,
                  icon: const Icon(Icons.edit_calendar),
                  label: Text(_modoMes ? 'Cambiar mes' : 'Cambiar día'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _selectedMonth = DateTime.now().month;
                    _selectedYear = DateTime.now().year;
                  });
                },
                child: const Text('Hoy'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Chips estado
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chipEstado('todos', 'Todos', cs),
                _chipEstado('pendiente', 'Pendiente', cs),
                _chipEstado('asistio', 'Asistió', cs),
                _chipEstado('no_asistio', 'No asistió', cs),
                _chipEstado('cancelada', 'Cancelada', cs),
                _chipEstado('reagendada', 'Reagendada', cs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipEstado(String value, String label, ColorScheme cs) {
    final selected = _estadoFiltro == value;
    final color = value == 'todos' ? cs.primary : _colorEstado(value, cs);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        selectedColor: color.withOpacity(0.14),
        onSelected: (_) => setState(() => _estadoFiltro = value),
        side: BorderSide(color: selected ? color.withOpacity(0.6) : Colors.black.withOpacity(0.12)),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? color : cs.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme cs) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 44, color: cs.onSurfaceVariant),
            const SizedBox(height: 10),
            const Text(
              'No hay citas para el filtro seleccionado',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Prueba cambiando el día/mes o el estado.',
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedList(ColorScheme cs) {
    final groups = _agrupadasPorDia;
    final keys = groups.keys.toList()..sort();

    final widgets = <Widget>[];

    for (final dayKey in keys) {
      final dayDate = DateTime.tryParse(dayKey) ?? DateTime.now();
      final title = DateFormat("EEEE, d MMM yyyy", "es").format(dayDate);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );

      for (final cita in groups[dayKey]!) {
        widgets.add(_citaCard(cita, cs));
      }
    }

    return widgets;
  }

  Widget _citaCard(CitaEntity cita, ColorScheme cs) {
    final fecha = _getFecha(cita);
    final estado = _getEstado(cita);
    final colorEstado = _colorEstado(estado, cs);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        title: Text(
          _getTitulo(cita),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(_fmtTime.format(fecha), style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colorEstado.withOpacity(0.45)),
                ),
                child: Text(
                  _labelEstado(estado),
                  style: TextStyle(fontWeight: FontWeight.w700, color: colorEstado),
                ),
              ),
            ],
          ),
        ),
        trailing: _menuEstados(cita, cs),
      ),
    );
  }

  Widget _menuEstados(CitaEntity cita, ColorScheme cs) {
    // Solo permitimos cambiar a 3 estados (como pediste)
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
      onSelected: (value) => _confirmarYActualizarEstado(cita, value),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'asistio',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: cs.primary),
              const SizedBox(width: 10),
              const Text('Marcar como Asistió'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'no_asistio',
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 10),
              Text('Marcar como No asistió'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'cancelada',
          child: Row(
            children: [
              Icon(Icons.block, color: Colors.grey),
              SizedBox(width: 10),
              Text('Marcar como Cancelada'),
            ],
          ),
        ),
      ],
    );
  }
}
