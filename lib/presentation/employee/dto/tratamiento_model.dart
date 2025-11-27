import 'especialidad_model.dart';

class Tratamiento {
  final int idTratamiento;
  final String? codigo;
  final String nombre;
  final String? descripcion;
  final String? imagen;
  final double precio;
  final int idEspecialidad;
  final bool eliminado;
  final DateTime fechaCreacion;
  final Especialidad? especialidad;

  Tratamiento({
    required this.idTratamiento,
    this.codigo,
    required this.nombre,
    this.descripcion,
    this.imagen,
    required this.precio,
    required this.idEspecialidad,
    this.eliminado = false,
    required this.fechaCreacion,
    this.especialidad,
  });

  // ===========================================================
  // 🔹 CONSTRUCTOR DESDE JSON (desde el backend)
  // ===========================================================
  factory Tratamiento.fromJson(Map<String, dynamic> json) {
    return Tratamiento(
      idTratamiento: _safeInt(json['IdTratamiento'] ?? json['idtratamiento']),
      codigo: json['Codigo'] ?? json['codigo'],
      nombre: json['Nombre'] ?? json['nombre'] ?? '',
      descripcion: json['Descripcion'] ?? json['descripcion'],
      imagen: json['Imagen'] ?? json['imagen'],
      precio: _safeDouble(json['Precio'] ?? json['precio']),
      idEspecialidad: _safeInt(json['IdEspecialidad'] ?? json['idespecialidad']),
      eliminado: json['Eliminado'] ?? json['eliminado'] ?? false,
      fechaCreacion: _safeDate(json['FechaCreacion'] ?? json['fechacreacion']),
      especialidad: json['Especialidad'] != null &&
              json['Especialidad'] is Map<String, dynamic>
          ? Especialidad.fromJson(json['Especialidad'])
          : null,
    );
  }

  // ===========================================================
  // 🔹 CONVERTIR A JSON (para enviar al backend)
  // ===========================================================
  Map<String, dynamic> toJson({bool includeEspecialidad = false}) {
    final data = {
      'IdTratamiento': idTratamiento,
      'Codigo': codigo,
      'Nombre': nombre,
      'Descripcion': descripcion,
      'Imagen': imagen,
      'Precio': precio,
      'IdEspecialidad': idEspecialidad,
      'Eliminado': eliminado,
      'FechaCreacion': fechaCreacion.toIso8601String(),
    };

    if (includeEspecialidad && especialidad != null) {
      data['Especialidad'] = especialidad!.toJson();
    }

    return data;
  }

  // ===========================================================
  // 🧩 MÉTODOS AUXILIARES SEGUROS
  // ===========================================================
  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _safeDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}