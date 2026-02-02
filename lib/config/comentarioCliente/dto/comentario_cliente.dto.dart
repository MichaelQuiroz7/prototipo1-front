class ComentarioCliente {
  final int idComentario;
  final String image;
  final String nombre;
  final String tratamiento;
  final double puntuacion;
  final String feedback;
  final bool eliminado;
  final DateTime fecha;

  ComentarioCliente({
    required this.idComentario,
    required this.image,
    required this.nombre,
    required this.tratamiento,
    required this.puntuacion,
    required this.feedback,
    required this.eliminado,
    required this.fecha,
  });

  // ===========================================================
  //  FACTORY: DESDE JSON (BACKEND → FRONT)
  // ===========================================================
  factory ComentarioCliente.fromJson(Map<String, dynamic> json) {
    return ComentarioCliente(
      idComentario: _safeInt(json['idComentario'] ?? json['id_comentario']),
      image: json['image'] ?? '',
      nombre: json['nombre'] ?? '',
      tratamiento: json['tratamiento'] ?? '',
      puntuacion: _safeDouble(json['puntuacion']),
      feedback: json['feedback'] ?? '',
      eliminado: json['eliminado'] ?? false,
      fecha: toEcuadorTime(_safeDate(json['fecha'])),


    );
  }

  // ===========================================================
  //  TO JSON (FRONT → BACKEND si lo necesitas)
  // ===========================================================
  Map<String, dynamic> toJson() {
    return {
      'idComentario': idComentario,
      'image': image,
      'nombre': nombre,
      'tratamiento': tratamiento,
      'puntuacion': puntuacion,
      'feedback': feedback,
      'eliminado': eliminado,
      'fecha': fecha.toIso8601String(),
    };
  }

  // ===========================================================
  //  HELPERS SEGUROS
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

static DateTime toEcuadorTime(DateTime utcDate) {
  return utcDate.toUtc().subtract(const Duration(hours: 5));
}

}
