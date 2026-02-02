import 'package:prototipo1_app/config/citas/citas_service.dart';
import 'package:prototipo1_app/config/client/session.dart';

class Appointment {
  final int idCita;
  final DateTime date;
  final String estado;
  final String time;
  final bool eliminado;
  final int idTratamiento;
  final String? nombreTratamiento;

  Appointment({
    required this.idCita,
    required this.date,
    required this.estado,
    required this.time,
    required this.eliminado,
    required this.idTratamiento,
    this.nombreTratamiento,
  });
}

class CalendarHelper {
  // ==============================
  // Cargar citas del cliente
  // ==============================
  static Future<List<Appointment>> cargarCitasCliente() async {
    final cliente = SessionApp.usuarioActual;
    if (cliente == null) return [];

    final service = CitasService();
    final citas = await service.obtenerCitasPorCliente(cliente.idCliente);

    return citas.map((c) {
      return Appointment(
        idCita: c.idCita!,
        date: DateTime.parse(c.fecha),
        time: c.horaInicio.substring(0, 5),
        eliminado: c.eliminado,
        estado: mapEstado(c.estado, c.eliminado),
        idTratamiento: c.idTratamiento,
        nombreTratamiento: c.nombreTratamiento,
      );
    }).toList();
  }

  static Future<void> cancelarCita(int idCita) async {
    final service = CitasService();
    await service.cancelar(idCita);
  }

  // ==============================
  // Mapeo de estado
  // ==============================
  static String mapEstado(String? estado, bool eliminado) {
    if (eliminado) return 'Cancelada';
    switch (estado) {
      case 'asistio':
        return 'Asistió';
      case 'no_asistio':
        return 'No asistió';
      default:
        return 'Pendiente';
    }
  }

  // ==============================
  // Días del mes
  // ==============================
  static List<DateTime> getDaysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  // ==============================
  // Nombre del mes
  // ==============================
  static String getMonthName(int month) {
    const names = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return names[month - 1];
  }

  // ==============================
  // Filtrar citas del mes
  // ==============================
  static List<Appointment> filtrarPorMes(
    List<Appointment> appointments,
    DateTime month,
  ) {
    final filtered = appointments
        .where((a) => a.date.month == month.month && a.date.year == month.year)
        .toList();

    filtered.sort((a, b) {
      // Pendientes primero
      final aPendiente = a.estado == 'Pendiente';
      final bPendiente = b.estado == 'Pendiente';

      if (aPendiente && !bPendiente) return -1;
      if (!aPendiente && bPendiente) return 1;

      // Fecha + hora (descendente)
      final dateA = DateTime(
        a.date.year,
        a.date.month,
        a.date.day,
        int.parse(a.time.split(':')[0]),
        int.parse(a.time.split(':')[1]),
      );

      final dateB = DateTime(
        b.date.year,
        b.date.month,
        b.date.day,
        int.parse(b.time.split(':')[0]),
        int.parse(b.time.split(':')[1]),
      );

      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  

  // ==============================
  // Verificar si un día tiene cita
  // ==============================
  static bool hasAppointment(List<Appointment> appointments, DateTime day) {
    return appointments.any(
      (a) =>
          a.date.year == day.year &&
          a.date.month == day.month &&
          a.date.day == day.day,
    );
  }
}
