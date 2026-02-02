import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/citas/citas_service.dart';
import 'package:prototipo1_app/presentation/client/dtoCitas/cita_model.dart';

class CitaUtils {
  // ===============================
  // FECHAS
  // ===============================
  static DateTime getInitialValidDate(DateTime date) {
    DateTime d = date;

    while (d.weekday == DateTime.saturday ||
        d.weekday == DateTime.sunday) {
      d = d.add(const Duration(days: 1));
    }

    return d;
  }

  static bool esDiaLaboral(DateTime date) {
    return date.weekday != DateTime.saturday &&
        date.weekday != DateTime.sunday;
  }

  // ===============================
  // HORARIOS
  // ===============================
  static Future<void> bloquearHorariosOcupados({
    required DateTime selectedDate,
    required List<TimeSlot> slots,
  }) async {
    final citasService = CitasService();

    final fecha =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final citas = await citasService.obtenerTodasCitas();

    // Reset
    for (final slot in slots) {
      slot.isAvailable = true;
    }

    for (final cita in citas) {
      if (cita.fecha != fecha) continue;

      for (final slot in slots) {
        final inicio = formatTime(slot.start);
        final fin = formatTime(slot.end);

        if (inicio == cita.horaInicio &&
            fin == cita.horaFin &&
            cita.estado == 'pendiente') {
          slot.isAvailable = false;
        }
      }
    }
  }

  static Future<bool> horarioSigueDisponible({
    required DateTime selectedDate,
    required TimeSlot slot,
  }) async {
    final citasService = CitasService();

    final fecha =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final inicio = formatTime(slot.start);
    final fin = formatTime(slot.end);

    final citas = await citasService.obtenerTodasCitas();

    return !citas.any((c) =>
        c.fecha == fecha &&
        c.horaInicio == inicio &&
        c.horaFin == fin &&
        c.estado == 'pendiente');
  }

  // ===============================
  // UTIL
  // ===============================
  static String formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}
