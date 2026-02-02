class Promocion {
  final int? idPromocion;
  final int idTratamiento;
  final double precioAntes;
  final double precioAhora;
  final bool es2x1;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int limite;
  final bool eliminado;
  final DateTime fechaCreacion;

  Promocion({
    this.idPromocion,
    required this.idTratamiento,
    required this.precioAntes,
    required this.precioAhora,
    required this.es2x1,
    required this.fechaInicio,
    required this.fechaFin,
    this.limite = 10000,
    this.eliminado = false,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      idPromocion: json['idPromocion'] ?? json['id_promocion'],
      idTratamiento: json['idTratamiento'] ?? json['id_tratamiento'],
      precioAntes: _safeDouble(json['precioAntes'] ?? json['precio_antes']),
      precioAhora: _safeDouble(json['precioAhora'] ?? json['precio_ahora']),
      es2x1: json['es2x1'] ?? json['es_2x1'] ?? false,
      fechaInicio: _safeDate(json['fechaInicio'] ?? json['fecha_inicio']),
      fechaFin: _safeDate(json['fechaFin'] ?? json['fecha_fin']),
      limite: json['limite'] ?? 10000,
      eliminado: json['eliminado'] ?? false,
      fechaCreacion: _safeDate(json['fechaCreacion'] ?? json['fecha_creacion']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final data = {
      'idTratamiento': idTratamiento,
      'precioAntes': precioAntes,
      'precioAhora': precioAhora,
      'es2x1': es2x1,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'limite': limite,
    };

    if (includeId && idPromocion != null) {
      data['idPromocion'] = idPromocion as Object;
    }

    return data;
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _safeDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'idTratamiento': idTratamiento,
      'precioAntes': precioAntes,
      'precioAhora': precioAhora,
      'es2x1': es2x1,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'limite': limite,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'idPromocion': idPromocion,
      'precioAntes': precioAntes,
      'precioAhora': precioAhora,
      'es2x1': es2x1,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'limite': limite,
    };
  }
  
}


