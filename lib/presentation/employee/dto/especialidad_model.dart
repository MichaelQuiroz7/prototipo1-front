import 'tratamiento_model.dart';

class Especialidad {
  final int idEspecialidad;
  final String nombre;
  final String? descripcion;
  final String? imagen;
  final bool eliminado;
  final DateTime fechaCreacion;
  final List<Tratamiento>? tratamientos;

  Especialidad({
    required this.idEspecialidad,
    required this.nombre,
    this.descripcion,
    this.imagen,
    this.eliminado = false,
    required this.fechaCreacion,
    this.tratamientos,
  });

  // 🔹 Constructor desde JSON (desde la API)
  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      idEspecialidad: json['IdEspecialidad'] ?? json['idespecialidad'] ?? 0,
      nombre: json['Nombre'] ?? json['nombre'] ?? '',
      descripcion: json['Descripcion'] ?? json['descripcion'],
      imagen: json['Imagen'] ?? json['imagen'],
      eliminado: json['Eliminado'] ?? json['eliminado'] ?? false,
      fechaCreacion: DateTime.tryParse(
            json['FechaCreacion'] ?? json['fechacreacion'] ?? '',
          ) ??
          DateTime.now(),
      tratamientos: json['Tratamientos'] != null
          ? (json['Tratamientos'] as List)
              .map((t) => Tratamiento.fromJson(t))
              .toList()
          : null,
    );
  }

  // 🔹 Convertir a JSON (para enviar al backend)
  Map<String, dynamic> toJson({bool includeTratamientos = false}) {
    final data = {
      'IdEspecialidad': idEspecialidad,
      'Nombre': nombre,
      'Descripcion': descripcion,
      'Imagen': imagen,
      'Eliminado': eliminado,
      'FechaCreacion': fechaCreacion.toIso8601String(),
    };

    if (includeTratamientos && tratamientos != null) {
      data['Tratamientos'] = tratamientos!.map((t) => t.toJson()).toList();
    }

    return data;
  }
}