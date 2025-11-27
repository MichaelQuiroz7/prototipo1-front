

class RolEntity {
  final int idRol;
  final String nombre;
  final String? descripcion;
  final bool eliminado;
  final DateTime fechaCreacion;

  RolEntity({
    required this.idRol,
    required this.nombre,
    this.descripcion,
    this.eliminado = false,
    required this.fechaCreacion,
  });

  factory RolEntity.fromJson(Map<String, dynamic> json) {
    return RolEntity(
      idRol: json['IdRol'] ?? json['id_rol'] ?? 0,
      nombre: json['Nombre'] ?? json['nombre'] ?? '',
      descripcion: json['Descripcion'] ?? json['descripcion'],
      eliminado: json['Eliminado'] ?? json['eliminado'] ?? false,
      fechaCreacion: DateTime.tryParse(
            json['FechaCreacion'] ?? json['fecha_creacion'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdRol': idRol,
      'Nombre': nombre,
      'Descripcion': descripcion,
      'Eliminado': eliminado,
      'FechaCreacion': fechaCreacion.toIso8601String(),
    };
  }
}
