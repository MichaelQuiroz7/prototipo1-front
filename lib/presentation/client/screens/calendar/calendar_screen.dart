import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
import 'package:prototipo1_app/presentation/client/Components/my_bottom_nav_bar.dart';
import 'package:prototipo1_app/presentation/client/providers/helper/calendar helper/calendar_helper.dart';
import 'package:prototipo1_app/presentation/client/screens/citas/agendar_cita_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime currentMonth = DateTime.now();
  List<Appointment> appointments = [];

  Appointment? _selectedAppointment; // estado global del widget

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await CalendarHelper.cargarCitasCliente();
    setState(() => appointments = data);
  }

  @override
  Widget build(BuildContext context) {
    final days = CalendarHelper.getDaysInMonth(currentMonth);

    return Scaffold(
      appBar: AppBar(title: const Text('Citas reservadas')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() => _selectedAppointment = null);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _monthHeader(),
              const SizedBox(height: 12),
              _calendarGrid(days),
              const SizedBox(height: 20),
              const Text(
                'Citas del mes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _appointmentList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }

  // ---------------------------------------------------------------------------
  // Header mes
  // ---------------------------------------------------------------------------
  Widget _monthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
            });
          },
        ),
        Text(
          '${CalendarHelper.getMonthName(currentMonth.month)} ${currentMonth.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Calendario
  // ---------------------------------------------------------------------------
  Widget _calendarGrid(List<DateTime> days) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, index) {
        final day = days[index];
        final hasAppointment = CalendarHelper.hasAppointment(appointments, day);

        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('${day.day}'),
              if (hasAppointment)
                const Positioned(
                  bottom: 4,
                  child: Icon(Icons.star, size: 16, color: Colors.orange),
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Lista de citas
  // ---------------------------------------------------------------------------
  Widget _appointmentList() {
    final filtered = CalendarHelper.filtrarPorMes(appointments, currentMonth);

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No hay citas este mes.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: filtered.map((a) {
        final isSelected = _selectedAppointment == a;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAppointment = isSelected ? null : a;
            });
          },
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.medical_services,
                    color: Colors.blue,
                  ),
                  title: Text('Estado: ${a.estado}\n${a.nombreTratamiento ?? ''}'),
                  subtitle: Text(
                    '${a.date.day}/${a.date.month}/${a.date.year} - ${a.time}',
                  ),
                ),
              ),

              // Botones 
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.schedule),
                        label: const Text('Reagendar'),
                        onPressed: () => _reagendarCita(a),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: a.eliminado ? null : () => _cancelarCita(a),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------
  void _reagendarCita(Appointment cita) async {
  final tratamientoService = TratamientosService();

  final tratamiento = await tratamientoService.getTratamientoById(
    cita.idTratamiento,
  );

  if (tratamiento == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo cargar el tratamiento de la cita'),
      ),
    );
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AgendarCitaScreen(
        tratamiento: tratamiento, 
        citaExistente: cita,
      ),
    ),
  );

  await _load(); 
}


  Future<void> _cancelarCita(Appointment cita) async {
    try {
      await CalendarHelper.cancelarCita(cita.idCita);

      setState(() {
        _selectedAppointment = null;
      });

      await _load(); // recargar citas desde backend

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada correctamente')),
      );
    } catch (e) {
      debugPrint('Error cancelando cita: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cancelar la cita')),
      );
    }
  }
}
