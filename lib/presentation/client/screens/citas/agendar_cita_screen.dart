import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/citas/citas_service.dart';
import 'package:prototipo1_app/config/citas/dtos/cita_entity.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/presentation/client/dtoCitas/cita_model.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:prototipo1_app/presentation/client/providers/helper/calendar helper/calendar_helper.dart';
import 'package:prototipo1_app/presentation/client/screens/utils/cita_utils.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';
import 'package:prototipo1_app/util/notification_service.dart';

class AgendarCitaScreen extends StatefulWidget {
  final Tratamiento tratamiento;
  final Cliente? clienteOverride;

  final Appointment? citaExistente;

  const AgendarCitaScreen({
    super.key,
    required this.tratamiento,
    this.citaExistente,
    this.clienteOverride,
  });

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  DateTime selectedDate = CitaUtils.getInitialValidDate(DateTime.now());

  TimeSlot? selectedSlot;

  final List<TimeSlot> slots = [];

  @override
  void initState() {
    super.initState();
    slots.addAll(generateTimeSlots());
    _recargarHorarios();
  }

  // ===========================================================================
  // RECARGAR HORARIOS
  // ===========================================================================
  Future<void> _recargarHorarios() async {
    await CitaUtils.bloquearHorariosOcupados(
      selectedDate: selectedDate,
      slots: slots,
    );
    setState(() {});
  }

  // ===========================================================================
  // CAMBIAR A HOY (PRIMER DÍA DISPONIBLE)
  // ===========================================================================
  Future<void> _irAHoy() async {
    setState(() {
      selectedDate = CitaUtils.getInitialValidDate(DateTime.now());
      selectedSlot = null;
      slots
        ..clear()
        ..addAll(generateTimeSlots());
    });

    await _recargarHorarios();
  }

  // ===========================================================================
  // AVANZAR AL SIGUIENTE DÍA LABORAL
  // ===========================================================================
  Future<void> _irAlSiguienteDia() async {
    DateTime next = selectedDate.add(const Duration(days: 1));

    // Saltar días no laborables
    while (!CitaUtils.esDiaLaboral(next)) {
      next = next.add(const Duration(days: 1));
    }

    setState(() {
      selectedDate = next;
      selectedSlot = null;
      slots
        ..clear()
        ..addAll(generateTimeSlots());
    });

    await _recargarHorarios();
  }

  // ===========================================================================
  // SELECCIONAR FECHA
  // ===========================================================================
  Future<void> _selectDate() async {
    //final now = CitaUtils.getInitialValidDate(DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: CitaUtils.getInitialValidDate(selectedDate),
      firstDate: CitaUtils.getInitialValidDate(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      selectableDayPredicate: CitaUtils.esDiaLaboral,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedSlot = null;
        slots
          ..clear()
          ..addAll(generateTimeSlots());
      });

      await _recargarHorarios();
    }
  }

  // ===========================================================================
  // CONFIRMAR CITA
  // ===========================================================================
  Future<void> _confirmAppointment() async {
    final cliente = widget.clienteOverride ?? SessionApp.usuarioActual;

    if (cliente == null || selectedSlot == null) return;

    // VALIDAR DISPONIBILIDAD EN TIEMPO REAL
    final disponible = await CitaUtils.horarioSigueDisponible(
      selectedDate: selectedDate,
      slot: selectedSlot!,
    );

    if (!disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            ' Este horario acaba de ser reservado. Seleccione otro.',
          ),
        ),
      );

      setState(() => selectedSlot = null);
      await _recargarHorarios();
      return;
    }

    final citasService = CitasService();

    try {
      final citasCliente = await citasService.obtenerCitasPorCliente(
        cliente.idCliente,
      );

      final tienePendiente = citasCliente.any((c) => c.estado == 'pendiente');

      if (widget.citaExistente == null && tienePendiente) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ya tienes una cita pendiente. Asiste o reagenda antes de crear otra.',
            ),
          ),
        );
        return;
      }

      // ===========================
      //  NOTIFICACIONES
      // ===========================
      final int notificationBaseId = cliente.idCliente * 1000;

      final String fechaTexto =
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}';

      final String horaInicio = CitaUtils.formatTime(
        selectedSlot!.start,
      ).substring(0, 5);

      final String horaFin = CitaUtils.formatTime(
        selectedSlot!.end,
      ).substring(0, 5);

      final String bodyNotificacion =
          '📅 Fecha: $fechaTexto\n⏰ Hora: $horaInicio - $horaFin';

      // Cancelar notificaciones previas
      await NotificationService.cancel(notificationBaseId);
      await NotificationService.cancel(notificationBaseId + 1);

      // Reagendamiento
      if (widget.citaExistente != null) {
        await citasService.reagendar(widget.citaExistente!.idCita);
      }
      final cita = CitaEntity(
        idCliente: cliente.idCliente,
        idTratamiento: widget.tratamiento.idTratamiento,
        nombreTratamiento: widget.tratamiento.nombre,
        precio: widget.tratamiento.precio,
        fecha:
            "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
        horaInicio: CitaUtils.formatTime(selectedSlot!.start),
        horaFin: CitaUtils.formatTime(selectedSlot!.end),
        estado: 'pendiente',
      );

      // Crear cita usando el modelo
      await citasService.crearCita(cita.toJson());

      // Programar notificaciones (07:00)
      await NotificationService().scheduleBeforeAndOnDate(
        baseId: notificationBaseId,
        title: 'Perfect Teeth 🦷',
        body: 'Tienes una cita odontológica programada \n$bodyNotificacion',
        targetDate: selectedDate,
        hour: 21,
        minute: 10,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cita registrada correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar la cita')),
      );
    }
  }

  // ===========================================================================
  // UI
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tratamiento.nombre,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '\$${widget.tratamiento.precio.toStringAsFixed(2)}\nDeberá cancelar después de ser atendido.',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),

                TextButton(
                  onPressed: _selectDate,
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const Spacer(),

                OutlinedButton(onPressed: _irAHoy, child: const Text('hoy')),

                const SizedBox(width: 8),

                OutlinedButton(
                  onPressed: _irAlSiguienteDia,
                  child: const Text('Siguiente día'),
                ),
              ],
            ),

            const SizedBox(height: 15),
            const Text(
              'Horarios disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                itemCount: slots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final slot = slots[index];
                  final isSelected = selectedSlot == slot;

                  return GestureDetector(
                    onTap: slot.isAvailable
                        ? () => setState(() => selectedSlot = slot)
                        : null,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !slot.isAvailable
                            ? Colors.grey.shade300
                            : isSelected
                            ? primaryColor
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        slot.label,
                        style: TextStyle(
                          color: !slot.isAvailable
                              ? Colors.grey
                              : isSelected
                              ? Colors.white
                              : primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: selectedSlot == null ? null : _confirmAppointment,
              child: const Text('Confirmar cita'),
            ),
          ],
        ),
      ),
    );
  }
}
