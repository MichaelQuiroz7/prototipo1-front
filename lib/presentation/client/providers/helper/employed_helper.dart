import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/citas/citas_service.dart';
import 'package:prototipo1_app/config/citas/dtos/cita_entity.dart';

class EmployedHelper {
  static final CitasService _service = CitasService();


  // ======================================================
  //  Obtener citas separadas por estado
  // ======================================================

  static Future<List<CitaEntity>> consultarTodas() async {
    try {
      final List<CitaEntity> todas = await _service.consultarTodas();
      return todas; 
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Error obtenerTodas: $e");
      }
      rethrow;
    }
  }

   // ======================================================
  //  Filtros por estado (usan obtenerTodas)
  // ======================================================

  static Future<List<CitaEntity>> obtenerPendientes() async {
    final todas = await consultarTodas();
    return todas.where((c) => _estado(c) == 'pendiente').toList();
  }

  static Future<List<CitaEntity>> obtenerAsistidas() async {
    final todas = await consultarTodas();
    return todas.where((c) => _estado(c) == 'asistio').toList();
  }

  static Future<List<CitaEntity>> obtenerNoAsistidas() async {
    final todas = await consultarTodas();
    return todas.where((c) => _estado(c) == 'no_asistio').toList();
  }

  static Future<List<CitaEntity>> obtenerCanceladas() async {
    final todas = await consultarTodas();
    return todas.where((c) => _estado(c) == 'cancelada').toList();
  }

  static Future<List<CitaEntity>> obtenerReagendadas() async {
    final todas = await consultarTodas();
    return todas.where((c) => _estado(c) == 'reagendada').toList();
  }
    // ======================================================
  //  Filtrar citas por rango de fechas (lista externa)
  // ======================================================

  static List<CitaEntity> filtrarPorRangoFechas({
    required List<CitaEntity> citas,
    required DateTimeRange rango,
  }) {
    return citas.where((c) {
      if (c.fecha.isEmpty) return false;

      try {
        final fechaCita = DateTime.parse(c.fecha);

        return !fechaCita.isBefore(rango.start) &&
               !fechaCita.isAfter(rango.end);
      } catch (e) {
        if (kDebugMode) {
          debugPrint("⚠️ Fecha inválida en cita ${c.idCita}: ${c.fecha}");
        }
        return false;
      }
    }).toList();
  }


  // ======================================================
//  Filtrar citas por mes y año (lista externa)
// ======================================================

static List<CitaEntity> filtrarPorMesYAnio({
  required List<CitaEntity> citas,
  required int mes,
  required int anio,
}) {
  return citas.where((c) {
    if (c.fecha.isEmpty) return false;

    try {
      final fechaCita = DateTime.parse(c.fecha);

      return fechaCita.month == mes &&
             fechaCita.year == anio;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⚠️ Fecha inválida en cita ${c.idCita}: ${c.fecha}");
      }
      return false;
    }
  }).toList();
}


  


  // ======================================================
  //  Utilidad interna para normalizar estado
  // ======================================================

  static String _estado(CitaEntity c) {
    return (c.estado ?? 'pendiente')
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_');
  }

}
